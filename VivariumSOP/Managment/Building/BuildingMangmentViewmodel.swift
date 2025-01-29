//
//  BuildingMangmentViewmodel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/28/25.
//

import SwiftUI
class BuildingManagementViewModel: ObservableObject {
    @Published var buildings: [Building] = []
    @Published var showingAddBuildingSheet = false
    @Published var selectedBuilding: Building?
    @AppStorage("organizationId") var organizationId: String = ""
    
    init() {
        Task { @MainActor in
            await loadBuildings()
        }
    }
    
    @MainActor
    func loadBuildings() async {
        do {
            buildings = try await BuildingManager.shared.getBuildings(organizationId: organizationId)
        } catch {
            print("Error loading buildings: \(error)")
        }
    }
    
    func saveBuilding(_ building: Building) {
        Task {
            do {
                try await BuildingManager.shared.updateBuilding(building)
                await loadBuildings()
            } catch {
                print("Error saving building: \(error)")
            }
        }
    }
    
    func deleteBuildingWithFloors(building: Building) {
        Task {
            do {
                try await BuildingManager.shared.deleteBuilding(building.id)
                await loadBuildings()
            } catch {
                print("Error deleting building: \(error)")
            }
        }
    }
}


import SwiftUI
import FirebaseFirestore

class BuildingManagerViewModel: ObservableObject {
    @Published var buildings: [Building] = []
    @Published var floors: [String: [Floor]] = [:] // Dictionary of buildingId: [Floor]
    private var floorListeners: [String: ListenerRegistration] = [:]
     let db = Firestore.firestore()
    
    deinit {
        // Remove all listeners when view model is deallocated
        removeAllListeners()
    }
    func updateUser(_ user: User) async throws {
          try await db.collection("users")
              .document(user.id ?? "")
              .setData(from: user)
      }
      
      func fetchFloors(for organizationId: String) async -> [FloorSection] {
          do {
              let snapshot = try await db.collection("floors")
                  .whereField("organizationId", isEqualTo: organizationId)
                  .getDocuments()
              
              return snapshot.documents.compactMap { try? $0.data(as: FloorSection.self) }
          } catch {
              print("Error fetching floors: \(error)")
              return []
          }
      }

    func fetchBuildings(organizationId: String) {
        db.collection("buildings")
            .whereField("organizationId", isEqualTo: organizationId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else {
                    print("Error fetching buildings: \(error?.localizedDescription ?? "")")
                    return
                }
                
                self.buildings = documents.compactMap { document -> Building? in
                    try? document.data(as: Building.self)
                }
            }
    }
    
    func setupFloorListener(for buildingId: String) {
        // Remove existing listener if any
        floorListeners[buildingId]?.remove()
        
        let listener = db.collection("floors")
            .whereField("buildingId", isEqualTo: buildingId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else {
                    print("Error fetching floors: \(error?.localizedDescription ?? "")")
                    return
                }
                
                let floors = documents.compactMap { document -> Floor? in
                    try? document.data(as: Floor.self)
                }.sorted { $0.level < $1.level }
                
                DispatchQueue.main.async {
                    self.floors[buildingId] = floors
                    print(self.floors[buildingId])
                }
                
            }
       
        print(buildingId)
        floorListeners[buildingId] = listener
    }
    
    func removeListener(for buildingId: String) {
        floorListeners[buildingId]?.remove()
        floorListeners[buildingId] = nil
    }
    
    private func removeAllListeners() {
        floorListeners.values.forEach { $0.remove() }
        floorListeners.removeAll()
    }
    
 
    
    func addSection(to floor: Floor, name: String) {
           var updatedFloor = floor
           updatedFloor.sections.append(name)  // Just append the section name
           
           do {
               try db.collection("floors").document(floor.id).setData(from: updatedFloor)
           } catch {
               print("Error adding section: \(error.localizedDescription)")
           }
       }
       
       func deleteSection(from floor: Floor, at indexSet: IndexSet) {
           var updatedFloor = floor
           updatedFloor.sections.remove(atOffsets: indexSet)
           
           do {
               try db.collection("floors").document(floor.id).setData(from: updatedFloor)
           } catch {
               print("Error deleting section: \(error.localizedDescription)")
           }
       }
       
       func addFloor(to building: Building, level: Int, name: String, isRestricted: Bool) {
           let floorRef = db.collection("floors").document()
           let floor = Floor(
               id: floorRef.documentID,
               buildingId: building.id,
               organizationId: building.organizationId,
               level: level,
               name: name,
               isRestricted: isRestricted,
               sections: []  // Initialize with empty sections
           )
           
           do {
               try floorRef.setData(from: floor)
           } catch {
               print("Error adding floor: \(error.localizedDescription)")
           }
       }
       
       func updateFloor(_ floor: Floor) {
           do {
               try db.collection("floors").document(floor.id).setData(from: floor)
           } catch {
               print("Error updating floor: \(error.localizedDescription)")
           }
       }
    
    func deleteFloor(_ floor: Floor) {
        db.collection("floors").document(floor.id).delete { error in
            if let error = error {
                print("Error deleting floor: \(error.localizedDescription)")
            }
        }
    }
    
}

