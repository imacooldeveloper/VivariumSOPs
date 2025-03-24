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
import FirebaseStorage
import SwiftUI


@MainActor
class PDFCategoryViewModel: ObservableObject {
    @Published private(set) var pdfCategories: [PDFCategory] = []
    @Published private(set) var sopCategories: [SOPCategory] = []
    @Published private(set) var uniqueCategories: [String] = []
    @Published private(set) var categories: [Category] = []
    @Published var isLoading = true
    @AppStorage("organizationId") private var organizationId: String = ""
    private var storage = Storage.storage()
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    
    private var filteredCache: [String: [PDFCategory]] = [:]
      
      func getFilteredPDFs(category: String, subcategory: String) -> [PDFCategory] {
          let cacheKey = "\(category)-\(subcategory)"
          if let cached = filteredCache[cacheKey] {
              return cached
          }
          
          let filtered = pdfCategories
              .filter { $0.nameOfCategory == category && $0.SOPForStaffTittle == subcategory }
              .sorted(by: { $0.pdfName < $1.pdfName })
          
          filteredCache[cacheKey] = filtered
          return filtered
      }
    private var subcategoryCache: [String: [String]] = [:] // Add this cache

    func getSubcategories(for category: String) -> [String] {
        // Check cache first
        if let cached = subcategoryCache[category] {
            return cached
        }
        
        let subcategories = Array(Set(pdfCategories
            .filter { $0.nameOfCategory == category }
            .map { $0.SOPForStaffTittle }))
            .sorted()
        
        // Store in cache
        subcategoryCache[category] = subcategories
        return subcategories
    }

    // Add this method to clear cache when needed
    func clearSubcategoryCache() {
        subcategoryCache.removeAll()
    }
    
    
    private let pageSize = 50 // Number of PDFs to load at once
        
        // Modify fetchPDFCategories to fetch only for specific category/subcategory
       
    func fetchPDFsForSubcategory(
        category: String,
        subcategory: String,
        startAfter: PDFCategory? = nil,
        limit: Int = 50
    ) async throws -> [PDFCategory] {
        var query = Firestore.firestore()
            .collection("PDFCategory")
            .whereField("organizationId", isEqualTo: organizationId)
            .whereField("nameOfCategory", isEqualTo: category)
            .whereField("SOPForStaffTittle", isEqualTo: subcategory)
            .order(by: "pdfName") // Add an order to enable pagination
            .limit(to: limit)
        
        // If we have a startAfter document, add it to the query
        if let lastDoc = startAfter {
            query = query.start(after: [lastDoc.pdfName])
        }
        
        let snapshot = try await query.getDocuments()
        
        let fetchedCategories = try snapshot.documents.compactMap { document in
            try document.data(as: PDFCategory.self)
        }
        
        print("Fetched \(fetchedCategories.count) PDFs for \(category)/\(subcategory)")
        
        return fetchedCategories
    }
    
    // Helper method to clear caches when needed
    func clearCaches() {
        filteredCache.removeAll()
    }
    
    // Update your existing deletePDF method to clear caches
//    func deletePDF(_ pdf: PDFCategory) async throws {
//        let id = pdf.id
//        
//        // Delete from Firestore
//        try await db.collection("PDFCategory").document(id).delete()
//        
//        // Delete the PDF file from Firebase Storage
//        if let pdfURL = pdf.pdfURL, let url = URL(string: pdfURL) {
//            let path = "pdfs/\(pdf.nameOfCategory)/\(pdf.SOPForStaffTittle)/\(pdf.pdfName).pdf"
//            let storageRef = storage.reference().child(path)
//            try await storageRef.delete()
//        }
//        
//        // Update local state and clear caches
//        await MainActor.run {
//            self.pdfCategories.removeAll { $0.id == id }
//            self.clearCaches()
//        }
//        
//        // Check if the category folder is empty and delete it if so
//        await self.deleteEmptyFolders(category: pdf.nameOfCategory, subcategory: pdf.SOPForStaffTittle)
//    }
//  
    
