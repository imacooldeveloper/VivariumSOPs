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
import FirebaseStorage

import SwiftUI


@MainActor
//class PDFCategoryViewModel: ObservableObject {
//    @Published private(set) var pdfCategories: [PDFCategory] = []
//    @Published private(set) var uniqueCategories: [String] = []
//    @Published var isLoading = true
//    
//    private var storage = Storage.storage()
//    private var db = Firestore.firestore()
//    private var listener: ListenerRegistration?
//    
//    
//    
//    
//    init() {
//        Task {
//            await fetchPDFCategories()
//        }
//    }
//    
//    func fetchCategoriesIfNeeded() {
//        Task {
//            await fetchPDFCategories()
//        }
//    }
//    
//    private func fetchPDFCategories() async {
//        print("Fetching PDF categories...")
//        isLoading = true
//        
//        do {
//            let snapshot = try await db.collection("PDFCategories").getDocuments()
//            let fetchedCategories = snapshot.documents.compactMap { queryDocumentSnapshot -> PDFCategory? in
//                return try? queryDocumentSnapshot.data(as: PDFCategory.self)
//            }
//            
//            await MainActor.run {
//                self.pdfCategories = fetchedCategories
//                self.updateUniqueCategories()
//                print("Fetched \(self.pdfCategories.count) categories")
//                self.isLoading = false
//            }
//        } catch {
//            print("Error fetching categories: \(error.localizedDescription)")
//            await MainActor.run {
//                self.isLoading = false
//            }
//        }
//    }
//    
//    private func updateUniqueCategories() {
//        let categories = Set(pdfCategories.map { $0.nameOfCategory })
//        uniqueCategories = Array(categories).sorted()
//    }
//    
//    func getSubcategories(for category: String) -> [String] {
//        let subcategories = Set(pdfCategories.filter { $0.nameOfCategory == category }.map { $0.SOPForStaffTittle })
//        return Array(subcategories).sorted()
//    }
//    
//    func filteredPDFs(category: String, subcategory: String) -> [PDFCategory] {
//        pdfCategories.filter { $0.nameOfCategory == category && $0.SOPForStaffTittle == subcategory }
//            .sorted(by: { $0.pdfName < $1.pdfName })
//    }
//    
//    func updatePDFCategory(_ category: PDFCategory) async {
//        do {
//            let categoryRef = db.collection("PDFCategories").document(category.id)
//            try await categoryRef.setData(from: category, merge: true)
//        } catch {
//            print("Error updating PDF category: \(error.localizedDescription)")
//        }
//    }
//    
//    func addPDFCategory(_ category: PDFCategory) async {
//        do {
//            var newCategory = category
//            if newCategory.id.isEmpty {
//                newCategory.id = db.collection("PDFCategories").document().documentID
//            }
//            try await db.collection("PDFCategories").document(newCategory.id).setData(from: newCategory)
//        } catch {
//            print("Error adding PDF category: \(error.localizedDescription)")
//        }
//    }
//    
//    func deleteCategory(_ category: String) async {
//        do {
//            let batch = db.batch()
//            let query = db.collection("PDFCategories").whereField("nameOfCategory", isEqualTo: category)
//            let snapshot = try await query.getDocuments()
//            
//            for document in snapshot.documents {
//                batch.deleteDocument(document.reference)
//            }
//            
//            try await batch.commit()
//            
//            await MainActor.run {
//                self.pdfCategories.removeAll { $0.nameOfCategory == category }
//                self.updateUniqueCategories()
//            }
//        } catch {
//            print("Error deleting category: \(error.localizedDescription)")
//        }
//    }
//    
//    func deletePDF(_ pdf: PDFCategory) async {
//        do {
//            let id = pdf.id
//            
//            // Delete the document from Firestore
//            try await db.collection("PDFCategories").document(id).delete()
//            
//            // Delete the PDF file from Firebase Storage
//            if let pdfURL = pdf.pdfURL, let url = URL(string: pdfURL) {
//                let path = "pdfs/\(pdf.nameOfCategory)/\(pdf.SOPForStaffTittle)/\(pdf.pdfName).pdf"
//                let storageRef = storage.reference().child(path)
//                try await storageRef.delete()
//            }
//            
//            // Update the local array
//            await removePDFCategory(withID: id)
//            
//            // Check if the category folder is empty and delete it if so
//            await deleteEmptyFolders(category: pdf.nameOfCategory, subcategory: pdf.SOPForStaffTittle)
//        } catch {
//            print("Error deleting PDF: \(error.localizedDescription)")
//        }
//    }
//
//    @MainActor
//    private func removePDFCategory(withID id: String) {
//        pdfCategories.removeAll { $0.id == id }
//        updateUniqueCategories()
//    }
//    
//    private func deleteEmptyFolders(category: String, subcategory: String) async {
//        let path = "pdfs/\(category)/\(subcategory)"
//        let storageRef = storage.reference().child(path)
//        
//        do {
//            let items = try await storageRef.listAll()
//            if items.items.isEmpty && items.prefixes.isEmpty {
//                // The folder is empty, so delete it
//                try await storageRef.delete()
//                
//                // Check if the parent folder (category) is now empty
//                let parentRef = storage.reference().child("pdfs/\(category)")
//                let parentItems = try await parentRef.listAll()
//                if parentItems.items.isEmpty && parentItems.prefixes.isEmpty {
//                    try await parentRef.delete()
//                }
//            }
//        } catch {
//            print("Error checking/deleting empty folders: \(error.localizedDescription)")
//        }
//    }
//    
//    func uploadPDF(data: Data, category: PDFCategory) async {
//        do {
//            let path = "pdfs/\(category.nameOfCategory)/\(category.SOPForStaffTittle)/\(category.pdfName).pdf"
//            let storageRef = storage.reference().child(path)
//            
//            let _ = try await storageRef.putDataAsync(data)
//            let downloadURL = try await storageRef.downloadURL()
//            
//            var updatedCategory = category
//            updatedCategory.pdfURL = downloadURL.absoluteString
//            
//            let docRef = db.collection("PDFCategories").document(category.id)
//            try await docRef.setData(from: updatedCategory)
//            
//            await updatePDFCategories(with: updatedCategory)
//        } catch {
//            print("Error uploading PDF: \(error.localizedDescription)")
//        }
//    }
//
//    @MainActor
//    private func updatePDFCategories(with updatedCategory: PDFCategory) {
//        if let index = pdfCategories.firstIndex(where: { $0.id == updatedCategory.id }) {
//            pdfCategories[index] = updatedCategory
//        } else {
//            pdfCategories.append(updatedCategory)
//        }
//        updateUniqueCategories()
//    }
//    
//    deinit {
//        listener?.remove()
//    }
//}
class PDFCategoryViewModel: ObservableObject {
    @Published private(set) var pdfCategories: [PDFCategory] = []
    @Published private(set) var uniqueCategories: [String] = []
    @Published var isLoading = true
    
