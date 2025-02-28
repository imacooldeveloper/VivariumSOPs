//
//  CategoryManager.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
class CategoryManager {
    static let shared = CategoryManager()
    private let categoryCollection = Firestore.firestore().collection("categoryList")
    private let pdfCategoryCollection = Firestore.firestore().collection("PDFCategory")
    private let SOPCategoryCollection = Firestore.firestore().collection("SOPCategory")
    private let quizCollection = Firestore.firestore().collection("Quiz") // Added this line
    private func categoryDocuments(roomId: String) -> DocumentReference {
        categoryCollection.document(roomId)
    }
    // upload Category
    func uploadCategory(room: Categorys) async throws {
        try categoryDocuments(roomId: room.id).setData(from: room)
    }
    
    //    func getAllCategory() async throws -> [Categorys] {
    //        let snapshot = try await categoryCollection.getDocuments()
    //        var room: [Categorys] = []
    //
    //        for doc in snapshot.documents {
    //            let rooms = try doc.data(as: Categorys.self)
    //            room.append(rooms)
    //        }
    //        return room
    //    }
    
    func getAllCategory(for organizationId: String) async throws -> [Categorys] {
        let snapshot = try await categoryCollection
            .whereField("organizationId", isEqualTo: organizationId)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Categorys.self)
        }
    }
    // PDf Category
    
    private func pdfcategoryDocuments(roomId: String) -> DocumentReference {
        pdfCategoryCollection.document(roomId)
    }
    func uploadCategoryPDF(room: PDFCategory) async throws {
        try pdfcategoryDocuments(roomId: room.id).setData(from: room)
    }
    
    private func SOPCategoryDocuments(roomId: String) -> DocumentReference {
        SOPCategoryCollection.document(roomId)
    }
    
    // upload Category
    func uploadSOPCategory(room: SOPCategory) async throws {
        try SOPCategoryDocuments(roomId: room.id).setData(from: room)
    }
    
    private func getSOPCategoryListQuery()  -> Query {
        SOPCategoryCollection
        
    }
    
    func getAllSOPCategory() async throws -> [SOPCategory] {
        let snapshot = try await SOPCategoryCollection.getDocuments()
        var room: [SOPCategory] = []
        
        for doc in snapshot.documents {
            let rooms = try doc.data(as: SOPCategory.self)
            room.append(rooms)
        }
        return room
    }
    private func getCategoryList(title:String)-> Query {
        SOPCategoryCollection
        
            .whereField(SOPCategory.CodingKeys.nameOfCategory.rawValue, isEqualTo: title)
        
    }
    func getCategoryList(for organizationId: String, title: String?) async throws -> [SOPCategory] {
        var query = SOPCategoryCollection
            .whereField("organizationId", isEqualTo: organizationId)
        
        if let title {
            query = query.whereField(SOPCategory.CodingKeys.nameOfCategory.rawValue, isEqualTo: title)
        }
        
        return try await query.getDocumentsWithSnapshot(as: SOPCategory.self)
    }
    
    func getCategoryList(title: String?) async throws -> [SOPCategory]  {
        var query = getSOPCategoryListQuery()
        
        if let title{
            query = getCategoryList(title:title)
        }
        
        return try await query
            .getDocumentsWithSnapshot(as: SOPCategory.self)
    }
    
    // PDf Category
    
    
    
    func getAllCategoryPDF() async throws -> [PDFCategory] {
        let snapshot = try await pdfCategoryCollection.getDocuments()
        var room: [PDFCategory] = []
        
        for doc in snapshot.documents {
            let rooms = try doc.data(as: PDFCategory.self)
            room.append(rooms)
        }
        return room
    }
    
    
    private func getPDFCategoryListQuery()  -> Query {
        pdfCategoryCollection
        
    }
    
    private func getPDFCategoryList(title:String, nameOfPdf: String)-> Query {
        pdfCategoryCollection
        
            .whereField(PDFCategory.CodingKeys.SOPForStaffTittle.rawValue, isEqualTo: title)
        // .whereField(PDFCategory.CodingKeys.pdfName.rawValue, isEqualTo: nameOfPdf)
        
    }
    //    func getCategoryPDFList(title: String?,nameOfPdf: String?) async throws -> [PDFCategory]  {
    //        var query = getPDFCategoryListQuery()
    //
    //        if let title, let nameOfPdf{
    //            query = getPDFCategoryList(title:title, nameOfPdf: nameOfPdf)
    //        }
    //
    //        return try await query
    //            .getDocumentsWithSnapshot(as: PDFCategory.self)
    //    }
    
    
    
    func getCategoryPDFList(title: String?, nameOfPdf: String?, organizationId: String) async throws -> [PDFCategory] {
        // Start with the base query
        let query: Query = pdfCategoryCollection
        
        // Build query with filters
        let finalQuery = query.whereField("organizationId", isEqualTo: organizationId)
            .whereField("SOPForStaffTittle", isEqualTo: title)
        
        return try await finalQuery.getDocumentsWithSnapshot(as: PDFCategory.self)
    }
    private func deleteStorageContents(for category: String) async {
        let storage = Storage.storage()
        let pdfStorageRef = storage.reference().child("pdfs/\(category)")
        
        do {
            print("Checking storage for category: \(category)")
            let result = try await pdfStorageRef.listAll()
            
            if !result.prefixes.isEmpty || !result.items.isEmpty {
                print("Found storage content to delete")
                for prefix in result.prefixes {
                    let subItems = try await prefix.listAll()
                    for item in subItems.items {
                        try await item.delete()
                        print("Deleted file: \(item.fullPath)")
                    }
                    try await prefix.delete()
                    print("Deleted prefix: \(prefix.fullPath)")
                }
                try await pdfStorageRef.delete()
                print("Storage deletion completed")
            } else {
                print("No storage content found for category: \(category)")
            }
        } catch let error as NSError where error.domain == StorageErrorDomain {
            if error.code == StorageErrorCode.objectNotFound.rawValue {
                print("No storage found for category: \(category)")
            } else {
                print("Storage deletion error: \(error)")
            }
        } catch {
            print("Storage deletion error: \(error)")
        }
    }
    func deleteQuiz(_ quiz: Quiz) async throws {
           do {
               let quizRef = quizCollection.document(quiz.id)
               
               // 1. First delete all questions in the Questions subcollection
               print("Deleting questions for quiz: \(quiz.id)")
               let questionsSnapshot = try await quizRef.collection("Questions").getDocuments()
               
               // Delete each question document
               for questionDoc in questionsSnapshot.documents {
                   print("Deleting question: \(questionDoc.documentID)")
                   try await questionDoc.reference.delete()
               }
               
               // 2. Delete quiz assignments from users
               let usersRef = Firestore.firestore().collection("Users")
               let usersWithQuiz = try await usersRef
                   .whereField("quizScores", arrayContains: ["quizID": quiz.id])
                   .getDocuments()
               
               for userDoc in usersWithQuiz.documents {
                   print("Removing quiz \(quiz.id) from user \(userDoc.documentID)")
                   try await userDoc.reference.updateData([
                       "quizScores": FieldValue.arrayRemove([["quizID": quiz.id]])
                   ])
               }
               
               // 3. Finally delete the quiz document itself
               print("Deleting quiz document: \(quiz.id)")
               try await quizRef.delete()
               
               print("Successfully deleted quiz and all associated data")
           } catch {
               print("Error during quiz deletion: \(error)")
               throw error
           }
       }
    private func deleteAssociatedQuizzes(category: String, organizationId: String) async throws {
        print("Starting quiz deletion for category: \(category)")
        let quizManager = QuizManager.shared
        
        // 1. Get PDFs for this category and get their SOPForStaffTittle values
        let pdfDocs = try await pdfCategoryCollection
            .whereField("nameOfCategory", isEqualTo: category)
            .whereField("organizationId", isEqualTo: organizationId)
            .getDocuments()
            
        // Extract the subcategories (SOPForStaffTittle values)
        let subcategories = Set(pdfDocs.documents.compactMap { doc -> String? in
            if let pdf = try? doc.data(as: PDFCategory.self) {
                print("Found folder structure: \(category)/\(pdf.SOPForStaffTittle)")
                return pdf.SOPForStaffTittle
            }
            return nil
        })
        
      
        // 2. Get all quizzes in organization
        let allQuizzes = try await quizManager.getAllQuizzes(for: organizationId)
      
        
        // 3. Find quizzes where quizCategory matches any subcategory
        let quizzesToDelete = allQuizzes.filter { quiz in
            if subcategories.contains(quiz.quizCategory) {
             
                return true
            }
            return false
        }
        
        // 4. Delete the matching quizzes
        if !quizzesToDelete.isEmpty {
          
            for quiz in quizzesToDelete {
               
                try await quizManager.deleteQuiz(quiz)
            }
        } else {
         
            for quiz in allQuizzes {
              
            }
        }
    }
    func deleteCategory(_ category: String, organizationId: String) async throws {
        // Delete PDFCategory documents
        let pdfQuery = pdfCategoryCollection
            .whereField("nameOfCategory", isEqualTo: category)
            .whereField("organizationId", isEqualTo: organizationId)
        
        let pdfDocs = try await pdfQuery.getDocumentsWithSnapshot(as: PDFCategory.self)
        for doc in pdfDocs {
            print("Deleting PDFCategory: \(doc.id)")
            try await pdfCategoryCollection.document(doc.id).delete()
        }
        
        // Delete SOPCategory documents
        let sopQuery = SOPCategoryCollection
            .whereField("nameOfCategory", isEqualTo: category)
            .whereField("organizationId", isEqualTo: organizationId)
        
        let sopDocs = try await sopQuery.getDocumentsWithSnapshot(as: SOPCategory.self)
        for doc in sopDocs {
            print("Deleting SOPCategory: \(doc.id)")
            try await SOPCategoryCollection.document(doc.id).delete()
        }
        
        // Delete associated quizzes
        try await deleteAssociatedQuizzes(category: category, organizationId: organizationId)
        
        // Delete storage contents
        await deleteStorageContents(for: category)
        
        // Delete the category itself
        let categoryQuery = categoryCollection
            .whereField("categoryTitle", isEqualTo: category)
            .whereField("organizationId", isEqualTo: organizationId)
        
        let categoryDocs = try await categoryQuery.getDocumentsWithSnapshot(as: Categorys.self)
        for doc in categoryDocs {
            print("Deleting category document: \(doc.id)")
            try await categoryCollection.document(doc.id).delete()
        }
        func deleteEntireCategory(_ category: String, organizationId: String) async throws {
            print("Starting deletion for category: \(category), organizationId: \(organizationId)")
            
            // 1. Delete PDFs from Storage
            let storage = Storage.storage()
            let pdfStorageRef = storage.reference().child("pdfs/\(category)")
            
            do {
                print("Attempting to delete from Storage: pdfs/\(category)")
                let result = try await pdfStorageRef.listAll()
                print("Found \(result.prefixes.count) prefixes and \(result.items.count) items in storage")
                
                for prefix in result.prefixes {
                    print("Processing prefix: \(prefix.fullPath)")
                    let subItems = try await prefix.listAll()
                    for item in subItems.items {
                        print("Deleting item: \(item.fullPath)")
                        try await item.delete()
                    }
                    try await prefix.delete()
                }
                try await pdfStorageRef.delete()
                print("Storage deletion completed")
            } catch {
                print("Storage deletion error: \(error)")
            }
            
            // 2. Delete PDFCategory documents
            do {
                print("Querying PDFCategory documents")
                let pdfCategories = try await pdfCategoryCollection
                    .whereField("nameOfCategory", isEqualTo: category)
                    .whereField("organizationId", isEqualTo: organizationId)
                    .getDocuments()
                
                print("Found \(pdfCategories.documents.count) PDFCategory documents")
                for doc in pdfCategories.documents {
                    print("Deleting PDFCategory document: \(doc.documentID)")
                    try await pdfCategoryCollection.document(doc.documentID).delete()
                }
            } catch {
                print("Error deleting PDFCategory documents: \(error)")
                throw error
            }
            
            // 3. Delete SOPCategory documents
            do {
                print("Querying SOPCategory documents")
                let sopCategories = try await SOPCategoryCollection
                    .whereField("nameOfCategory", isEqualTo: category)
                    .whereField("organizationId", isEqualTo: organizationId)
                    .getDocuments()
                
                print("Found \(sopCategories.documents.count) SOPCategory documents")
                for doc in sopCategories.documents {
                    print("Deleting SOPCategory document: \(doc.documentID)")
                    try await SOPCategoryCollection.document(doc.documentID).delete()
                }
            } catch {
                print("Error deleting SOPCategory documents: \(error)")
                throw error
            }
            
            // 4. Delete associated quizzes
            do {
                print("Querying associated quizzes")
                let quizManager = QuizManager.shared
                let quizzes = try await quizManager.getQuizList(category: category)
                
                print("Found \(quizzes.count) associated quizzes")
                for quiz in quizzes {
                    print("Deleting quiz: \(quiz.id)")
                    try await quizManager.deleteQuiz(quiz)
                }
            } catch {
                print("Error deleting quizzes: \(error)")
                throw error
            }
            
            // 5. Delete the category itself
            do {
                print("Querying category documents")
                let categoryDocs = try await categoryCollection
                    .whereField("categoryTitle", isEqualTo: category)
                    .whereField("organizationId", isEqualTo: organizationId)
                    .getDocuments()
                
                print("Found \(categoryDocs.documents.count) category documents")
                for doc in categoryDocs.documents {
                    print("Deleting category document: \(doc.documentID)")
                    try await categoryCollection.document(doc.documentID).delete()
                }
            } catch {
                print("Error deleting category documents: \(error)")
                throw error
            }
            
            print("Category deletion completed successfully")
        }
        
    }
}