    func deletePDF(_ pdf: PDFCategory) async throws {
        let id = pdf.id
        
        // Store category information for page count update
        let category = pdf.nameOfCategory
        let subcategory = pdf.SOPForStaffTittle
        
        do {
            // Delete from Firestore
            try await db.collection("PDFCategory").document(id).delete()
            
            // Delete the PDF file from Firebase Storage
            if let pdfURL = pdf.pdfURL, let url = URL(string: pdfURL) {
                let path = "pdfs/\(category)/\(subcategory)/\(pdf.pdfName).pdf"
                let storageRef = storage.reference().child(path)
                try await storageRef.delete()
            }
            
            // Update the local array
            pdfCategories.removeAll { $0.id == id }
            
            // Update subcategory page count (decrement by 1)
            try await updateSOPCategoryPageCount(category: category, subcategory: subcategory, increment: -1)
            
            // Check if the category folder is empty and delete it if so
            //await deleteEmptyFolders(category: category, subcategory: subcategory)
            
            // Update cache
            clearCaches()
        } catch {
            print("Error deleting PDF: \(error.localizedDescription)")
            throw error
        }
    }

    ///
    ///
    ///
    ///
    init() {
        print("PDFCategoryViewModel initialized")
        Task {
            await fetchCategories()  // This will now properly fetch organization-specific categories
        }
    }
    
    
    func createOrUpdateSOPCategory(nameOfCategory: String, SOPForStaffTittle: String, pdfCount: Int) async throws {
          do {
              // Query for existing SOP category
              let categoryRef = db.collection("SOPCategory")
                  .whereField("nameOfCategory", isEqualTo: nameOfCategory)
                  .whereField("SOPForStaffTittle", isEqualTo: SOPForStaffTittle)
                  .whereField("organizationId", isEqualTo: organizationId)
              
              let snapshot = try await categoryRef.getDocuments()
              
              if let existingDoc = snapshot.documents.first {
                  // Update existing category
                  var sopCategory = try existingDoc.data(as: SOPCategory.self)
                  let currentPages = Int(sopCategory.sopPages ?? "0") ?? 0
                  let newPageCount = currentPages + pdfCount
                  sopCategory.sopPages = String(newPageCount)
                  
                  print("Updating existing SOP category: \(SOPForStaffTittle)")
                  print("Current pages: \(currentPages), Adding: \(pdfCount), New total: \(newPageCount)")
                  
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
                      sopPages: String(pdfCount),
                      organizationId: organizationId
                  )
                  
                  print("Creating new SOP category: \(SOPForStaffTittle) with \(pdfCount) pages")
                  
                  try await db.collection("SOPCategory").document(newCategory.id).setData(from: newCategory)
                  sopCategories.append(newCategory)
              }
              
              // Refresh the categories
              await fetchSOPCategories()
              
          } catch {
              print("Error creating/updating SOP category: \(error.localizedDescription)")
              throw error
          }
      }

      // Updated uploadAllPDFs function to handle page counting correctly
      @MainActor
      func uploadAllPDFs(
          selectedPDFs: [URL],
          selectedTemplates: [TempSOP],
          folder: String,
          title: String,
          onProgress: @escaping (Double, String) -> Void
      ) async throws {
          let totalFiles = selectedPDFs.count + selectedTemplates.count
          var filesCompleted = 0
          
          // Create or update SOPCategory first with correct page count
          try await createOrUpdateSOPCategory(
              nameOfCategory: folder,
              SOPForStaffTittle: title,
              pdfCount: totalFiles
          )
          
          // Upload regular PDFs
          for url in selectedPDFs {
              guard url.startAccessingSecurityScopedResource() else { continue }
              defer { url.stopAccessingSecurityScopedResource() }
              
              let data = try Data(contentsOf: url)
              let pdfName = url.deletingPathExtension().lastPathComponent
              
              onProgress(Double(filesCompleted) / Double(totalFiles), pdfName)
              
              let pdfCategory = PDFCategory(
                  id: UUID().uuidString,
                  nameOfCategory: folder,
                  SOPForStaffTittle: title,
                  pdfName: pdfName,
                  organizationId: organizationId
              )
              
              _ = try await uploadPDF(data: data, category: pdfCategory)
              filesCompleted += 1
          }
          
          // Upload template PDFs
          for template in selectedTemplates {
              onProgress(Double(filesCompleted) / Double(totalFiles), template.name)
              
              let storageRef = Storage.storage().reference(forURL: template.fileURL)
              let data = try await storageRef.data(maxSize: 50 * 1024 * 1024)
              
              let pdfCategory = PDFCategory(
                  id: UUID().uuidString,
                  nameOfCategory: folder,
                  SOPForStaffTittle: title,
                  pdfName: template.name,
                  organizationId: organizationId
              )
              
              _ = try await uploadPDF(data: data, category: pdfCategory)
              filesCompleted += 1
          }
          
          onProgress(1.0, "Complete")
      }
    
    func getCategoryList(for organizationId: String, title: String?) async throws -> [SOPCategory] {
        var query = db.collection("SOPCategory")
            .whereField("organizationId", isEqualTo: organizationId)
        
        if let title {
            query = query.whereField(SOPCategory.CodingKeys.nameOfCategory.rawValue, isEqualTo: title)
        }
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { document in
            try document.data(as: SOPCategory.self)
        }
    }
    
    func uploadSOPCategory(sopCategory: SOPCategory) async throws {
        print("Uploading SOP Category: \(sopCategory.SOPForStaffTittle)")
        try await CategoryManager.shared.uploadSOPCategory(room: sopCategory)
    }

    func addCategorywith(_ categoryTitle: String) async {
          do {
              let newCategory = Category(
                  id: UUID().uuidString,
                  categoryTitle: categoryTitle,
                  organizationId: organizationId
              )
              try await db.collection("categoryList").document(newCategory.id).setData(from: newCategory)
              
              self.categories.append(newCategory)
              
              print(newCategory)
          } catch {
              print("Error adding category: \(error.localizedDescription)")
          }
      }

    func addCategory(_ categoryTitle: String) async {
           do {
               let newCategory = Category(
                   id: UUID().uuidString,
                   categoryTitle: categoryTitle,
                   organizationId: organizationId
               )
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

    func deleteCategory(_ category: String) async throws {
        print("Starting category deletion process for: \(category)")
        
        // Call CategoryManager's deleteCategory method which handles all deletions including quizzes
        try await CategoryManager.shared.deleteCategory(category, organizationId: organizationId)
        
        // Update local state after successful deletion
        await MainActor.run {
            self.pdfCategories.removeAll { $0.nameOfCategory == category }
            self.updateUniqueCategories()
        }
        
        print("Category deletion completed: \(category)")
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
                   .whereField("organizationId", isEqualTo: organizationId) // Add organization filter
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
                       sopPages: String(incrementPageCount),
                       organizationId: organizationId  // Add organizationId
                   )
                   
                   try await db.collection("SOPCategory").document(newCategory.id).setData(from: newCategory)
                   sopCategories.append(newCategory)
               }
           } catch {
               print("Error creating/updating SOP category: \(error.localizedDescription)")
           }
       }
    
     func fetchCategories() async {
        isLoading = true
        do {
            // First, fetch categories from categoryList collection
            let categorySnapshot = try await db.collection("categoryList")
                .whereField("organizationId", isEqualTo: organizationId)
                .getDocuments()
            
            let categories = categorySnapshot.documents.compactMap { document -> String? in
                let data = document.data()
                return data["categoryTitle"] as? String
            }
            
            // Update uniqueCategories with organization-specific categories
            await MainActor.run {
                self.uniqueCategories = Array(Set(categories)).sorted()
            }
            
            // Then fetch PDFs for these categories
            await fetchPDFCategories()
            
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    

    @MainActor
    func fetchCategoriesIfNeeded() async {
            guard !pdfCategories.isEmpty else {
                await fetchPDFCategories()
                return
            }
        }

    private func fetchPDFCategories() async {
        do {
            let snapshot = try await db.collection("PDFCategory")
                .whereField("organizationId", isEqualTo: organizationId)
                .getDocuments()
            
            let fetchedCategories = try snapshot.documents.compactMap { document in
                try document.data(as: PDFCategory.self)
            }
            
            await MainActor.run {
                self.pdfCategories = fetchedCategories
                self.isLoading = false
            }
            
        } catch {
            print("Error fetching PDF categories: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    

    
//    func getSubcategories(for category: String) -> [String] {
//        let subcategories = Set(pdfCategories.filter { $0.nameOfCategory == category }.map { $0.SOPForStaffTittle })
//        return Array(subcategories).sorted()
//    }
    
    func filteredPDFs(category: String, subcategory: String) -> [PDFCategory] {
        pdfCategories.filter { $0.nameOfCategory == category && $0.SOPForStaffTittle == subcategory }
            .sorted(by: { $0.pdfName < $1.pdfName })
    }

//    @MainActor
//    func updatePDFCategory(_ category: PDFCategory) async throws {
//        do {
//            var updatedCategory = category // Create a mutable copy
//            
//            // Update Firestore
//            let categoryRef = db.collection("PDFCategory").document(category.id)
//            try await categoryRef.setData(from: updatedCategory, merge: true)
//            
//            // Update local array
//            if let index = pdfCategories.firstIndex(where: { $0.id == updatedCategory.id }) {
//                pdfCategories[index] = updatedCategory
//            }
//            
//            // Update Firebase Storage if the PDF file has changed
//            if let pdfURL = updatedCategory.pdfURL, let url = URL(string: pdfURL) {
//                let path = "pdfs/\(updatedCategory.nameOfCategory)/\(updatedCategory.SOPForStaffTittle)/\(updatedCategory.pdfName).pdf"
//                let storageRef = storage.reference().child(path)
//                
//                // Check if the file exists in Storage
//                do {
//                    _ = try await storageRef.downloadURL()
//                    // If we get here, the file exists, so we update it
//                    let (data, _) = try await URLSession.shared.data(from: url)
//                    _ = try await storageRef.putDataAsync(data)
//                    let newDownloadURL = try await storageRef.downloadURL()
//                    
//                    // Update Firestore with the new URL if it has changed
//                    if newDownloadURL.absoluteString != pdfURL {
//                        try await categoryRef.updateData(["pdfURL": newDownloadURL.absoluteString])
//                        updatedCategory.pdfURL = newDownloadURL.absoluteString
//                    }
//                } catch {
//                    // If the file doesn't exist, we create it
//                    let (data, _) = try await URLSession.shared.data(from: url)
//                    _ = try await storageRef.putDataAsync(data)
//                    let newDownloadURL = try await storageRef.downloadURL()
//                    try await categoryRef.updateData(["pdfURL": newDownloadURL.absoluteString])
//                    updatedCategory.pdfURL = newDownloadURL.absoluteString
//                }
//            }
//            
//            // Update local array again with potentially modified URL
//            if let index = pdfCategories.firstIndex(where: { $0.id == updatedCategory.id }) {
//                pdfCategories[index] = updatedCategory
//            }
//            
//            // Update unique categories
//            self.updateUniqueCategories()
//            
//        } catch {
//            print("Error updating PDF category: \(error.localizedDescription)")
//            throw error
//        }
//    }
//  
    
    @MainActor
    func updatePDFCategory(_ updatedCategory: PDFCategory) async throws {
        // Find the original category before the update
        let originalCategory = pdfCategories.first(where: { $0.id == updatedCategory.id })
        
        // Check if the PDF is being moved to a different subcategory
        let isMovingSubcategories = originalCategory != nil &&
            (originalCategory!.nameOfCategory != updatedCategory.nameOfCategory ||
             originalCategory!.SOPForStaffTittle != updatedCategory.SOPForStaffTittle)
        
        // Perform the standard update
        do {
            // Update in Firestore
            let categoryRef = db.collection("PDFCategory").document(updatedCategory.id)
            try await categoryRef.setData(from: updatedCategory, merge: true)
            
            // Update in local array
            if let index = pdfCategories.firstIndex(where: { $0.id == updatedCategory.id }) {
                pdfCategories[index] = updatedCategory
            } else {
                pdfCategories.append(updatedCategory)
            }
            
            // If the PDF was moved between subcategories, update the page counts
            if isMovingSubcategories && originalCategory != nil {
                try await updateSubcategoryPageCounts(
                    fromCategory: originalCategory!.nameOfCategory,
                    fromSubcategory: originalCategory!.SOPForStaffTittle,
                    toCategory: updatedCategory.nameOfCategory,
                    toSubcategory: updatedCategory.SOPForStaffTittle
                )
            }
            
            // Update unique categories
            updateUniqueCategories()
            
            // Clear caches
            subcategoryCache.removeAll()
            filteredCache.removeAll()
            
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
               // await self.deleteEmptyFolders(category: pdf.nameOfCategory, subcategory: pdf.SOPForStaffTittle)
            } catch {
                print("Error deleting PDF: \(error.localizedDescription)")
            }
        }
    }

    private func removePDFCategory(withID id: String) {
        pdfCategories.removeAll { $0.id == id }
        updateUniqueCategories()
    }
    
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
//    private func deleteEmptyFolders(category: String, subcategory: String) async {
//        let path = "pdfs/\(category)/\(subcategory)"
//        let storageRef = storage.reference().child(path)
//        
//        do {
//            let items = try await storageRef.listAll()
//            if items.items.isEmpty && items.prefixes.isEmpty {
//                // The folder is empty, so delete it
//                try await storageRef.delete()
//                print("Deleted empty subcategory folder: \(path)")
//                
//                // Check if the SOPCategory should be deleted (if page count is 0)
//                await checkAndDeleteEmptySOPCategory(category: category, subcategory: subcategory)
//                
//                // Check if the parent folder (category) is now empty
//                let parentRef = storage.reference().child("pdfs/\(category)")
//                let parentItems = try await parentRef.listAll()
//                if parentItems.items.isEmpty && parentItems.prefixes.isEmpty {
//                    try await parentRef.delete()
//                    print("Deleted empty category folder: pdfs/\(category)")
//                }
//            }
//        } catch {
//            print("Error checking/deleting empty folders: \(error.localizedDescription)")
//        }
//    }

    // Add this helper method to delete empty SOPCategory entries
    // Replace the checkAndEnsureSOPCategoryPageCount function with this corrected version

    private func checkAndEnsureSOPCategoryPageCount(category: String, subcategory: String) async {
        do {
            let query = db.collection("SOPCategory")
                .whereField("nameOfCategory", isEqualTo: category)
                .whereField("SOPForStaffTittle", isEqualTo: subcategory)
                .whereField("organizationId", isEqualTo: organizationId)
            
            let snapshot = try await query.getDocuments()
            
            for doc in snapshot.documents {
                if let sopCategory = try? doc.data(as: SOPCategory.self) {
                    // Count actual PDFs without using aggregation
                    let pdfQuery = db.collection("PDFCategory")
                        .whereField("nameOfCategory", isEqualTo: category)
                        .whereField("SOPForStaffTittle", isEqualTo: subcategory)
                        .whereField("organizationId", isEqualTo: organizationId)
                    
                    // Get all PDFs and count them manually
                    let pdfSnapshot = try await pdfQuery.getDocuments()
                    let pdfCount = pdfSnapshot.documents.count
                    
                    // Only update if the count doesn't match
                    let currentPages = Int(sopCategory.sopPages ?? "0") ?? 0
                    
                    if currentPages != pdfCount {
                        // Update to accurate count
                        var updatedCategory = sopCategory
                        updatedCategory.sopPages = String(pdfCount)
                        try await doc.reference.setData(from: updatedCategory)
                        
                        print("Corrected page count for \(category)/\(subcategory): \(currentPages) → \(pdfCount)")
                        
                        // Update local array
                        if let index = sopCategories.firstIndex(where: {
                            $0.nameOfCategory == category &&
                            $0.SOPForStaffTittle == subcategory
                        }) {
                            sopCategories[index].sopPages = String(pdfCount)
                        }
                    }
                }
            }
        } catch {
            print("Error checking SOPCategory page count: \(error.localizedDescription)")
        }
    }
    func uploadPDF(data: Data, category: PDFCategory) async throws -> String {
         print("Starting PDF upload for category: \(category.pdfName)")
         
         // Upload using PDFStorageManager
         let downloadURL = try await PDFStorageManager.shared.uploadPDF(data: data, category: category)
         
         // Fetch updated categories
         await self.fetchPDFCategories()
         
         return downloadURL
     }
    // Helper function to update unique categories
       private func updateUniqueCategories() {
           let categories = Set(pdfCategories.map { $0.nameOfCategory })
           uniqueCategories = Array(categories).sorted()
       }
   
    private func updatePDFCategories(with updatedCategory: PDFCategory) {
        if let index = pdfCategories.firstIndex(where: { $0.id == updatedCategory.id }) {
            pdfCategories[index] = updatedCategory
        } else {
            pdfCategories.append(updatedCategory)
        }
        updateUniqueCategories()
    }
    // deleteSubCategory
    
    enum DeleteSubcategoryError: LocalizedError {
        case firestoreError(Error)
        case storageError(Error)
        case noSubcategoryFound
        
        var errorDescription: String? {
            switch self {
            case .firestoreError(let error):
                return "Database error: \(error.localizedDescription)"
            case .storageError(let error):
                return "Storage error: \(error.localizedDescription)"
            case .noSubcategoryFound:
                return "Subcategory not found"
            }
        }
    }
    @MainActor
    func deleteSubcategory(category: String, subcategory: String) async throws {
        print("Starting deletion process for subcategory: \(subcategory) in category: \(category)")
        
        // Verify the subcategory exists first
        let sopQuery = db.collection("SOPCategory")
            .whereField("organizationId", isEqualTo: organizationId)
            .whereField("nameOfCategory", isEqualTo: category)
            .whereField("SOPForStaffTittle", isEqualTo: subcategory)
           
        
        let sopSnapshot = try await sopQuery.getDocuments()
        
        if sopSnapshot.documents.isEmpty {
            throw DeleteSubcategoryError.noSubcategoryFound
        }
        
        do {
            // 1. Get all PDFs in this subcategory
            let pdfQuery = db.collection("PDFCategory")
                .whereField("nameOfCategory", isEqualTo: category)
                .whereField("SOPForStaffTittle", isEqualTo: subcategory)
                .whereField("organizationId", isEqualTo: organizationId)
            
            let pdfsSnapshot = try await pdfQuery.getDocuments()
            print("Found \(pdfsSnapshot.documents.count) PDFs to delete")
            
            // 2. Get all quizzes associated with this subcategory
            let quizQuery = db.collection("Quiz")
                .whereField("quizCategory", isEqualTo: subcategory)
                .whereField("organizationId", isEqualTo: organizationId)
            
            let quizSnapshot = try await quizQuery.getDocuments()
            print("Found \(quizSnapshot.documents.count) quizzes to delete")
            
            // 3. Create a batch for Firestore operations
            var totalBatchOperations = 0
            var currentBatch = db.batch()
            
            // Firestore batches can handle at most 500 operations, so we need to handle this
            let MAX_BATCH_SIZE = 400
            
            // Helper function to commit the current batch and start a new one when needed
            func commitBatchIfNeeded() async throws {
                if totalBatchOperations >= MAX_BATCH_SIZE {
                    try await currentBatch.commit()
                    currentBatch = db.batch()
                    totalBatchOperations = 0
                }
            }
            
            // 4. Delete SOPCategory documents
            for doc in sopSnapshot.documents {
                currentBatch.deleteDocument(doc.reference)
                totalBatchOperations += 1
                try await commitBatchIfNeeded()
            }
            
            // 5. Delete all PDF documents
            var pdfStorageURLs: [URL] = []
            for doc in pdfsSnapshot.documents {
                if let pdf = try? doc.data(as: PDFCategory.self),
                   let urlString = pdf.pdfURL,
                   let url = URL(string: urlString) {
                    pdfStorageURLs.append(url)
                }
                currentBatch.deleteDocument(doc.reference)
                totalBatchOperations += 1
                try await commitBatchIfNeeded()
            }
            
            // 6. Delete quizzes and their subcollections
            for quizDoc in quizSnapshot.documents {
                // Handle questions subcollection
                let questionsSnapshot = try await quizDoc.reference.collection("Questions").getDocuments()
                for questionDoc in questionsSnapshot.documents {
                    currentBatch.deleteDocument(questionDoc.reference)
                    totalBatchOperations += 1
                    try await commitBatchIfNeeded()
                }
                
                // Delete the quiz document itself
                currentBatch.deleteDocument(quizDoc.reference)
                totalBatchOperations += 1
                try await commitBatchIfNeeded()
            }
            
            // 7. Commit any remaining operations
            if totalBatchOperations > 0 {
                try await currentBatch.commit()
            }
            
            // 8. Delete files from Firebase Storage
            let storage = Storage.storage()
            let folderPath = "pdfs/\(category)/\(subcategory)"
            let storageFolder = storage.reference().child(folderPath)
            
            do {
                // Delete all files in the subcategory folder
                let listResult = try await storageFolder.listAll()
                
                for item in listResult.items {
                    try await item.delete()
                    print("Deleted file: \(item.name) from storage")
                }
                
                // Delete the subcategory folder itself if empty
                if listResult.prefixes.isEmpty {
                    try await storageFolder.delete()
                    print("Deleted subcategory folder from storage")
                }
            } catch let storageError as NSError {
                // Only throw if it's not a "not found" error (which is fine since we're deleting)
                if storageError.domain != StorageErrorDomain ||
                   storageError.code != StorageErrorCode.objectNotFound.rawValue {
                    throw DeleteSubcategoryError.storageError(storageError)
                }
            }
            
            // 9. Update local data
            self.pdfCategories.removeAll {
                $0.nameOfCategory == category &&
                $0.SOPForStaffTittle == subcategory
            }
            
            self.sopCategories.removeAll {
                $0.nameOfCategory == category &&
                $0.SOPForStaffTittle == subcategory
            }
            
            // Clear caches
            self.subcategoryCache.removeAll()
            self.filteredCache.removeAll()
            
            print("Subcategory deletion completed: \(subcategory)")
        } catch {
            print("Error during subcategory deletion: \(error)")
            throw DeleteSubcategoryError.firestoreError(error)
        }
    }
    // Function to update page counts when a PDF is moved between subcategories
    @MainActor
    func updateSubcategoryPageCounts(fromCategory: String, fromSubcategory: String, toCategory: String, toSubcategory: String, pdfCount: Int = 1) async throws {
        print("Updating page counts - moving \(pdfCount) PDFs from \(fromCategory)/\(fromSubcategory) to \(toCategory)/\(toSubcategory)")
        
        // Decrement page count in the source subcategory
        try await updateSOPCategoryPageCount(
            category: fromCategory,
            subcategory: fromSubcategory,
            increment: -pdfCount
        )
        
        // Increment page count in the destination subcategory
        try await updateSOPCategoryPageCount(
            category: toCategory,
            subcategory: toSubcategory,
            increment: pdfCount
        )
        
        // Refresh SOPCategories to update UI
        await fetchSOPCategories()
    }

    
    
    // Helper function to update a single subcategory's page count
    private func updateSOPCategoryPageCount(category: String, subcategory: String, increment: Int) async throws {
        let query = db.collection("SOPCategory")
            .whereField("nameOfCategory", isEqualTo: category)
            .whereField("SOPForStaffTittle", isEqualTo: subcategory)
            .whereField("organizationId", isEqualTo: organizationId)
        
        let snapshot = try await query.getDocuments()
        
        if let document = snapshot.documents.first {
            let sopCategoryRef = document.reference
            var sopCategory = try document.data(as: SOPCategory.self)
            
            // Update the page count
            let currentPages = Int(sopCategory.sopPages ?? "0") ?? 0
            let newPageCount = max(0, currentPages + increment) // Ensure it doesn't go below 0
            sopCategory.sopPages = String(newPageCount)
            
            // Update Firestore
            try await sopCategoryRef.setData(from: sopCategory)
            
            print("Updated page count for \(category)/\(subcategory): \(currentPages) → \(newPageCount)")
            
            // Update local array if available
            if let index = sopCategories.firstIndex(where: {
                $0.nameOfCategory == category &&
                $0.SOPForStaffTittle == subcategory
            }) {
                sopCategories[index].sopPages = String(newPageCount)
            }
        } else {
            // If the subcategory doesn't exist and we're incrementing (adding pages),
            // we need to create it
            if increment > 0 {
                let newCategory = SOPCategory(
                    id: UUID().uuidString,
                    nameOfCategory: category,
                    SOPForStaffTittle: subcategory,
                    sopPages: String(increment),
                    organizationId: organizationId
                )
                
                try await db.collection("SOPCategory").document(newCategory.id).setData(from: newCategory)
                
                // Add to local array
                sopCategories.append(newCategory)
                
                print("Created new SOPCategory for \(category)/\(subcategory) with page count: \(increment)")
            } else {
                print("Warning: Attempted to decrement pages for non-existent SOPCategory: \(category)/\(subcategory)")
            }
        }
    }
    @MainActor
    func validateAllSubcategoryPageCounts() async {
        for category in uniqueCategories {
            let subcategories = getSubcategories(for: category)
            for subcategory in subcategories {
                await checkAndEnsureSOPCategoryPageCount(category: category, subcategory: subcategory)
            }
        }
    }
    deinit {
        listener?.remove()
    }
}
