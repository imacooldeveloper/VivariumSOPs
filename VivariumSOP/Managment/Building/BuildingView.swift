//
//  BuildingView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/28/25.
//

import SwiftUI



import SwiftUI
import FirebaseFirestore

struct BuildingManagementView: View {
    @EnvironmentObject private var viewModel: BuildingManagerViewModel
    @AppStorage("organizationId") var organizationId: String = ""
    
    var body: some View {
        
            BuildingView()
    
    }
}

struct BuildingView: View {
    @EnvironmentObject var viewModel: BuildingManagerViewModel
    @AppStorage("organizationId") var organizationId: String = ""
    @State private var showingAddBuilding = false
    @State private var searchText = ""
    
    var filteredBuildings: [Building] {
        if searchText.isEmpty {
            return viewModel.buildings
        }
        return viewModel.buildings.filter { building in
            building.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredBuildings) { building in
                    
                    
                    NavigationLink(value: building) {
                        BuildingCard(building: building)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .overlay {
            if viewModel.buildings.isEmpty {
                ContentUnavailableView(
                    "No Buildings",
                    systemImage: "building.2",
                    description: Text("Add a new building to get started")
                )
            }
        }
        .navigationTitle("Buildings")
        .searchable(text: $searchText, prompt: "Search buildings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddBuilding = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddBuilding) {
            AddBuildingView()
        }
        .onAppear {
            viewModel.fetchBuildings(organizationId: organizationId)
        }
        
    }
}

struct BuildingCard: View {
    @EnvironmentObject var viewModel: BuildingManagerViewModel
    let building: Building
    
    var floorCount: Int {
        viewModel.floors[building.id]?.count ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(building.name)
                .font(.headline)
            
            HStack {
                Label("\(floorCount) Floors", systemImage: "stairs")
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

struct AddBuildingView: View {
    @EnvironmentObject var viewModel: BuildingManagerViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("organizationId") var organizationId: String = ""
    
    @State private var name = ""
    @State private var code = ""
    @State private var type: Building.BuildingType = .research
    @State private var bsl: Building.BioSafetyLevel = .bsl2
    @State private var address = ""
    @State private var notes = ""
    @State private var isActive = true
    
    var body: some View {
       
            Form {
                Section("Building Information") {
                    TextField("Name", text: $name)
                    TextField("Code", text: $code)
                    TextField("Address", text: $address)
                    Picker("Type", selection: $type) {
                        ForEach(Building.BuildingType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Picker("BSL Level", selection: $bsl) {
                        ForEach(Building.BioSafetyLevel.allCases, id: \.self) { level in
                            Text("BSL-\(level.rawValue)").tag(level)
                        }
                    }
                }
                
                Section("Additional Details") {
                    Toggle("Active", isOn: $isActive)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Building")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newBuilding = Building(
                            id: UUID().uuidString,
                            name: name,
                            code: code,
                            type: type,
                            maxBioSafetyLevel: bsl,
                            address: address,
                            notes: notes.isEmpty ? nil : notes,
                            isActive: isActive,
                            organizationId: organizationId,
                            floors: []
                        )
                        
                        Task {
                            do {
                                try await viewModel.db.collection("buildings")
                                    .document(newBuilding.id)
                                    .setData(from: newBuilding)
                                dismiss()
                            } catch {
                                print("Error saving building: \(error)")
                            }
                        }
                    }
                    .disabled(name.isEmpty || code.isEmpty || address.isEmpty)
                }
            }
       
    }
}

struct BuildingDetailView: View {
    @EnvironmentObject var viewModel: BuildingManagerViewModel
    let building: Building
    @State private var showingAddFloor = false
    
    var floors: [Floor] {
        viewModel.floors[building.id] ?? []
    }
    
    var body: some View {
        List {
            // Building Information Section with improved styling
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(building.name)
                            .font(.headline)
                        Text(building.code)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.secondary.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    Text(building.type.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(building.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Label("BSL-\(building.maxBioSafetyLevel.rawValue)", systemImage: "shield.fill")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.yellow.opacity(0.2))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        if !building.isActive {
                            Text("Inactive")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    if let notes = building.notes {
                        Text(notes)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("BUILDING INFORMATION")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            // Floors Section with improved styling
            Section {
                if floors.isEmpty {
                    ContentUnavailableView(
                        "No Floors",
                        systemImage: "stairs",
                        description: Text("Add floors to this building")
                    )
                }
                
                ForEach(floors) { floor in
                    NavigationLink(value: floor) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Level \(floor.level)")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(floor.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                if floor.isRestricted {
                                    Label("Restricted", systemImage: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                                
                                if !floor.sections.isEmpty {
                                    Label {
                                        Text("\(floor.sections.count) Sections")
                                    } icon: {
                                        Image(systemName: "rectangle.3.group")
                                            .foregroundStyle(.blue)
                                    }
                                    .font(.caption)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                HStack {
                    Text("FLOORS")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(floors.count) Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
      
        .navigationTitle(building.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddFloor = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddFloor) {
            AddFloorView(viewModel: viewModel, building: building)
        }
        .navigationDestination(for: Floor.self) { floor in
            FloorDetailView(viewModel: viewModel, floor: floor)
        }
        .onAppear{
            Task{
                try await viewModel.setupFloorListener(for: building.id)
           }
        }
    }
}


struct BuildingSOPView: View {
    let building: Building
    @State private var associatedSOPs: [SOPCategory] = []
    @State private var showingSOPPicker = false
    
    var body: some View {
        List {
            ForEach(associatedSOPs) { sop in
                VStack(alignment: .leading) {
                    Text(sop.SOPForStaffTittle)
                        .font(.headline)
                    Text(sop.nameOfCategory)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .onDelete { indexSet in
                // Handle SOP deletion/disassociation
            }
            
            Button("Add SOP") {
                showingSOPPicker = true
            }
        }
        .navigationTitle("Building SOPs")
        .sheet(isPresented: $showingSOPPicker) {
            // Add SOP picker view here
        }
    }
}
