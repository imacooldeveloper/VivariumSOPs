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


//@MainActor
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
@MainActor


/// this one is really working
//class PDFCategoryViewModel: ObservableObject {
//    @Published private(set) var pdfCategories: [PDFCategory] = []
//    @Published private(set) var uniqueCategories: [String] = []
//    @Published var isLoading = true
//    
//    private var storage = Storage.storage()
//    private var db = Firestore.firestore()
//    private var listener: ListenerRegistration?
//    
//    init() {
//        print("PDFCategoryViewModel initialized")
//        Task {
//            await fetchPDFCategories()
//        }
//    }
//    @MainActor
//    func fetchCategoriesIfNeeded() async {
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
//            let fetchedCategories = await withTaskGroup(of: PDFCategory?.self, returning: [PDFCategory].self) { group in
//                for document in snapshot.documents {
//                    group.addTask {
//                        return try? document.data(as: PDFCategory.self)
//                    }
//                }
//                var categories: [PDFCategory] = []
//                for await category in group {
//                    if let category = category {
//                        categories.append(category)
//                    }
//                }
//                return categories
//            }
//            
//            self.pdfCategories = fetchedCategories
//            self.updateUniqueCategories()
//            print("Fetched \(self.pdfCategories.count) categories")
//            self.isLoading = false
//        } catch {
//            print("Error fetching categories: \(error.localizedDescription)")
//            self.isLoading = false
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
//    func updatePDFCategory(_ category: PDFCategory) {
//        Task {
//            do {
//                let categoryRef = db.collection("PDFCategories").document(category.id)
//                try await categoryRef.setData(from: category, merge: true)
//            } catch {
//                print("Error updating PDF category: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func addPDFCategory(_ category: PDFCategory) {
//        Task {
//            do {
//                var newCategory = category
//                if newCategory.id.isEmpty {
//                    newCategory.id = db.collection("PDFCategories").document().documentID
//                }
//                try await db.collection("PDFCategories").document(newCategory.id).setData(from: newCategory)
//            } catch {
//                print("Error adding PDF category: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func deleteCategory(_ category: String) {
//        Task {
//            do {
//                let batch = db.batch()
//                let query = db.collection("PDFCategories").whereField("nameOfCategory", isEqualTo: category)
//                let snapshot = try await query.getDocuments()
//                
//                for document in snapshot.documents {
//                    batch.deleteDocument(document.reference)
//                }
//                
//                try await batch.commit()
//                
//                self.pdfCategories.removeAll { $0.nameOfCategory == category }
//                self.updateUniqueCategories()
//            } catch {
//                print("Error deleting category: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func deletePDF(_ pdf: PDFCategory) {
//        Task {
//            do {
//                let id = pdf.id
//                
//                // Delete the document from Firestore
//                try await db.collection("PDFCategories").document(id).delete()
//                
//                // Delete the PDF file from Firebase Storage
//                if let pdfURL = pdf.pdfURL, let url = URL(string: pdfURL) {
//                    let path = "pdfs/\(pdf.nameOfCategory)/\(pdf.SOPForStaffTittle)/\(pdf.pdfName).pdf"
//                    let storageRef = storage.reference().child(path)
//                    try await storageRef.delete()
//                }
//                
//                // Update the local array
//                self.removePDFCategory(withID: id)
//                
//                // Check if the category folder is empty and delete it if so
//                await self.deleteEmptyFolders(category: pdf.nameOfCategory, subcategory: pdf.SOPForStaffTittle)
//            } catch {
//                print("Error deleting PDF: \(error.localizedDescription)")
//            }
//        }
//    }
//
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
//    func uploadPDF(data: Data, category: PDFCategory) {
//        Task {
//            do {
//                let path = "pdfs/\(category.nameOfCategory)/\(category.SOPForStaffTittle)/\(category.pdfName).pdf"
//                let storageRef = storage.reference().child(path)
//                
//                let _ = try await storageRef.putDataAsync(data)
//                let downloadURL = try await storageRef.downloadURL()
//                
//                var updatedCategory = category
//                updatedCategory.pdfURL = downloadURL.absoluteString
//                
//                let docRef = db.collection("PDFCategories").document(category.id)
//                try await docRef.setData(from: updatedCategory)
//                
//                self.updatePDFCategories(with: updatedCategory)
//            } catch {
//                print("Error uploading PDF: \(error.localizedDescription)")
//            }
//        }
//    }
//
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
    @Published private(set) var sopCategories: [SOPCategory] = []
    @Published private(set) var uniqueCategories: [String] = []
    @Published private(set) var categories: [Category] = []
    @Published var isLoading = true
    
    private var storage = Storage.storage()
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        print("PDFCategoryViewModel initialized")
        Task {
            await fetchPDFCategories()
            await fetchSOPCategories()
            await fetchCategoriesonHome()
        }
    }
    func fetchCategories() async {
           do {
               let snapshot = try await db.collection("categoryList").getDocuments()
               let fetchedCategories = snapshot.documents.compactMap { document -> Category? in
                   try? document.data(as: Category.self)
               }
               self.categories = fetchedCategories
               
               print(self.categories)
           } catch {
               print("Error fetching categories: \(error.localizedDescription)")
           }
       }
