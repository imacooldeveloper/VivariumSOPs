//
//  PDFCategoryViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

//import UniformTypeIdentifiers
//import Firebase
//import FirebaseFirestoreSwift
//
//
//
//
//@MainActor
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class PDFCategoryViewModel: ObservableObject {
    @Published var pdfCategories: [PDFCategory] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func fetchPDFCategories() {
           db.collection("PDFCategories").addSnapshotListener { [weak self] (querySnapshot, error) in
               guard let documents = querySnapshot?.documents else {
                   print("No documents")
                   return
               }
               
               self?.pdfCategories = documents.compactMap { queryDocumentSnapshot -> PDFCategory? in
                   return try? queryDocumentSnapshot.data(as: PDFCategory.self)
               }
           }
       }
    
    func updatePDFCategory(_ category: PDFCategory) async throws {
        let categoryRef = db.collection("PDFCategories").document(category.id)
        
        // Check if the category exists
        let document = try await categoryRef.getDocument()
        
        if document.exists {
            // Update existing category
            try categoryRef.setData(from: category)
        } else {
            // Add new category
            try await addPDFCategory(category)
        }
    }

    func addPDFCategory(_ category: PDFCategory) async throws {
        var newCategory = category
        if newCategory.id.isEmpty {
            newCategory.id = db.collection("PDFCategories").document().documentID
        }
        try db.collection("PDFCategories").document(newCategory.id).setData(from: newCategory)
    }
    
    deinit {
        listener?.remove()
    }
}