    private var storage = Storage.storage()
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        Task {
            await fetchPDFCategories()
        }
    }
    
    func fetchCategoriesIfNeeded() {
        Task {
            await fetchPDFCategories()
        }
    }
    
    private func fetchPDFCategories() async {
        print("Fetching PDF categories...")
        isLoading = true
        
        do {
            let snapshot = try await db.collection("PDFCategories").getDocuments()
            let fetchedCategories = snapshot.documents.compactMap { queryDocumentSnapshot -> PDFCategory? in
                return try? queryDocumentSnapshot.data(as: PDFCategory.self)
            }
            
            await MainActor.run {
                self.pdfCategories = fetchedCategories
                self.updateUniqueCategories()
                print("Fetched \(self.pdfCategories.count) categories")
                self.isLoading = false
            }
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func updateUniqueCategories() {
        let categories = Set(pdfCategories.map { $0.nameOfCategory })
        uniqueCategories = Array(categories).sorted()
    }
    
    func getSubcategories(for category: String) -> [String] {
        let subcategories = Set(pdfCategories.filter { $0.nameOfCategory == category }.map { $0.SOPForStaffTittle })
        return Array(subcategories).sorted()
    }
    
    func filteredPDFs(category: String, subcategory: String) -> [PDFCategory] {
        pdfCategories.filter { $0.nameOfCategory == category && $0.SOPForStaffTittle == subcategory }
            .sorted(by: { $0.pdfName < $1.pdfName })
    }
    
    func updatePDFCategory(_ category: PDFCategory) async {
        do {
            let categoryRef = db.collection("PDFCategories").document(category.id)
            try await categoryRef.setData(from: category, merge: true)
        } catch {
            print("Error updating PDF category: \(error.localizedDescription)")
        }
    }
    
    func addPDFCategory(_ category: PDFCategory) async {
        do {
            var newCategory = category
            if newCategory.id.isEmpty {
                newCategory.id = db.collection("PDFCategories").document().documentID
            }
            try await db.collection("PDFCategories").document(newCategory.id).setData(from: newCategory)
        } catch {
            print("Error adding PDF category: \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(_ category: String) async {
        do {
            let batch = db.batch()
            let query = db.collection("PDFCategories").whereField("nameOfCategory", isEqualTo: category)
            let snapshot = try await query.getDocuments()
            
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            try await batch.commit()
            
            await MainActor.run {
                self.pdfCategories.removeAll { $0.nameOfCategory == category }
                self.updateUniqueCategories()
            }
        } catch {
            print("Error deleting category: \(error.localizedDescription)")
        }
    }
    
    func deletePDF(_ pdf: PDFCategory) async {
        do {
            let id = pdf.id
            
            // Delete the document from Firestore
            try await db.collection("PDFCategories").document(id).delete()
            
            // Delete the PDF file from Firebase Storage
            if let pdfURL = pdf.pdfURL, let url = URL(string: pdfURL) {
                let path = "pdfs/\(pdf.nameOfCategory)/\(pdf.SOPForStaffTittle)/\(pdf.pdfName).pdf"
                let storageRef = storage.reference().child(path)
                try await storageRef.delete()
            }
            
            // Update the local array
            await removePDFCategory(withID: id)
            
            // Check if the category folder is empty and delete it if so
            await deleteEmptyFolders(category: pdf.nameOfCategory, subcategory: pdf.SOPForStaffTittle)
        } catch {
            print("Error deleting PDF: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func removePDFCategory(withID id: String) {
        pdfCategories.removeAll { $0.id == id }
        updateUniqueCategories()
    }
    
    private func deleteEmptyFolders(category: String, subcategory: String) async {
        let path = "pdfs/\(category)/\(subcategory)"
        let storageRef = storage.reference().child(path)
        
        do {
            let items = try await storageRef.listAll()
            if items.items.isEmpty && items.prefixes.isEmpty {
                // The folder is empty, so delete it
                try await storageRef.delete()
                
                // Check if the parent folder (category) is now empty
                let parentRef = storage.reference().child("pdfs/\(category)")
                let parentItems = try await parentRef.listAll()
                if parentItems.items.isEmpty && parentItems.prefixes.isEmpty {
                    try await parentRef.delete()
                }
            }
        } catch {
            print("Error checking/deleting empty folders: \(error.localizedDescription)")
        }
    }
    
    func uploadPDF(data: Data, category: PDFCategory) async {
        do {
            let path = "pdfs/\(category.nameOfCategory)/\(category.SOPForStaffTittle)/\(category.pdfName).pdf"
            let storageRef = storage.reference().child(path)
            
            let _ = try await storageRef.putDataAsync(data)
            let downloadURL = try await storageRef.downloadURL()
            
            var updatedCategory = category
            updatedCategory.pdfURL = downloadURL.absoluteString
            
            let docRef = db.collection("PDFCategories").document(category.id)
            try await docRef.setData(from: updatedCategory)
            
            await updatePDFCategories(with: updatedCategory)
        } catch {
            print("Error uploading PDF: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func updatePDFCategories(with updatedCategory: PDFCategory) {
        if let index = pdfCategories.firstIndex(where: { $0.id == updatedCategory.id }) {
            pdfCategories[index] = updatedCategory
        } else {
            pdfCategories.append(updatedCategory)
        }
        updateUniqueCategories()
    }
    
    deinit {
        listener?.remove()
    }
}


