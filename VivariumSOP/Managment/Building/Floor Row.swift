//
//  Floor Row.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/28/25.
//

import SwiftUI
// Floor Row View
struct FloorRow: View {
    @ObservedObject var viewModel: BuildingManagerViewModel
    let floor: Floor
    let onAddSection: () -> Void
    
    var body: some View {
        Section(header: Text("Level \(floor.level): \(floor.name)")) {
            ForEach(floor.sections, id: \.self) { section in
                FloorSectionRow(section: section)
            }
            .onDelete { indexSet in
                var updatedFloor = floor
                updatedFloor.sections.remove(atOffsets: indexSet)
                viewModel.updateFloor(updatedFloor)
            }
            
            Button("Add Section") {
                onAddSection()
            }
        }
    }
}
struct AddFloorView: View {
    @ObservedObject var viewModel: BuildingManagerViewModel
    let building: Building
    @Environment(\.dismiss) private var dismiss
    
    @State private var floorLevel = 1
    @State private var floorName = ""
    @State private var isRestricted = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Floor Details") {
                    Stepper("Level: \(floorLevel)", value: $floorLevel)
                    TextField("Floor Name", text: $floorName)
                    Toggle("Restricted Access", isOn: $isRestricted)
                }
                
                Section {
                    Button("Add Floor") {
                        viewModel.addFloor(to: building, level: floorLevel, name: floorName, isRestricted: isRestricted)
                        
//                        
//                        addFloor(
//                            to: building,
//                            floorName: floorName,
//                            level: floorLevel,
//                            isRestricted: isRestricted
//                        )
                        dismiss()
                    }
                    .disabled(floorName.isEmpty)
                }
            }
            .navigationTitle("Add Floor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
