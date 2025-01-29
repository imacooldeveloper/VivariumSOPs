//
//  BuildingManager.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/28/25.
//


import Foundation
import FirebaseFirestore


class BuildingManager {
    static let shared = BuildingManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Building Operations
    func getBuildings(organizationId: String) async throws -> [Building] {
        let snapshot = try await db.collection("buildings")
            .whereField("organizationId", isEqualTo: organizationId)
            .getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: Building.self)
        }
    }
    
    func updateBuilding(_ building: Building) async throws {
        try await db.collection("buildings")
            .document(building.id)
            .setData(from: building, merge: true)
    }
    
    func deleteBuilding(_ buildingId: String) async throws {
        try await db.collection("buildings")
            .document(buildingId)
            .delete()
    }
    
    // MARK: - Building-SOP Association
    func associateSOP(buildingId: String, sopId: String) async throws {
        let association: [String: Any] = [
            "buildingId": buildingId,
            "sopId": sopId,
            "createdAt": Timestamp()
        ]
        
        try await db.collection("building_sops")
            .document("\(buildingId)_\(sopId)")
            .setData(association)
    }
    
    func getAssociatedSOPs(buildingId: String) async throws -> [SOPCategory] {
        let snapshot = try await db.collection("building_sops")
            .whereField("buildingId", isEqualTo: buildingId)
            .getDocuments()
        
        let sopIds = snapshot.documents.map { $0.data()["sopId"] as? String ?? "" }
        
        var sops: [SOPCategory] = []
        for sopId in sopIds {
            if let sopDoc = try? await db.collection("sops")
                .document(sopId)
                .getDocument(),
               let sop = try? sopDoc.data(as: SOPCategory.self) {
                sops.append(sop)
            }
        }
        
        return sops
    }
    
    func removeSOPAssociation(buildingId: String, sopId: String) async throws {
        try await db.collection("building_sops")
            .document("\(buildingId)_\(sopId)")
            .delete()
    }
}
