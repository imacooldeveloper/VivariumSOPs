//
//  FloorDetailView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/28/25.
//

import SwiftUI

struct FloorDetailView: View {
    @ObservedObject var viewModel: BuildingManagerViewModel
    let floor: Floor
    @State private var showingAddSectionAlert = false
    @State private var newSectionName = ""
    
    var body: some View {
        List {
            Section("Floor Information") {
                LabeledContent("Level", value: "\(floor.level)")
                LabeledContent("Name", value: floor.name)
                if floor.isRestricted {
                    Label("Restricted Access", systemImage: "lock.fill")
                        .foregroundStyle(.orange)
                }
            }
            
            Section("Sections") {
                if floor.sections.isEmpty {
                    ContentUnavailableView(
                        "No Sections",
                        systemImage: "square.grid.2x2",
                        description: Text("Add sections to organize this floor")
                    )
                }
                
                ForEach(floor.sections, id: \.self) { section in
                    Text(section)
                }
                .onDelete { indexSet in
                    var updatedFloor = floor
                    updatedFloor.sections.remove(atOffsets: indexSet)
                    viewModel.updateFloor(updatedFloor)
                }
            }
        }
        .navigationTitle("Floor Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSectionAlert = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .alert("Add Section", isPresented: $showingAddSectionAlert) {
            TextField("Section Name", text: $newSectionName)
            Button("Cancel", role: .cancel) {
                newSectionName = ""
            }
            Button("Add") {
                if !newSectionName.isEmpty {
                    viewModel.addSection(to: floor, name: newSectionName)
                    newSectionName = ""
                }
            }
        }
    }
}
