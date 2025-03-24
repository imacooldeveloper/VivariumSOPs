//
//  PDFSTorageManager.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
import Firebase
import FirebaseStorage
/// working

//class PDFStorageManager: ObservableObject {
//    static let shared = PDFStorageManager()
//    private let storage = Storage.storage()
//    private let db = Firestore.firestore()
//    
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0
//    
//    func uploadPDF(data: Data, path: String, filename: String, category: PDFCategory, completion: @escaping (Result<String, Error>) -> Void) {
//        isUploading = true
//        uploadProgress = 0
//        
//        let storageRef = storage.reference().child(path).child(filename)
//        
//        let uploadTask = storageRef.putData(data, metadata: nil) { (metadata, error) in
//            self.isUploading = false
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            storageRef.downloadURL { (url, error) in
//                if let error = error {
//                    completion(.failure(error))
//                } else if let urlString = url?.absoluteString {
//                    // Upload successful, now add to Firestore
//                    self.addPDFCategoryToFirestore(category: category, pdfURL: urlString) { result in
//                        switch result {
//                        case .success:
//                            completion(.success(urlString))
//                        case .failure(let error):
//                            completion(.failure(error))
//                        }
//                    }
//                }
//            }
//        }
//        
//        uploadTask.observe(.progress) { snapshot in
//            self.uploadProgress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
//        }
//    }
//    
//    private func addPDFCategoryToFirestore(category: PDFCategory, pdfURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        do {
//            var categoryData = try Firestore.Encoder().encode(category)
//            categoryData["pdfURL"] = pdfURL
//            
//            db.collection("PDFCategories").document(category.id).setData(categoryData) { error in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success(()))
//                }
//            }
//        } catch {
//            completion(.failure(error))
//        }
//    }
//}

// working before chatgpt
//class PDFStorageManager: ObservableObject {
//    static let shared = PDFStorageManager()
//    private let storage = Storage.storage()
//    private let db = Firestore.firestore()
//    
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0
//    
//    func uploadPDF(data: Data, category: PDFCategory, completion: @escaping (Result<String, Error>) -> Void) {
//        isUploading = true
//        uploadProgress = 0
//        
//        let path = "pdfs/\(category.nameOfCategory)/\(category.pdfName).pdf"
//        let storageRef = storage.reference().child(path)
//        
//        // Check if the file already exists
//        storageRef.getMetadata { (metadata, error) in
//            if metadata != nil {
//                // File exists, delete it first
//                storageRef.delete { error in
//                    if let error = error {
//                        completion(.failure(error))
//                    } else {
//                        self.uploadNewFile(data: data, storageRef: storageRef, category: category, completion: completion)
//                    }
//                }
//            } else {
//                // File doesn't exist, upload directly
//                self.uploadNewFile(data: data, storageRef: storageRef, category: category, completion: completion)
//            }
//        }
//    }
//    
//    private func uploadNewFile(data: Data, storageRef: StorageReference, category: PDFCategory, completion: @escaping (Result<String, Error>) -> Void) {
//        let uploadTask = storageRef.putData(data, metadata: nil) { (metadata, error) in
//            self.isUploading = false
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            storageRef.downloadURL { (url, error) in
//                if let error = error {
//                    completion(.failure(error))
//                } else if let urlString = url?.absoluteString {
//                    self.updatePDFCategoryInFirestore(category: category, pdfURL: urlString) { result in
//                        switch result {
//                        case .success:
//                            completion(.success(urlString))
//                        case .failure(let error):
//                            completion(.failure(error))
//                        }
//                    }
//                }
//            }
//        }
//        
//        uploadTask.observe(.progress) { snapshot in
//            self.uploadProgress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
//        }
//    }
//    
//    private func updatePDFCategoryInFirestore(category: PDFCategory, pdfURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        let categoryRef = db.collection("PDFCategories").document(category.id ?? "")
//        
//        categoryRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                // Document exists, update it
//                categoryRef.updateData([
//                    "nameOfCategory": category.nameOfCategory,
//                    "SOPForStaffTittle": category.SOPForStaffTittle,
//                    "pdfName": category.pdfName,
//                    "pdfURL": pdfURL
//                ]) { error in
//                    if let error = error {
//                        completion(.failure(error))
//                    } else {
//                        completion(.success(()))
//                    }
//                }
//            } else {
//                // Document doesn't exist, create a new one
//                do {
//                    var categoryData = try Firestore.Encoder().encode(category)
//                    categoryData["pdfURL"] = pdfURL
//                    
//                    categoryRef.setData(categoryData) { error in
//                        if let error = error {
//                            completion(.failure(error))
//                        } else {
//                            completion(.success(()))
//                        }
//                    }
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//}



import Firebase
import FirebaseStorage
import FirebaseFirestore
@MainActor


class PDFStorageManager: ObservableObject {
    static let shared = PDFStorageManager()
    private let storage = Storage.storage()
    private let db = Firestore.firestore() // Add Firestore reference
    
    @Published var isUploading = false
        @Published var uploadProgress: Double = 0
        
//        func uploadPDF(data: Data, category: PDFCategory) async throws -> String {
//            let folderPath = "pdfs/\(category.nameOfCategory)/\(category.SOPForStaffTittle)"
//            let filename = "\(category.pdfName).pdf"
//            let fullPath = "\(folderPath)/\(filename)"
//            
//            let storageRef = storage.reference().child(fullPath)
//            
//            await MainActor.run {
//                self.isUploading = true
//                self.uploadProgress = 0
//            }
//            
//            // Upload the file
//            let _ = try await storageRef.putDataAsync(data) { progress in
//                if let progress = progress {
//                    let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
//                    Task { @MainActor in
//                        self.uploadProgress = percentComplete
//                    }
//                }
//            }
//            
//            // Get the download URL
//            let downloadURL = try await storageRef.downloadURL()
//            
//            await MainActor.run {
//                self.isUploading = false
//                self.uploadProgress = 1.0
//            }
//            
//            return downloadURL.absoluteString
//        }
    @MainActor
       func uploadPDF(data: Data, category: PDFCategory) async throws -> String {
           let folderPath = "pdfs/\(category.organizationId)/\(category.nameOfCategory)/\(category.SOPForStaffTittle)"
           let filename = "\(category.pdfName).pdf"
           let fullPath = "\(folderPath)/\(filename)"
           
           let storageRef = storage.reference().child(fullPath)
           
           // Upload to Storage
           let _ = try await storageRef.putDataAsync(data)
           
           // Get the download URL
           let downloadURL = try await storageRef.downloadURL()
           
           // Create a new PDFCategory with the download URL
           var updatedCategory = category
           updatedCategory.pdfURL = downloadURL.absoluteString
           
           // Save to Firestore
           try await db.collection("PDFCategory")
               .document(category.id)
               .setData([
                   "id": category.id,
                   "nameOfCategory": category.nameOfCategory,
                   "SOPForStaffTittle": category.SOPForStaffTittle,
                   "pdfName": category.pdfName,
                   "pdfURL": downloadURL.absoluteString,
                   "organizationId": category.organizationId
               ])
           
           print("Successfully uploaded PDF to Storage and saved to Firestore")
           print("Document ID: \(category.id)")
           print("Download URL: \(downloadURL.absoluteString)")
           
           return downloadURL.absoluteString
       }
        func movePDF(from oldCategory: PDFCategory, to newCategory: PDFCategory) async throws -> String {
            guard let oldURL = URL(string: oldCategory.pdfURL ?? "") else {
                throw NSError(domain: "PDFStorageManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid old URL"])
            }
            
            let oldStorageRef = storage.reference(forURL: oldURL.absoluteString)
            let newFolderPath = "pdfs/\(newCategory.organizationId)/\(newCategory.nameOfCategory)/\(newCategory.SOPForStaffTittle)"
            let newFilename = "\(newCategory.pdfName).pdf"
            let newFullPath = "\(newFolderPath)/\(newFilename)"
            let newStorageRef = storage.reference().child(newFullPath)
            
            // Download the old file
            let data = try await oldStorageRef.data(maxSize: 100 * 1024 * 1024) // 100 MB max
            
            // Upload to the new location
            _ = try await newStorageRef.putDataAsync(data)
            
            // Delete the old file
            try await oldStorageRef.delete()
            
            // Get the new download URL
            let newDownloadURL = try await newStorageRef.downloadURL()
            
            return newDownloadURL.absoluteString
        }
}
