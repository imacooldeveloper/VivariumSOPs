//
//  CategoryManager.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/28/24.
//

import Foundation
import FirebaseFirestore

class CategoryManager {
    static let shared = CategoryManager()
    private let categoryCollection = Firestore.firestore().collection("categoryList")
    private let pdfCategoryCollection = Firestore.firestore().collection("PDFCategory")
    private let SOPCategoryCollection = Firestore.firestore().collection("SOPCategory")
    private func categoryDocuments(roomId: String) -> DocumentReference {
        categoryCollection.document(roomId)
    }
    // upload Category
    func uploadCategory(room: Categorys) async throws {
        try categoryDocuments(roomId: room.id).setData(from: room)
    }
    
    func getAllCategory() async throws -> [Categorys] {
        let snapshot = try await categoryCollection.getDocuments()
        var room: [Categorys] = []
        
        for doc in snapshot.documents {
            let rooms = try doc.data(as: Categorys.self)
            room.append(rooms)
        }
        return room
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
    func getCategoryPDFList(title: String?,nameOfPdf: String?) async throws -> [PDFCategory]  {
        var query = getPDFCategoryListQuery()
        
        if let title, let nameOfPdf{
            query = getPDFCategoryList(title:title, nameOfPdf: nameOfPdf)
        }
        
        return try await query
            .getDocumentsWithSnapshot(as: PDFCategory.self)
    }
    
}

