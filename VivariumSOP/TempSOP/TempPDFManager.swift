//
//  TempPDFManager.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/23/25.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

class TempPDFManager {
    static let shared = TempPDFManager()

    private let storage = Storage.storage()
    private let db = Firestore.firestore()

    func uploadTempPDF(data: Data, organizationId: String, category: String, subcategory: String, filename: String) async throws -> String {
        // Construct storage path
        let path = "pdfs/\(organizationId)/\(category)/\(subcategory)/\(filename).pdf"
        let storageRef = storage.reference().child(path)

        // Upload file to Firebase Storage
        _ = try await storageRef.putDataAsync(data)

        // Get download URL
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }

    func saveTempPDFMetadata(organizationId: String, category: String, subcategory: String, filename: String, downloadURL: String) async throws {
        // Create Firestore document metadata
        let tempPDFMetadata = [
            "organizationId": organizationId,
            "category": category,
            "subcategory": subcategory,
            "filename": filename,
            "fileURL": downloadURL,
            "uploadedAt": FieldValue.serverTimestamp()
        ] as [String : Any]

        // Save metadata to Firestore
        try await db.collection("Organizations")
            .document(organizationId)
            .collection("TempPDFs")
            .document(UUID().uuidString)
            .setData(tempPDFMetadata)
    }

    func fetchAvailableTempPDFs(organizationId: String) async throws -> [TempPDF] {
        let snapshot = try await db.collection("Organizations")
            .document(organizationId)
            .collection("TempPDFs")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            try? document.data(as: TempPDF.self)
        }
    }
}


struct TempPDF: Identifiable, Codable {
    let id: String
    let category: String
    let subcategory: String
    let filename: String
    let fileURL: String
    let organizationId: String
    let uploadedAt: Date?
}