// this adds a new category when the user creates a new tittle
       func addCategorywith(_ categoryTitle: String) async {
           do {
               let newCategory = Category(id: UUID().uuidString, categoryTitle: categoryTitle)
               try await db.collection("categoryList").document(newCategory.id).setData(from: newCategory)
               
               
               self.categories.append(newCategory)
               
               print(newCategory)
           } catch {
               print("Error adding category: \(error.localizedDescription)")
           }
       }

    
    func addCategory(_ categoryTitle: String) async {
            do {
                let newCategory = Category(id: UUID().uuidString, categoryTitle: categoryTitle)
                try await db.collection("categoryList").document(newCategory.id).setData(from: newCategory)
                
                await MainActor.run {
                    self.categories.append(newCategory)
                    if !self.uniqueCategories.contains(categoryTitle) {
                        self.uniqueCategories.append(categoryTitle)
                    }
                }
                
                // Refresh the categories after adding a new one
                await fetchCategories()
            } catch {
                print("Error adding category: \(error.localizedDescription)")
            }
        }
    
    func fetchCategoriesonHome() async {
          do {
              let snapshot = try await db.collection("categoryList").getDocuments()
              let fetchedCategories = snapshot.documents.compactMap { document -> Category? in
                  try? document.data(as: Category.self)
              }
              self.categories = fetchedCategories
              self.uniqueCategories = Array(Set(fetchedCategories.map { $0.categoryTitle })).sorted()
              print(self.uniqueCategories)
          } catch {
              print("Error fetching categories: \(error.localizedDescription)")
          }
      }
    
       func updateCategory(_ category: Category) async {
           do {
               try await db.collection("categoryList").document(category.id).setData(from: category)
               if let index = categories.firstIndex(where: { $0.id == category.id }) {
                   self.categories[index] = category
               }
           } catch {
               print("Error updating category: \(error.localizedDescription)")
           }
       }

       func deleteCategory(_ category: Category) async {
           do {
               try await db.collection("categoryList").document(category.id).delete()
               self.categories.removeAll { $0.id == category.id }
           } catch {
               print("Error deleting category: \(error.localizedDescription)")
           }
       }

    private func fetchSOPCategories() async {
        print("Fetching SOP categories...")
        do {
            let snapshot = try await db.collection("SOPCategory").getDocuments()
            let fetchedCategories = snapshot.documents.compactMap { document -> SOPCategory? in
                try? document.data(as: SOPCategory.self)
            }
            await MainActor.run {
                self.sopCategories = fetchedCategories
                print("Fetched \(self.sopCategories.count) SOP categories")
            }
        } catch {
            print("Error fetching SOP categories: \(error.localizedDescription)")
        }
    }
    
    func createOrUpdateSOPCategory(nameOfCategory: String, SOPForStaffTittle: String, incrementPageCount: Int) async {
        do {
            let categoryRef = db.collection("SOPCategory")
                .whereField("nameOfCategory", isEqualTo: nameOfCategory)
                .whereField("SOPForStaffTittle", isEqualTo: SOPForStaffTittle)
            let snapshot = try await categoryRef.getDocuments()
            
            if let existingDoc = snapshot.documents.first {
                // Update existing category
                var sopCategory = try existingDoc.data(as: SOPCategory.self)
                let currentPages = Int(sopCategory.sopPages ?? "0") ?? 0
                sopCategory.sopPages = String(currentPages + incrementPageCount)
                
                try await db.collection("SOPCategory").document(existingDoc.documentID).setData(from: sopCategory)
                
                if let index = sopCategories.firstIndex(where: { $0.id == existingDoc.documentID }) {
                    sopCategories[index] = sopCategory
                }
            } else {
                // Create new category
                let newCategory = SOPCategory(
                    id: UUID().uuidString,
                    nameOfCategory: nameOfCategory,
                    SOPForStaffTittle: SOPForStaffTittle,
                    sopPages: String(incrementPageCount)
                )
                
                try await db.collection("SOPCategory").document(newCategory.id).setData(from: newCategory)
                sopCategories.append(newCategory)
            }
        } catch {
            print("Error creating/updating SOP category: \(error.localizedDescription)")
        }
    }
    @MainActor
    func fetchCategoriesIfNeeded() async {
        Task {
            await fetchCategories()
        }
    }
    
    private func fetchPDFCategories() async {
        print("Fetching PDF categories...")
        isLoading = true
        
        do {
            let snapshot = try await db.collection("PDFCategory").getDocuments()
            let fetchedCategories = await withTaskGroup(of: PDFCategory?.self, returning: [PDFCategory].self) { group in
                for document in snapshot.documents {
                    group.addTask {
                        return try? document.data(as: PDFCategory.self)
                    }
                }
                var categories: [PDFCategory] = []
                for await category in group {
                    if let category = category {
                        categories.append(category)
                    }
                }
                return categories
            }
            
            self.pdfCategories = fetchedCategories
            self.updateUniqueCategories()
            print("Fetched \(self.pdfCategories.count) categories")
            self.isLoading = false
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            self.isLoading = false
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
    
//    func updatePDFCategory(_ category: PDFCategory) {
//        Task {
//            do {
//                let categoryRef = db.collection("PDFCategory").document(category.id)
//                try await categoryRef.setData(from: category, merge: true)
//            } catch {
//                print("Error updating PDF category: \(error.localizedDescription)")
//            }
//        }
//    }
    
    @MainActor
    func updatePDFCategory(_ category: PDFCategory) async throws {
        do {
            var updatedCategory = category // Create a mutable copy
            
            // Update Firestore
            let categoryRef = db.collection("PDFCategory").document(category.id)
            try await categoryRef.setData(from: updatedCategory, merge: true)
            
            // Update local array
            if let index = pdfCategories.firstIndex(where: { $0.id == updatedCategory.id }) {
                pdfCategories[index] = updatedCategory
            }
            
            // Update Firebase Storage if the PDF file has changed
            if let pdfURL = updatedCategory.pdfURL, let url = URL(string: pdfURL) {
                let path = "pdfs/\(updatedCategory.nameOfCategory)/\(updatedCategory.SOPForStaffTittle)/\(updatedCategory.pdfName).pdf"
                let storageRef = storage.reference().child(path)
                
                // Check if the file exists in Storage
                do {
                    _ = try await storageRef.downloadURL()
                    // If we get here, the file exists, so we update it
                    let (data, _) = try await URLSession.shared.data(from: url)
                    _ = try await storageRef.putDataAsync(data)
                    let newDownloadURL = try await storageRef.downloadURL()
                    
                    // Update Firestore with the new URL if it has changed
                    if newDownloadURL.absoluteString != pdfURL {
                        try await categoryRef.updateData(["pdfURL": newDownloadURL.absoluteString])
                        updatedCategory.pdfURL = newDownloadURL.absoluteString
                    }
                } catch {
                    // If the file doesn't exist, we create it
                    let (data, _) = try await URLSession.shared.data(from: url)
                    _ = try await storageRef.putDataAsync(data)
                    let newDownloadURL = try await storageRef.downloadURL()
                    try await categoryRef.updateData(["pdfURL": newDownloadURL.absoluteString])
                    updatedCategory.pdfURL = newDownloadURL.absoluteString
                }
            }
            
            // Update local array again with potentially modified URL
            if let index = pdfCategories.firstIndex(where: { $0.id == updatedCategory.id }) {
                pdfCategories[index] = updatedCategory
            }
            
            // Update unique categories
            self.updateUniqueCategories()
            
        } catch {
            print("Error updating PDF category: \(error.localizedDescription)")
            throw error
        }
    }
    func addPDFCategory(_ category: PDFCategory) {
        Task {
            do {
                var newCategory = category
                if newCategory.id.isEmpty {
                    newCategory.id = db.collection("PDFCategory").document().documentID
                }
                try await db.collection("PDFCategory").document(newCategory.id).setData(from: newCategory)
            } catch {
                print("Error adding PDF category: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteCategory(_ category: String) {
        Task {
            do {
                let batch = db.batch()
                let query = db.collection("PDFCategory").whereField("nameOfCategory", isEqualTo: category)
                let snapshot = try await query.getDocuments()
                
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }
                
                try await batch.commit()
                
                self.pdfCategories.removeAll { $0.nameOfCategory == category }
                self.updateUniqueCategories()
            } catch {
                print("Error deleting category: \(error.localizedDescription)")
            }
        }
    }
    
    func deletePDF(_ pdf: PDFCategory) {
        Task {
            do {
                let id = pdf.id
                
                // Delete the document from Firestore
                try await db.collection("PDFCategory").document(id).delete()
                
                // Delete the PDF file from Firebase Storage
                if let pdfURL = pdf.pdfURL, let url = URL(string: pdfURL) {
                    let path = "pdfs/\(pdf.nameOfCategory)/\(pdf.SOPForStaffTittle)/\(pdf.pdfName).pdf"
                    let storageRef = storage.reference().child(path)
                    try await storageRef.delete()
                }
                
                // Update the local array
                self.removePDFCategory(withID: id)
                
                // Check if the category folder is empty and delete it if so
                await self.deleteEmptyFolders(category: pdf.nameOfCategory, subcategory: pdf.SOPForStaffTittle)
            } catch {
                print("Error deleting PDF: \(error.localizedDescription)")
            }
        }
    }

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
    
    func uploadPDF(data: Data, category: PDFCategory) async throws {
        let path = "pdfs/\(category.nameOfCategory)/\(category.SOPForStaffTittle)/\(category.pdfName).pdf"
        let storageRef = storage.reference().child(path)
        
        let _ = try await storageRef.putDataAsync(data)
        let downloadURL = try await storageRef.downloadURL()
        
        var updatedCategory = category
        updatedCategory.pdfURL = downloadURL.absoluteString
        
        let docRef = db.collection("PDFCategory").document(category.id)
        try await docRef.setData(from: updatedCategory)
        
        self.updatePDFCategories(with: updatedCategory)
        
        // Create or update SOPCategory, incrementing the page count by 1
        // Create or update SOPCategory, incrementing the page count by 1
          await createOrUpdateSOPCategory(
              nameOfCategory: category.nameOfCategory,
              SOPForStaffTittle: category.SOPForStaffTittle,
              incrementPageCount: 1
          )
        
        if !self.categories.contains(where: { $0.categoryTitle == category.nameOfCategory }) {
                   await addCategory(category.nameOfCategory)
               }

    }
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
