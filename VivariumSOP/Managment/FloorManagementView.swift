//
//  FloorManagementView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/25/25.
//

import SwiftUI

class FloorManagementViewModel: ObservableObject {
    @Published var floors: [FloorSection] = []
    @Published var showingAddSectionAlert = false
    @Published var newSectionName = ""
    @AppStorage("organizationId")  var organizationId: String = ""
    private var selectedFloor: FloorSection?
    
    init() {
        Task { @MainActor in
            await loadFloors()
        }
    }
    
    @MainActor
    func loadFloors() async {
        do {
            floors = try await UserManager.shared.getFloorStructure(organizationId: organizationId)
        } catch {
            print("Error loading floors: \(error)")
        }
    }
    
    func showAddSectionAlert(for floor: FloorSection) {
        selectedFloor = floor
        showingAddSectionAlert = true
    }
    
    func addSection() {
        guard let floor = selectedFloor,
              !newSectionName.isEmpty,
              let index = floors.firstIndex(where: { $0.id == floor.id }) else { return }
        
        var updatedFloor = floor
        updatedFloor.sections.append(newSectionName)
        floors[index] = updatedFloor
        
        saveFloors()
        newSectionName = ""
    }
    
    func removeSection(from floor: FloorSection, at indexSet: IndexSet) {
        guard let index = floors.firstIndex(where: { $0.id == floor.id }) else { return }
        
        var updatedFloor = floor
        updatedFloor.sections.remove(atOffsets: indexSet)
        floors[index] = updatedFloor
        
        saveFloors()
    }
    
     func saveFloors() {
        Task {
            do {
                try await UserManager.shared.updateFloorStructure(
                    organizationId: organizationId,
                    floors: floors
                )
            } catch {
                print("Error saving floors: \(error)")
            }
        }
    }
}





// Floor Section Row View
struct FloorSectionRow: View {
    let section: String
    
    var body: some View {
        Text(section)
    }
}



// Main Floor Management View
struct FloorManagementView: View {
    @ObservedObject var viewModel: BuildingManagerViewModel
    let buildingId: Building
    
    @State private var showingAddFloorSheet = false
    @State private var showingAddSectionAlert = false
    @State private var newSectionName = ""
    @State private var selectedFloor: Floor?
    @Environment(\.dismiss) var dismiss
    
    var floors: [Floor] {
        viewModel.floors[buildingId.id] ?? []
    }
    
    var body: some View {
        FloorListView(
            viewModel: viewModel,
            floors: floors,
            showingAddFloorSheet: $showingAddFloorSheet,
            showingAddSectionAlert: $showingAddSectionAlert,
            newSectionName: $newSectionName,
            selectedFloor: $selectedFloor,
            buildingId: buildingId
        )
    }
}

// Separate List View
struct FloorListView: View {
    @ObservedObject var viewModel: BuildingManagerViewModel
    let floors: [Floor]
    @Binding var showingAddFloorSheet: Bool
    @Binding var showingAddSectionAlert: Bool
    @Binding var newSectionName: String
    @Binding var selectedFloor: Floor?
    let buildingId: Building
    
    var body: some View {
    
            ForEach(floors) { floor in
                FloorRow(
                    viewModel: viewModel,
                    floor: floor,
                    onAddSection: {
                        selectedFloor = floor
                        showingAddSectionAlert = true
                    }
                )
            }
       
        .navigationTitle("Floor Management")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add Floor") {
                    showingAddFloorSheet = true
                }
            }
        }
        .sheet(isPresented: $showingAddFloorSheet) {
            AddFloorView(viewModel: viewModel, building: buildingId)
        }
        .alert("Add Section", isPresented: $showingAddSectionAlert) {
            TextField("Section Name", text: $newSectionName)
            Button("Cancel", role: .cancel) {
                newSectionName = ""
            }
            Button("Add") {
                if let floor = selectedFloor, !newSectionName.isEmpty {
                    viewModel.addSection(to: floor, name: newSectionName)
                    newSectionName = ""
                    selectedFloor = nil
                }
            }
        }
        .onAppear {
            viewModel.setupFloorListener(for: buildingId.id)
        }
        .onDisappear {
            viewModel.removeListener(for: buildingId.id)
        }
    }
}

