//
//  Querry.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//


import FirebaseFirestore
import FirebaseFirestoreSwift
extension Query {
    
//    func getDocumentss<T: Codable>(as type: T.Type) async throws -> [T] {
//        let snapshot = try await self.getDocuments()
//
//        return try snapshot.documents.map({ documents in
//         try  documents.data(as: T.self)
//
//        })
//
//    }
    
    func getDocumentss<T: Codable>(as type: T.Type) async throws -> T {
        try await getDocumentsWithSnapshot(as: T.self) as! T
        
    }
    
    func getDocumentsWithSnapshot<T: Codable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await self.getDocuments()
        
        let product = try snapshot.documents.map({ documents in
         try  documents.data(as: T.self)
            
        })
        return product
    }
    
    func start(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        
        if let lastDocument{
            return self.start(afterDocument: lastDocument)
        } else {
            return self
        }
    }
}
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
