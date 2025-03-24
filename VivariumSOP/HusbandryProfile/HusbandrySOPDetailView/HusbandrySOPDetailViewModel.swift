//
//  HusbandrySOPDetailViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import Foundation
import Foundation
import FirebaseStorage
import Combine
import FirebaseFirestore
import FirebaseAuth
class PDFViewModel: ObservableObject {
    @Published var pdfDocuments: [PDFDocuments] = []
    @Published var currentUser: User?
    @Published var pdfFile: PDFDocuments?

    private var storage = Storage.storage()
    private var storageRef = Storage.storage().reference()

    var sopcategory: String?
    var category: String?
    var sopName: String?
    var pdfName: String?

    init(sopcategory: String? = nil, category: String? = nil, sopName: String? = nil, pdfName: String? = nil) {
        self.sopcategory = sopcategory
        self.category = category
        self.sopName = sopName
        fetchPDFs(folderName: category ?? "", category: sopcategory ?? "", pdfName: pdfName ?? "")
    }

    @MainActor
    func fecthUser() async throws {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        print(userUID)
        let document = try await Firestore.firestore().collection("Users").document(userUID).getDocument()

        if var user = try? document.data(as: User.self) {
            // Manually set the user's id
            user.id = document.documentID
            currentUser = user
        }
    }
    //@MainActor
    func fetchPDFs(folderName: String, category: String, pdfName: String) {
        guard let organizationId = Auth.auth().currentUser?.uid else { return }
        let pdfsRef = storageRef.child("pdfs/\(organizationId)/\(folderName)/\(category)/\(pdfName)/")
        var tempDocuments: [PDFDocuments] = []
        let dispatchGroup = DispatchGroup()

        pdfsRef.listAll { result, error in
            if let error = error {
                print("Error fetching PDFs: \(error.localizedDescription)")
                return
            }
            guard let result = result else {
                print("No result found for the given folder name")
                return
            }

            for item in result.items {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    defer { dispatchGroup.leave() }

                    if let downloadURL = url {
                        let pdfDocument = PDFDocuments(
                            id: UUID(),
                            name: folderName,
                            category: category,
                            pdfName: pdfName,
                            downloadURL: downloadURL
                        )
                        self.pdfFile = pdfDocument
                        tempDocuments.append(pdfDocument)
                    } else if let error = error {
                        print("Error getting download URL for item \(folderName): \(error.localizedDescription)")
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.pdfDocuments = tempDocuments
            }
        }
    }
    func markPDFAsCompleted(pdfId: String, for user: inout User) async {
        // Convert the String pdfId to UUID
        guard let uuid = UUID(uuidString: pdfId) else {
            print("Invalid UUID string: \(pdfId)")
            return
        }

        let pdfIdString = uuid.uuidString
        if user.userPDFProgress == nil {
            user.userPDFProgress = UserPDFProgress(userID: user.userUID, completedPDFs: [])
        }
        if !(user.userPDFProgress?.completedPDFs.contains(pdfIdString) ?? false) {
            user.userPDFProgress?.completedPDFs.append(pdfIdString)
        }

        do {
            try await updateUserProgressInDataStore(user: user)
        } catch {
            print("Error updating user progress: \(error.localizedDescription)")
        }
    }


    private func updateUserProgressInDataStore(user: User) async throws {
        guard let userId = user.id else {
            print("Error: User ID is nil")
            return
        }
        try await Firestore.firestore().collection("Users").document(userId).setData(from: user)
        print("User progress updated successfully.")
    }

    func isPDFCompleted(pdfId: String) -> Bool {
        guard let completedPDFs = currentUser?.userPDFProgress?.completedPDFs else {
            return false
        }
        return completedPDFs.contains(pdfId)
    }
}
struct PDFDocuments: Identifiable, Hashable {
    var id = UUID() // Unique identifier for each PDF document
    var name: String? // Name of the PDF
    var category: String? // Category of the PDF (e.g., "Technical", "Education", "Entertainment", etc.)
    var pdfName: String?
    var downloadURL: URL? // URL to download the PDF from Firebase Storage (optional)
    
    // Conform to Equatable
       static func == (lhs: PDFDocuments, rhs: PDFDocuments) -> Bool {
           return lhs.id == rhs.id
       }
}
