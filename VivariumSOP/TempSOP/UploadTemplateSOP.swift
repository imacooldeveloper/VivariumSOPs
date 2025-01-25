//
//  UploadTemplateSOP.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/23/25.
//

import SwiftUI
import FirebaseStorage
import Firebase
import FirebaseFirestore

// TemplateSOPUploadView.swift
// TemplateSOPUploadView.swift
//struct TemplateSOPUploadView: View {
//    @StateObject private var viewModel = TemplateSOPUploadViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showingFilePicker = false
//    @State private var selectedPDFURL: URL?
//    @State private var category = ""
//    @State private var subcategory = ""
//    @State private var description = ""
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Template Details")) {
//                    TextField("Category", text: $category)
//                    TextField("Subcategory", text: $subcategory)
//                    TextField("Description", text: $description)
//                }
//                
//                Section(header: Text("PDF File")) {
//                    if let url = selectedPDFURL {
//                        Text(url.lastPathComponent)
//                            .foregroundColor(.blue)
//                    }
//                    
//                    Button(action: {
//                        showingFilePicker = true
//                    }) {
//                        Text("Select PDF")
//                    }
//                }
//                
//                Section {
//                    Button(action: uploadTemplate) {
//                        if viewModel.isUploading {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle())
//                        } else {
//                            Text("Upload Template")
//                        }
//                    }
//                    .disabled(viewModel.isUploading || selectedPDFURL == nil || category.isEmpty || subcategory.isEmpty)
//                }
//                
//                if viewModel.isUploading {
//                    Section {
//                        ProgressView(value: viewModel.uploadProgress) {
//                            Text("Uploading... \(Int(viewModel.uploadProgress * 100))%")
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Add Template SOP")
//            .navigationBarItems(trailing: Button("Done") {
//                presentationMode.wrappedValue.dismiss()
//            })
//            .fileImporter(
//                isPresented: $showingFilePicker,
//                allowedContentTypes: [.pdf],
//                allowsMultipleSelection: false
//            ) { result in
//                switch result {
//                case .success(let urls):
//                    selectedPDFURL = urls.first
//                case .failure(let error):
//                    alertMessage = "Error selecting PDF: \(error.localizedDescription)"
//                    showAlert = true
//                }
//            }
//            .alert("Upload Status", isPresented: $showAlert) {
//                Button("OK", role: .cancel) { }
//            } message: {
//                Text(alertMessage)
//            }
//        }
//    }
//    
//    private func uploadTemplate() {
//        guard let url = selectedPDFURL else { return }
//        
//        Task {
//            do {
//                try await viewModel.uploadTemplate(
//                    pdfURL: url,
//                    category: category,
//                    subcategory: subcategory,
//                    description: description
//                )
//                await MainActor.run {
//                    alertMessage = "Template uploaded successfully"
//                    showAlert = true
//                    // Reset form
//                    selectedPDFURL = nil
//                    category = ""
//                    subcategory = ""
//                    description = ""
//                }
//            } catch {
//                await MainActor.run {
//                    alertMessage = "Upload failed: \(error.localizedDescription)"
//                    showAlert = true
//                }
//            }
//        }
//    }
//}

 //TemplateSOPUploadViewModel.swift
//@MainActor
//class TemplateSOPUploadViewModel: ObservableObject {
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0
//    
//    private let storage = Storage.storage()
//    private let db = Firestore.firestore()
//    
////    func uploadTemplate(pdfURL: URL, category: String, subcategory: String, description: String) async throws {
////        isUploading = true
////        uploadProgress = 0
////        
////        do {
////            // 1. Upload PDF to Firebase Storage
////            let data = try Data(contentsOf: pdfURL)
////            let filename = pdfURL.lastPathComponent
////            let storagePath = "templates/\(category)/\(filename)"
////            let storageRef = storage.reference().child(storagePath)
////            
////            let metadata = StorageMetadata()
////            metadata.contentType = "application/pdf"
////            
////            // Upload with progress monitoring
////            // Upload with progress monitoring
////            let uploadTask = storageRef.putData(data, metadata: metadata)
////            
////            // Monitor upload progress
////            uploadTask.observe(.progress) { [weak self] snapshot in
////                guard let percentComplete = snapshot.progress?.fractionCompleted else { return }
////                Task { @MainActor in
////                    self?.uploadProgress = percentComplete
////                }
////            }
////            
////            // Wait for upload to complete
////            _ = try await uploadTask.snapshot
////            
////            // 2. Get download URL
////            let downloadURL = try await storageRef.downloadURL()
////            
////            // 3. Create Firestore document
////            let tempSOP = TempSOP(
////                id: UUID().uuidString,
////                name: filename.replacingOccurrences(of: ".pdf", with: ""),
////                category: category,
////                subcategory: subcategory,
////                fileURL: downloadURL.absoluteString,
////                previewURL: nil,
////                description: description
////            )
////            
////            try await db.collection("TempSOPs").document(tempSOP.id).setData(from: tempSOP)
////            
////            isUploading = false
////            uploadProgress = 1.0
////        } catch {
////            isUploading = false
////            uploadProgress = 0
////            throw error
////        }
////    }
//   
//    
//    func uploadTemplate(pdfURL: URL, category: String, subcategory: String, description: String) async throws {
//            isUploading = true
//            uploadProgress = 0
//            
//            do {
//                // 1. Get the PDF data
//                guard pdfURL.startAccessingSecurityScopedResource() else {
//                    throw NSError(domain: "TemplateUpload", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access PDF file"])
//                }
//                defer { pdfURL.stopAccessingSecurityScopedResource() }
//                
//                let data = try Data(contentsOf: pdfURL)
//                let filename = pdfURL.lastPathComponent
//                
//                // 2. Create a unique storage path
//                let uniqueID = UUID().uuidString
//                let storagePath = "templates/\(uniqueID)-\(filename)"
//                let storageRef = storage.reference().child(storagePath)
//                
//                // 3. Set metadata
//                let metadata = StorageMetadata()
//                metadata.contentType = "application/pdf"
//                
//                // 4. Upload with progress monitoring
//                let uploadTask = storageRef.putData(data, metadata: metadata)
//                
//                // Monitor progress
//                _ = uploadTask.observe(.progress) { [weak self] snapshot in
//                    if let percentComplete = snapshot.progress?.fractionCompleted {
//                        Task { @MainActor in
//                            self?.uploadProgress = percentComplete
//                        }
//                    }
//                }
//                
//                // Wait for upload to complete
//                let snapshot = try await uploadTask.snapshot
//                
//                // Get the download URL
//                let downloadURL = try await snapshot.reference.downloadURL()
//                
//                // 5. Create Firestore document
//                let tempSOP = TempSOP(
//                    id: uniqueID,
//                    name: filename.replacingOccurrences(of: ".pdf", with: ""),
//                    category: category,
//                    subcategory: subcategory,
//                    fileURL: downloadURL.absoluteString,
//                    previewURL: nil,
//                    description: description
//                )
//                
//                // 6. Save to Firestore
//                try await db.collection("TempSOPs").document(tempSOP.id).setData(from: tempSOP)
//                
//                isUploading = false
//                uploadProgress = 1.0
//                
//                print("Successfully uploaded template: \(filename)")
//                print("Storage path: \(storagePath)")
//                print("Download URL: \(downloadURL.absoluteString)")
//                
//            } catch {
//                isUploading = false
//                uploadProgress = 0
//                print("Upload failed with error: \(error.localizedDescription)")
//                throw error
//            }
//        }
//    private func withProgress<T>(
//        _ progressHandler: @escaping (Double) -> Void,
//        operation: () async throws -> T
//    ) async throws -> T {
//        let progressTask = Task { @MainActor in
//            while !Task.isCancelled {
//                progressHandler(uploadProgress)
//                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
//            }
//        }
//        
//        defer { progressTask.cancel() }
//        return try await operation()
//    }
//}
//@MainActor
//class TemplateSOPUploadViewModel: ObservableObject {
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0
//    
//    // Store upload task in a way that's safe to access from any context
//    private let uploadTaskHolder = UploadTaskHolder()
//    private let storage = Storage.storage()
//    private let db = Firestore.firestore()
//    
//    // Separate class to hold the upload task that can be accessed from any context
//    private class UploadTaskHolder {
//        private var task: StorageUploadTask?
//        let lock = NSLock()
//        
//        func set(_ task: StorageUploadTask?) {
//            lock.lock()
//            defer { lock.unlock() }
//            self.task = task
//        }
//        
//        func cancel() {
//            lock.lock()
//            defer { lock.unlock() }
//            task?.cancel()
//            task = nil
//        }
//    }
//    
//    private func sanitizeFilename(_ filename: String) -> String {
//        // Remove special characters and spaces
//        let sanitized = filename
//            .replacingOccurrences(of: " ", with: "_")
//            .replacingOccurrences(of: "(", with: "")
//            .replacingOccurrences(of: ")", with: "")
//            .replacingOccurrences(of: "[", with: "")
//            .replacingOccurrences(of: "]", with: "")
//        
//        // Remove any other special characters
//        return sanitized.components(separatedBy: .alphanumerics.union(CharacterSet(charactersIn: ".-_")).inverted).joined()
//    }
//    
//    func uploadTemplate(pdfURL: URL, category: String, subcategory: String, description: String) async throws {
//        // Cancel any existing upload
//        uploadTaskHolder.cancel()
//        
//        isUploading = true
//        uploadProgress = 0
//        
//        do {
//            // 1. Get the PDF data
//            guard pdfURL.startAccessingSecurityScopedResource() else {
//                throw NSError(domain: "TemplateUpload", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access PDF file"])
//            }
//            defer { pdfURL.stopAccessingSecurityScopedResource() }
//            
//            let data = try Data(contentsOf: pdfURL)
//            let originalFilename = pdfURL.lastPathComponent
//            let sanitizedFilename = sanitizeFilename(originalFilename)
//            
//            // 2. Create a unique storage path
//            let uniqueID = UUID().uuidString
//            let storagePath = "templates/\(category)/\(uniqueID)-\(sanitizedFilename)"
//            let storageRef = storage.reference().child(storagePath)
//            
//            // 3. Set metadata
//            let metadata = StorageMetadata()
//            metadata.contentType = "application/pdf"
//            metadata.customMetadata = [
//                "originalFilename": originalFilename,
//                "category": category,
//                "subcategory": subcategory
//            ]
//            
//            // 4. Create and store the upload task
//            let uploadTask = storageRef.putData(data, metadata: metadata)
//            uploadTaskHolder.set(uploadTask)
//            
//            // Monitor progress
//            _ = uploadTask.observe(.progress) { [weak self] snapshot in
//                if let percentComplete = snapshot.progress?.fractionCompleted {
//                    Task { @MainActor in
//                        self?.uploadProgress = percentComplete
//                    }
//                }
//            }
//            
//            // Wait for upload to complete
//            let snapshot = try await uploadTask.snapshot
//            
//            // Get the download URL
//            let downloadURL = try await snapshot.reference.downloadURL()
//            
//            // 5. Create Firestore document
//            let tempSOP = TempSOP(
//                id: uniqueID,
//                name: originalFilename.replacingOccurrences(of: ".pdf", with: ""),
//                category: category,
//                subcategory: subcategory,
//                fileURL: downloadURL.absoluteString,
//                previewURL: nil,
//                description: description
//            )
//            
//            // 6. Save to Firestore
//            try await db.collection("TempSOPs").document(tempSOP.id).setData(from: tempSOP)
//            
//            isUploading = false
//            uploadProgress = 1.0
//            uploadTaskHolder.set(nil)
//            
//            print("Successfully uploaded template: \(originalFilename)")
//            print("Storage path: \(storagePath)")
//            print("Download URL: \(downloadURL.absoluteString)")
//            
//        } catch {
//            isUploading = false
//            uploadProgress = 0
//            uploadTaskHolder.set(nil)
//            print("Upload failed with error: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    deinit {
//        uploadTaskHolder.cancel()
//    }
//}


// TempSOP.swift - Update the model
struct TempSOP: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let subcategory: String
    let fileURL: String
    let previewURL: String?
    let description: String
    let organizationId: String // Add organization ID
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case subcategory
        case fileURL
        case previewURL
        case description
        case organizationId
    }
}

//@MainActor
//class TemplateSOPUploadViewModel: ObservableObject {
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0
//    private let uploadTaskHolder = UploadTaskHolder()
//    private let storage = Storage.storage()
//    private let db = Firestore.firestore()
//    @AppStorage("organizationId") private var organizationId: String = ""
//    
//    // ... keep existing UploadTaskHolder class and sanitizeFilename method ...
//    private class UploadTaskHolder {
//        private var task: StorageUploadTask?
//        let lock = NSLock()
//        
//        func set(_ task: StorageUploadTask?) {
//            lock.lock()
//            defer { lock.unlock() }
//            self.task = task
//        }
//        
//        func cancel() {
//            lock.lock()
//            defer { lock.unlock() }
//            task?.cancel()
//            task = nil
//        }
//    }
//    
//    private func sanitizeFilename(_ filename: String) -> String {
//        // Remove special characters and spaces
//        let sanitized = filename
//            .replacingOccurrences(of: " ", with: "_")
//            .replacingOccurrences(of: "(", with: "")
//            .replacingOccurrences(of: ")", with: "")
//            .replacingOccurrences(of: "[", with: "")
//            .replacingOccurrences(of: "]", with: "")
//        
//        // Remove any other special characters
//        return sanitized.components(separatedBy: .alphanumerics.union(CharacterSet(charactersIn: ".-_")).inverted).joined()
//    }
//    func uploadTemplate(pdfURL: URL, category: String, subcategory: String, description: String) async throws {
//        uploadTaskHolder.cancel()
//        isUploading = true
//        uploadProgress = 0
//        
//        do {
//            guard pdfURL.startAccessingSecurityScopedResource() else {
//                throw NSError(domain: "TemplateUpload", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access PDF file"])
//            }
//            defer { pdfURL.stopAccessingSecurityScopedResource() }
//            
//            let data = try Data(contentsOf: pdfURL)
//            let originalFilename = pdfURL.lastPathComponent
//            let sanitizedFilename = sanitizeFilename(originalFilename)
//            let uniqueID = UUID().uuidString
//            
//            // Update storage path to include organization
//            let storagePath = "templates/\(organizationId)/\(category)/\(uniqueID)-\(sanitizedFilename)"
//            let storageRef = storage.reference().child(storagePath)
//            
//            let metadata = StorageMetadata()
//            metadata.contentType = "application/pdf"
//            metadata.customMetadata = [
//                "originalFilename": originalFilename,
//                "category": category,
//                "subcategory": subcategory,
//                "organizationId": organizationId
//            ]
//            
//            let uploadTask = storageRef.putData(data, metadata: metadata)
//            uploadTaskHolder.set(uploadTask)
//            
//            // Monitor progress
//            _ = uploadTask.observe(.progress) { [weak self] snapshot in
//                if let percentComplete = snapshot.progress?.fractionCompleted {
//                    Task { @MainActor in
//                        self?.uploadProgress = percentComplete
//                    }
//                }
//            }
//            
//            let snapshot = try await uploadTask.snapshot
//            let downloadURL = try await snapshot.reference.downloadURL()
//            
//            // Create the template document
//            let tempSOP = TempSOP(
//                id: uniqueID,
//                name: originalFilename.replacingOccurrences(of: ".pdf", with: ""),
//                category: category,
//                subcategory: subcategory,
//                fileURL: downloadURL.absoluteString,
//                previewURL: nil,
//                description: description,
//                organizationId: organizationId
//            )
//            
//            // Save to Firestore in organization's collection
//            try await db.collection("Organizations")
//                .document(organizationId)
//                .collection("TempSOPs")
//                .document(tempSOP.id)
//                .setData(from: tempSOP)
//            
//            isUploading = false
//            uploadProgress = 1.0
//            uploadTaskHolder.set(nil)
//            
//            print("Successfully uploaded template: \(originalFilename)")
//            print("Storage path: \(storagePath)")
//            print("Download URL: \(downloadURL.absoluteString)")
//            
//        } catch {
//            isUploading = false
//            uploadProgress = 0
//            uploadTaskHolder.set(nil)
//            print("Upload failed with error: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    func fetchTemplateSOPs() async throws -> [TempSOP] {
//        let snapshot = try await db.collection("Organizations")
//            .document(organizationId)
//            .collection("TempSOPs")
//            .getDocuments()
//            
//        return snapshot.documents.compactMap { document in
//            try? document.data(as: TempSOP.self)
//        }
//    }
//    
//    deinit {
//        uploadTaskHolder.cancel()
//    }
//}

///
// Helper extension for the existing TempSOPManager.swift
extension TempSOPManager {
    @MainActor
    func uploadTemplateSOP(_ sop: TempSOP) async throws {
        try await db.collection("TempSOPs").document(sop.id).setData(from: sop)
    }
    
    @MainActor
    func deleteTemplateSOP(_ sop: TempSOP) async throws {
        // Delete from Storage
        if let fileURL = URL(string: sop.fileURL) {
            let storageRef = storage.reference(forURL: fileURL.absoluteString)
            try await storageRef.delete()
        }
        
        // Delete from Firestore
        try await db.collection("TempSOPs").document(sop.id).delete()
    }
}


import SwiftUI
import Combine

@MainActor
class TempPDFViewModel: ObservableObject {
    @Published var tempPDFs: [TempPDF] = []
    @Published var isLoading = false
    @AppStorage("organizationId") private var organizationId: String = ""

    func fetchTempPDFs() async {
        isLoading = true
        do {
            tempPDFs = try await TempPDFManager.shared.fetchAvailableTempPDFs(organizationId: organizationId)
        } catch {
            print("Error fetching Temp PDFs: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func uploadTempPDF(_ tempPDF: TempPDF, data: Data) async throws {
        let downloadURL = try await TempPDFManager.shared.uploadTempPDF(
            data: data,
            organizationId: tempPDF.organizationId,
            category: tempPDF.category,
            subcategory: tempPDF.subcategory,
            filename: tempPDF.filename
        )
        try await TempPDFManager.shared.saveTempPDFMetadata(
            organizationId: tempPDF.organizationId,
            category: tempPDF.category,
            subcategory: tempPDF.subcategory,
            filename: tempPDF.filename,
            downloadURL: downloadURL
        )
    }
}

// TempPDFUploadView.swift
import SwiftUI

struct TempPDFUploadView: View {
    @StateObject private var viewModel = TempPDFViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTempPDF: TempPDF?
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading PDFs...")
                } else if viewModel.tempPDFs.isEmpty {
                    Text("No available PDFs to display.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }else {
                    List(viewModel.tempPDFs) { tempPDF in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tempPDF.filename)
                                    .font(.headline)
                                Text("Category: \(tempPDF.category)")
                                    .font(.subheadline)
                                Text("Subcategory: \(tempPDF.subcategory)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Upload") {
                                selectedTempPDF = tempPDF
                                Task { await uploadTempPDF(tempPDF) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Available PDFs")
            .onAppear {
                Task { await viewModel.fetchTempPDFs() }
            }
            .alert("Upload Status", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func uploadTempPDF(_ tempPDF: TempPDF) async {
        guard let fileURL = URL(string: tempPDF.fileURL),
              let data = try? Data(contentsOf: fileURL) else {
            alertMessage = "Failed to load PDF data."
            showAlert = true
            return
        }

        isUploading = true
        do {
            try await viewModel.uploadTempPDF(tempPDF, data: data)
            alertMessage = "PDF uploaded successfully."
        } catch {
            alertMessage = "Upload failed: \(error.localizedDescription)"
        }
        isUploading = false
        showAlert = true
    }
}



//@MainActor
//class TemplateSOPUploadViewModel: ObservableObject {
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0
//    private let storage = Storage.storage()
//    private let db = Firestore.firestore()
//    @AppStorage("organizationId") private var organizationId: String = ""
//    
//    func uploadTemplate(pdfURL: URL, category: String, subcategory: String, description: String) async throws {
//        if isUploading {
//            print("Upload already in progress. Aborting new upload.")
//            return
//        }
//        
//        isUploading = true
//        uploadProgress = 0
//        
//        do {
//            print("Starting upload for file: \(pdfURL.lastPathComponent)")
//            
//            // Access PDF data
//            guard pdfURL.startAccessingSecurityScopedResource() else {
//                throw NSError(domain: "TemplateUpload", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access PDF file"])
//            }
//            defer { pdfURL.stopAccessingSecurityScopedResource() }
//            
//            let data = try Data(contentsOf: pdfURL)
//            print("Successfully loaded data for file: \(pdfURL.lastPathComponent)")
//            
//            let filename = pdfURL.lastPathComponent
//            let uniqueID = UUID().uuidString
//            let storagePath = "templates/\(organizationId)/\(category)/\(uniqueID)-\(filename)"
//            print("Generated storage path: \(storagePath)")
//            
//            let storageRef = storage.reference().child(storagePath)
//            
//            // Upload to Firebase Storage
//            let metadata = StorageMetadata()
//            metadata.contentType = "application/pdf"
//            let uploadTask = storageRef.putData(data, metadata: metadata)
//            
//            print("Starting upload task...")
//            
//            // Monitor upload progress
//            _ = uploadTask.observe(.progress) { [weak self] snapshot in
//                if let percentComplete = snapshot.progress?.fractionCompleted {
//                    Task { @MainActor in
//                        self?.uploadProgress = percentComplete
//                        print("Upload progress: \(Int(percentComplete * 100))%")
//                    }
//                }
//            }
//            
//            let snapshot = try await uploadTask.snapshot
//            print("Upload completed successfully. Snapshot: \(snapshot)")
//            
//            let downloadURL = try await snapshot.reference.downloadURL()
//            print("Download URL retrieved: \(downloadURL)")
//            
//            // Save metadata to Firestore
//            let tempSOP = TempSOP(
//                id: uniqueID,
//                name: filename.replacingOccurrences(of: ".pdf", with: ""),
//                category: category,
//                subcategory: subcategory,
//                fileURL: downloadURL.absoluteString,
//                previewURL: nil,
//                description: description,
//                organizationId: organizationId
//            )
//            
//            print("Saving metadata to Firestore for document ID: \(tempSOP.id)")
//            
//            try await db.collection("Organizations")
//                .document(organizationId)
//                .collection("TempSOPs")
//                .document(tempSOP.id)
//                .setData(from: tempSOP)
//            
//            print("Metadata saved successfully to Firestore.")
//            
//            isUploading = false
//            uploadProgress = 1.0
//        } catch {
//            isUploading = false
//            uploadProgress = 0
//            print("Error during upload: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    
//    
//    
//    func uploadPDF(
//        data: Data,
//        category: String,
//        subcategory: String,
//        filename: String,
//        description: String
//    ) async throws {
//        if isUploading {
//            print("Upload already in progress. Aborting new upload.")
//            return
//        }
//        
//        isUploading = true
//        uploadProgress = 0
//        
//        do {
//            print("Starting upload for file: \(filename)")
//            
//            // Generate a unique storage path
//            let uniqueID = UUID().uuidString
//            let storagePath = "templates/\(organizationId)/\(category)/\(uniqueID)-\(filename)"
//            print("Generated storage path: \(storagePath)")
//            
//            // Create Firebase Storage reference
//            let storageRef = storage.reference().child(storagePath)
//            
//            // Upload file to Firebase Storage
//            let metadata = StorageMetadata()
//            metadata.contentType = "application/pdf"
//            let uploadTask = storageRef.putData(data, metadata: metadata)
//            
//            print("Starting upload task...")
//            
//            // Monitor upload progress
//            _ = uploadTask.observe(.progress) { [weak self] snapshot in
//                if let percentComplete = snapshot.progress?.fractionCompleted {
//                    Task { @MainActor in
//                        self?.uploadProgress = percentComplete
//                        print("Upload progress: \(Int(percentComplete * 100))%")
//                    }
//                }
//            }
//            
//            // Wait for upload to complete
//            let snapshot = try await uploadTask.snapshot
//            print("Upload completed successfully. Snapshot: \(snapshot)")
//            
//            // Retrieve the download URL
//            let downloadURL = try await snapshot.reference.downloadURL()
//            print("Download URL retrieved: \(downloadURL)")
//            
//            // Save metadata to Firestore
//            let tempSOP = TempSOP(
//                id: uniqueID,
//                name: filename.replacingOccurrences(of: ".pdf", with: ""),
//                category: category,
//                subcategory: subcategory,
//                fileURL: downloadURL.absoluteString,
//                previewURL: nil,
//                description: description,
//                organizationId: organizationId
//            )
//            
//            print("Saving metadata to Firestore for document ID: \(tempSOP.id)")
//            
//            try await db.collection("Organizations")
//                .document(organizationId)
//                .collection("TempSOPs")
//                .document(tempSOP.id)
//                .setData(from: tempSOP)
//            
//            print("Metadata saved successfully to Firestore.")
//            
//            isUploading = false
//            uploadProgress = 1.0
//        } catch {
//            isUploading = false
//            uploadProgress = 0
//            print("Error during upload: \(error.localizedDescription)")
//            throw error
//        }
//    }
//}
////
//@MainActor
//class TemplateSOPUploadViewModel: ObservableObject {
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0
//    private let storage = Storage.storage()
//    private let db = Firestore.firestore()
//    @AppStorage("organizationId") private var organizationId: String = ""
//    private func uploadSinglePDF(_ pdfURL: URL, category: String, subcategory: String) async throws {
//        guard pdfURL.startAccessingSecurityScopedResource() else { return }
//        defer { pdfURL.stopAccessingSecurityScopedResource() }
//
//        let data = try Data(contentsOf: pdfURL)
//        let filename = sanitizeFilename(pdfURL.deletingPathExtension().lastPathComponent)
//        let uniqueID = UUID().uuidString
//        let storagePath = "templates/\(organizationId)/\(category)/\(uniqueID)-\(filename)"
//        let storageRef = storage.reference().child(storagePath)
//
//        // Upload to Firebase Storage
//        let metadata = StorageMetadata()
//        metadata.contentType = "application/pdf"
//        let uploadTask = storageRef.putData(data, metadata: metadata)
//        let snapshot = try await uploadTask.snapshot
//
//        // Fetch download URL
//        let downloadURL = try await fetchDownloadURL(storageRef: storageRef)
//        print("File uploaded successfully: \(downloadURL)")
//
//        // Save metadata to Firestore
//        let tempSOP = TempSOP(
//            id: uniqueID,
//            name: filename,
//            category: category,
//            subcategory: subcategory,
//            fileURL: downloadURL.absoluteString,
//            previewURL: nil,
//            description: "\(subcategory) - \(filename)",
//            organizationId: organizationId
//        )
//
//        try await db.collection("TempSOPs")
//            .document(tempSOP.id)
//            .setData(from: tempSOP)
//    }
//
//    @MainActor
//    func uploadTemplateSOPs(pdfs: [URL], category: String, subcategory: String) async throws {
//        if isUploading {
//            print("An upload is already in progress. Aborting duplicate call.")
//            return
//        }
//
//        isUploading = true
//        uploadProgress = 0
//
//        // Remove duplicates
//        let uniquePDFs = Array(Set(pdfs))
//        if uniquePDFs.count != pdfs.count {
//            print("Duplicate files detected. Uploading only unique files.")
//        }
//
//        for (index, pdfURL) in uniquePDFs.enumerated() {
//            try await uploadSinglePDF(pdfURL, category: category, subcategory: subcategory)
//            uploadProgress = Double(index + 1) / Double(uniquePDFs.count)
//        }
//
//        isUploading = false
//        print("All PDFs uploaded successfully")
//    }
//
//    func sanitizeFilename(_ filename: String) -> String {
//        return filename
//            .replacingOccurrences(of: " ", with: "_")
//            .replacingOccurrences(of: "(", with: "")
//            .replacingOccurrences(of: ")", with: "")
//            .replacingOccurrences(of: "%", with: "")
//            .replacingOccurrences(of: "&", with: "and")
//    }
//    
//    func fetchDownloadURL(storageRef: StorageReference) async throws -> URL {
//        for attempt in 1...3 {
//            do {
//                return try await storageRef.downloadURL()
//            } catch {
//                print("Attempt \(attempt): Retrying download URL fetch...")
//                try await Task.sleep(nanoseconds: 1_000_000_000) // 1-second delay
//            }
//        }
//        throw NSError(domain: "DownloadURL", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch download URL after retries"])
//    }
//    
//    
//    private func uploadPDFs() {
//        Task {
//            do {
//                isUploading = true
//                uploadProgress = 0
//
//                for (index, url) in selectedPDFs.enumerated() {
//                    guard url.startAccessingSecurityScopedResource() else {
//                        print("Failed to access the resource.")
//                        continue
//                    }
//                    defer { url.stopAccessingSecurityScopedResource() }
//
//                    let data = try Data(contentsOf: url)
//                    let filename = url.deletingPathExtension().lastPathComponent
//                    let uniqueID = UUID().uuidString
//                    let storagePath = "templates/\(organizationId)/\(selectedFolder)/\(uniqueID)-\(filename).pdf"
//
//                    // Upload to Firebase Storage
//                    let storageRef = Storage.storage().reference().child(storagePath)
//                    let metadata = StorageMetadata()
//                    metadata.contentType = "application/pdf"
//
//                    await MainActor.run {
//                        currentUploadingPDF = filename
//                    }
//
//                    print("Uploading PDF: \(filename)")
//
//                    // Upload the file
//                    let uploadTask = storageRef.putData(data, metadata: metadata)
//                    let snapshot = try await uploadTask.snapshot
//                    let downloadURL = try await snapshot.reference.downloadURL()
//
//                    print("Successfully uploaded PDF: \(filename)")
//                    print("Download URL: \(downloadURL)")
//
//                    // Save TempSOP to Firestore
//                    let tempSOP = TempSOP(
//                        id: uniqueID,
//                        name: filename,
//                        category: selectedFolder,
//                        subcategory: sopForStaffTitle,
//                        fileURL: downloadURL.absoluteString,
//                        previewURL: nil,
//                        description: sopForStaffTitle,
//                        organizationId: organizationId
//                    )
//
//                    try await Firestore.firestore()
//                        .collection("TempSOPs")
//                        .document(tempSOP.id)
//                        .setData(from: tempSOP)
//
//                    // Update progress
//                    await MainActor.run {
//                        uploadProgress = Double(index + 1) / Double(selectedPDFs.count)
//                    }
//                }
//
//                await MainActor.run {
//                    isUploading = false
//                    showAlert(title: "Success", message: "All PDFs uploaded successfully", isSuccess: true)
//                }
//            } catch {
//                print("Error during upload: \(error.localizedDescription)")
//                await MainActor.run {
//                    isUploading = false
//                    showAlert(title: "Error", message: "Error uploading PDFs: \(error.localizedDescription)", isSuccess: false)
//                }
//            }
//        }
//    }
//
//}
//struct TemplateSOPUploadView: View {
//    @StateObject private var viewModel = TemplateSOPUploadViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedPDFs: [URL] = []
//    @State private var showFileImporter = false
//    @State private var selectedFolder = "Husbandry" // Default folder
//    @State private var sopForStaffTitle = "Standard Husbandry"
//    @State private var isUploading = false
//    @State private var showAlert = false
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var uploadProgress: Double = 0
//    @State private var currentUploadingPDF = ""
//    @AppStorage("organizationId") private var organizationId: String = ""
//
//    let folders = ["Husbandry", "Vet Services"]
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Picker("Select Folder", selection: $selectedFolder) {
//                    ForEach(folders, id: \.self) { folder in
//                        Text(folder).tag(folder)
//                    }
//                }
//
//                TextField("SOP Title", text: $sopForStaffTitle)
//                    .padding()
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 5)
//                            .stroke(sopForStaffTitle.isEmpty ? Color.red : Color.clear, lineWidth: 1)
//                    )
//
//                Section(header: Text("Selected PDFs")) {
//                    ForEach(selectedPDFs, id: \.self) { url in
//                        Text(url.lastPathComponent)
//                    }
//                    .onDelete(perform: deletePDFs)
//                }
//
//                Button("Select PDFs") {
//                    showFileImporter = true
//                }
//
//                Button("Upload PDFs") {
//                    uploadPDFs()
//                }
//                .disabled(selectedPDFs.isEmpty || sopForStaffTitle.isEmpty)
//
//                if isUploading {
//                    ProgressView("Uploading...", value: uploadProgress, total: 1.0)
//                }
//            }
//            .navigationTitle("Upload Template SOP")
//            .navigationBarItems(trailing: Button("Done") {
//                presentationMode.wrappedValue.dismiss()
//            })
//            .fileImporter(
//                isPresented: $showFileImporter,
//                allowedContentTypes: [.pdf],
//                allowsMultipleSelection: true
//            ) { result in
//                handleFileImport(result)
//            }
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text(alertTitle),
//                      message: Text(alertMessage),
//                      dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//
//    private func handleFileImport(_ result: Result<[URL], Error>) {
//        switch result {
//        case .success(let urls):
//            selectedPDFs.append(contentsOf: urls)
//        case .failure(let error):
//            showAlert(title: "Error", message: "Error selecting PDFs: \(error.localizedDescription)")
//        }
//    }
//
//    private func deletePDFs(at offsets: IndexSet) {
//        selectedPDFs.remove(atOffsets: offsets)
//    }
//
//    private func uploadPDFs() {
//        isUploading = true
//        uploadProgress = 0
//
//        Task {
//               for pdfURL in selectedPDFs {
//                   do {
//                       guard pdfURL.startAccessingSecurityScopedResource() else {
//                           print("Failed to access resource: \(pdfURL)")
//                           continue
//                       }
//                       defer { pdfURL.stopAccessingSecurityScopedResource() }
//
//                       let data = try Data(contentsOf: pdfURL)
//                       let filename = pdfURL.lastPathComponent
//
//                       try await viewModel.uploadTemplateSOPs(
//                        pdfs: selectedPDFs,
//                        category: selectedFolder,
//                        subcategory: sopForStaffTitle
//                    )
//                       print("All PDFs uploaded successfully")
//                   } catch {
//                       print("Error uploading PDF: \(error.localizedDescription)")
//                   }
//               }
//           }
//    }
//
//    private func showAlert(title: String, message: String) {
//        alertTitle = title
//        alertMessage = message
//        showAlert = true
//    }
//}


///
///
///
//struct TemplateSOPUploadView: View {
//    @StateObject private var viewModel = TemplateSOPUploadViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedPDFs: [URL] = []
//    @State private var showFileImporter = false
//    @State private var selectedFolder = "Husbandry" // Default folder
//    @State private var sopForStaffTitle = "Standard Husbandry"
//    @State private var showAlert = false
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var uploadProgress: Double = 0
//    @AppStorage("organizationId") private var organizationId: String = ""
//
//    let folders = ["Husbandry", "Vet Services"]
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Picker("Select Folder", selection: $selectedFolder) {
//                    ForEach(folders, id: \.self) { folder in
//                        Text(folder).tag(folder)
//                    }
//                }
//
//                TextField("SOP Title", text: $sopForStaffTitle)
//                    .padding()
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 5)
//                            .stroke(sopForStaffTitle.isEmpty ? Color.red : Color.clear, lineWidth: 1)
//                    )
//
//                Section(header: Text("Selected PDFs")) {
//                    ForEach(selectedPDFs, id: \.self) { url in
//                        Text(url.lastPathComponent)
//                    }
//                    .onDelete(perform: deletePDFs)
//                }
//
//                Button("Select PDFs") {
//                    showFileImporter = true
//                }
//
//                Button("Upload PDFs") {
//                    uploadPDFs()
//                }
//                .disabled(selectedPDFs.isEmpty || sopForStaffTitle.isEmpty)
//
//                if viewModel.isUploading {
//                    ProgressView("Uploading...", value: viewModel.uploadProgress, total: 1.0)
//                }
//            }
//            .navigationTitle("Upload Template SOP")
//            .navigationBarItems(trailing: Button("Done") {
//                presentationMode.wrappedValue.dismiss()
//            })
//            .fileImporter(
//                isPresented: $showFileImporter,
//                allowedContentTypes: [.pdf],
//                allowsMultipleSelection: true
//            ) { result in
//                handleFileImport(result)
//            }
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text(alertTitle),
//                      message: Text(alertMessage),
//                      dismissButton: .default(Text("OK")))
//            }
//        }
//    }
//
//    private func handleFileImport(_ result: Result<[URL], Error>) {
//        switch result {
//        case .success(let urls):
//            selectedPDFs.append(contentsOf: urls)
//        case .failure(let error):
//            showAlert(title: "Error", message: "Error selecting PDFs: \(error.localizedDescription)")
//        }
//    }
//
//    private func deletePDFs(at offsets: IndexSet) {
//        selectedPDFs.remove(atOffsets: offsets)
//    }
//
//    private func uploadPDFs() {
//        Task {
//            do {
//                try await viewModel.uploadTemplateSOPs(
//                    pdfs: selectedPDFs,
//                    category: selectedFolder,
//                    subcategory: sopForStaffTitle
//                )
//                showAlert(title: "Success", message: "All PDFs uploaded successfully")
//            } catch {
//                showAlert(title: "Error", message: "Error uploading PDFs: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    private func showAlert(title: String, message: String) {
//        alertTitle = title
//        alertMessage = message
//        showAlert = true
//    }
//}
//@MainActor
//class TemplateSOPUploadViewModel: ObservableObject {
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0
//    private let storage = Storage.storage()
//    private let db = Firestore.firestore()
//    @AppStorage("organizationId") private var organizationId: String = ""
//
//    func uploadTemplateSOPs(pdfs: [URL], category: String, subcategory: String) async throws {
//        if isUploading {
//            print("Upload already in progress. Aborting duplicate execution.")
//            return
//        }
//
//        isUploading = true
//        uploadProgress = 0
//
//        let uniquePDFs = Array(Set(pdfs)) // Avoid duplicates
//
//        for (index, pdfURL) in uniquePDFs.enumerated() {
//            try await uploadSinglePDF(pdfURL, category: category, subcategory: subcategory)
//            uploadProgress = Double(index + 1) / Double(uniquePDFs.count)
//        }
//
//        isUploading = false
//        print("All PDFs uploaded successfully")
//    }
//
//    private func uploadSinglePDF(_ pdfURL: URL, category: String, subcategory: String) async throws {
//        guard pdfURL.startAccessingSecurityScopedResource() else { return }
//        defer { pdfURL.stopAccessingSecurityScopedResource() }
//
//        let data = try Data(contentsOf: pdfURL)
//        let filename = sanitizeFilename(pdfURL.deletingPathExtension().lastPathComponent)
//        let uniqueID = UUID().uuidString
//        let storagePath = "templates/\(organizationId)/\(category)/\(uniqueID)-\(filename)"
//        let storageRef = storage.reference().child(storagePath)
//
//        // Upload to Firebase Storage
//        let metadata = StorageMetadata()
//        metadata.contentType = "application/pdf"
//        let uploadTask = storageRef.putData(data, metadata: metadata)
//        let snapshot = try await uploadTask.snapshot
//
//        let downloadURL = try await fetchDownloadURL(storageRef: storageRef)
//        print("File uploaded successfully: \(downloadURL)")
//
//        // Save metadata to Firestore
//        let tempSOP = TempSOP(
//            id: uniqueID,
//            name: filename,
//            category: category,
//            subcategory: subcategory,
//            fileURL: downloadURL.absoluteString,
//            previewURL: nil,
//            description: "\(subcategory) - \(filename)",
//            organizationId: organizationId
//        )
//
//        try await db.collection("TempSOPs")
//            .document(tempSOP.id)
//            .setData(from: tempSOP)
//    }
//
//    private func fetchDownloadURL(storageRef: StorageReference) async throws -> URL {
//        for attempt in 1...3 {
//            do {
//                return try await storageRef.downloadURL()
//            } catch {
//                print("Attempt \(attempt): Retrying download URL fetch...")
//                try await Task.sleep(nanoseconds: 1_000_000_000) // 1-second delay
//            }
//        }
//        throw NSError(domain: "DownloadURL", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch download URL after retries"])
//    }
//
//    private func sanitizeFilename(_ filename: String) -> String {
//        return filename
//            .replacingOccurrences(of: " ", with: "_")
//            .replacingOccurrences(of: "(", with: "")
//            .replacingOccurrences(of: ")", with: "")
//            .replacingOccurrences(of: "%", with: "")
//            .replacingOccurrences(of: "&", with: "and")
//    }
//}

//
//

import SwiftUI
import UniformTypeIdentifiers
import Firebase
import FirebaseStorage

struct TemplateSOPUploadView: View {
    @StateObject private var viewModel = TemplateSOPUploadViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPDFs: [URL] = []
    @State private var showFileImporter = false
    @State private var selectedFolder = "Husbandry"
    @State private var sopForStaffTitle = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @AppStorage("organizationId") private var organizationId: String = ""
    
    let folders = ["Husbandry", "Vet Services"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("Select Folder", selection: $selectedFolder) {
                        ForEach(folders, id: \.self) { folder in
                            Text(folder).tag(folder)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    TextField("SOP For Staff Title", text: $sopForStaffTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    List {
                        ForEach(selectedPDFs, id: \.self) { url in
                            Text(url.lastPathComponent)
                        }
                        .onDelete(perform: deletePDFs)
                    }
                    .frame(height: 200)
                    .listStyle(PlainListStyle())
                    
                    Button("Select PDFs") {
                        showFileImporter = true
                    }
                    .padding()
                    
                    Button("Upload PDFs") {
                        uploadPDFs()
                    }
                    .padding()
                    .disabled(selectedPDFs.isEmpty || sopForStaffTitle.isEmpty)
                    
                    if viewModel.isUploading {
                        ProgressView("Uploading...", value: viewModel.uploadProgress, total: 1.0)
                            .padding()
                    }
                }
            }
            .navigationTitle("Template SOP Upload")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [UTType.pdf],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            selectedPDFs.append(contentsOf: urls)
        case .failure(let error):
            showAlert(title: "Error", message: "Error selecting PDFs: \(error.localizedDescription)")
        }
    }
    
    private func deletePDFs(at offsets: IndexSet) {
        selectedPDFs.remove(atOffsets: offsets)
    }
    
    private func uploadPDFs() {
        Task {
            do {
                try await viewModel.uploadTemplateSOPs(
                    pdfs: selectedPDFs,
                    category: selectedFolder,
                    subcategory: sopForStaffTitle
                )
                await MainActor.run {
                    showAlert(title: "Success", message: "All PDFs uploaded successfully")
                    selectedPDFs.removeAll()
                    sopForStaffTitle = ""
                }
            } catch {
                await MainActor.run {
                    showAlert(title: "Error", message: "Error uploading PDFs: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

//@MainActor
//class TemplateSOPUploadViewModel: ObservableObject {
//    @Published var isUploading = false
//    @Published var uploadProgress: Double = 0
//    private let storage = Storage.storage()
//    private let db = Firestore.firestore()
//    @AppStorage("organizationId") private var organizationId: String = ""
//    
//    func uploadTemplateSOPs(pdfs: [URL], category: String, subcategory: String) async throws {
//            guard !isUploading else {
//                print("Upload already in progress")
//                return
//            }
//            
//            isUploading = true
//            uploadProgress = 0
//            
//            do {
//                for (index, pdfURL) in pdfs.enumerated() {
//                    print("Starting upload for file: \(pdfURL.lastPathComponent)")
//                    try await uploadSinglePDF(pdfURL, category: category, subcategory: subcategory)
//                    uploadProgress = Double(index + 1) / Double(pdfs.count)
//                }
//                
//                isUploading = false
//                uploadProgress = 1.0
//                print("All PDFs uploaded successfully")
//                
//            } catch {
//                isUploading = false
//                print("Error during upload: \(error.localizedDescription)")
//                throw error
//            }
//        }
//        
//        private func uploadSinglePDF(_ pdfURL: URL, category: String, subcategory: String) async throws {
//            guard pdfURL.startAccessingSecurityScopedResource() else {
//                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to access PDF file"])
//            }
//            defer { pdfURL.stopAccessingSecurityScopedResource() }
//            
//            let data = try Data(contentsOf: pdfURL)
//            let filename = pdfURL.deletingPathExtension().lastPathComponent
//            let sanitizedFilename = sanitizeFilename(filename)
//            let uniqueID = UUID().uuidString
//            
//            // Create storage path
//            let storagePath = "templates/\(organizationId)/\(category)/\(uniqueID)-\(sanitizedFilename)"
//            print("Generated storage path: \(storagePath)")
//            
//            let storageRef = storage.reference().child(storagePath)
//            
//            // Upload with metadata
//            let metadata = StorageMetadata()
//            metadata.contentType = "application/pdf"
//            print("Starting upload task...")
//            
//            let uploadTask = storageRef.putData(data, metadata: metadata)
//            _ = try await uploadTask.snapshot
//            print("Upload completed successfully")
//            
//            // Get download URL
//            let downloadURL = try await storageRef.downloadURL()
//            print("Download URL obtained: \(downloadURL.absoluteString)")
//            
//            // Save to Firestore in TempSOPs collection
//            let tempSOP = TempSOP(
//                id: uniqueID,
//                name: sanitizedFilename,
//                category: category,
//                subcategory: subcategory,
//                fileURL: downloadURL.absoluteString,
//                previewURL: nil,
//                description: "\(subcategory) - \(sanitizedFilename)",
//                organizationId: organizationId
//            )
//            
//            // Save to top-level TempSOPs collection
//            try await db.collection("TempSOPs")
//                .document(uniqueID)
//                .setData(from: tempSOP)
//            
//            print("Document saved to Firestore with ID: \(uniqueID)")
//        }
//        
//        private func sanitizeFilename(_ filename: String) -> String {
//            return filename
//                .replacingOccurrences(of: " ", with: "_")
//                .replacingOccurrences(of: "(", with: "")
//                .replacingOccurrences(of: ")", with: "")
//                .replacingOccurrences(of: "%", with: "")
//                .replacingOccurrences(of: "&", with: "and")
//        }
//  
//}

// Define TempSOP structure if not already defined elsewhere
//struct TempSOP: Identifiable, Codable {
//    let id: String
//    let name: String
//    let category: String
//    let subcategory: String
//    let fileURL: String
//    let previewURL: String?
//    let description: String
//    let organizationId: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case name
//        case category
//        case subcategory
//        case fileURL
//        case previewURL
//        case description
//        case organizationId
//    }
//}
@MainActor
class TemplateSOPUploadViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    @AppStorage("organizationId") private var organizationId: String = ""
    
    func uploadTemplateSOPs(pdfs: [URL], category: String, subcategory: String) async throws {
        guard !isUploading else {
            print("Upload already in progress")
            return
        }
        
        isUploading = true
        uploadProgress = 0
        
        do {
            for (index, pdfURL) in pdfs.enumerated() {
                print("Starting upload for file: \(pdfURL.lastPathComponent)")
                try await uploadSinglePDF(pdfURL, category: category, subcategory: subcategory)
                
                await MainActor.run {
                    uploadProgress = Double(index + 1) / Double(pdfs.count)
                }
            }
            
            await MainActor.run {
                isUploading = false
                uploadProgress = 1.0
            }
            print("All PDFs uploaded successfully")
            
        } catch {
            await MainActor.run {
                isUploading = false
            }
            print("Error during upload: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func uploadSinglePDF(_ pdfURL: URL, category: String, subcategory: String) async throws {
        guard pdfURL.startAccessingSecurityScopedResource() else {
              throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to access PDF file"])
          }
          defer { pdfURL.stopAccessingSecurityScopedResource() }
          
          let data = try Data(contentsOf: pdfURL)
          let filename = pdfURL.deletingPathExtension().lastPathComponent
          let sanitizedFilename = sanitizeFilename(filename)
          let uniqueID = UUID().uuidString
          
          // Updated storage path to include subcategory folder
          let storagePath = "templates/\(organizationId)/\(category)/\(subcategory)/\(uniqueID)-\(sanitizedFilename).pdf"
          print("Generated storage path: \(storagePath)")
          
          let storageRef = storage.reference().child(storagePath)
        // Upload with metadata
        let metadata = StorageMetadata()
        metadata.contentType = "application/pdf"
        print("Starting upload task...")
        
        // Upload with retry logic
        var uploadAttempt = 0
        var uploadSuccess = false
        var lastError: Error? = nil
        
        while uploadAttempt < 3 && !uploadSuccess {
            do {
                uploadAttempt += 1
                _ = try await storageRef.putDataAsync(data, metadata: metadata)
                uploadSuccess = true
                print("Upload completed successfully on attempt \(uploadAttempt)")
            } catch {
                lastError = error
                print("Upload attempt \(uploadAttempt) failed: \(error.localizedDescription)")
                if uploadAttempt < 3 {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                }
            }
        }
        
        if !uploadSuccess {
            throw lastError ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload failed after 3 attempts"])
        }
        
        // Get download URL with retry logic
        var downloadURL: URL?
        var downloadAttempt = 0
        
        while downloadAttempt < 3 && downloadURL == nil {
            do {
                downloadAttempt += 1
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                downloadURL = try await storageRef.downloadURL()
                print("Download URL obtained on attempt \(downloadAttempt): \(downloadURL?.absoluteString ?? "")")
            } catch {
                print("Download URL attempt \(downloadAttempt) failed: \(error.localizedDescription)")
                if downloadAttempt < 3 {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                }
            }
        }
        
        guard let finalURL = downloadURL else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to obtain download URL after 3 attempts"])
        }
        
        // Save to Firestore in TempSOPs collection
        let tempSOP = TempSOP(
            id: uniqueID,
            name: sanitizedFilename,
            category: category,
            subcategory: subcategory,
            fileURL: finalURL.absoluteString,
            previewURL: nil,
            description: "\(subcategory) - \(sanitizedFilename)",
            organizationId: organizationId
        )
        
        // Save to top-level TempSOPs collection with retry logic
        var firestoreAttempt = 0
        var firestoreSuccess = false
        
        while firestoreAttempt < 3 && !firestoreSuccess {
            do {
                firestoreAttempt += 1
                try await db.collection("TempSOPs")
                    .document(uniqueID)
                    .setData(from: tempSOP)
                firestoreSuccess = true
                print("Document saved to Firestore with ID: \(uniqueID) on attempt \(firestoreAttempt)")
            } catch {
                print("Firestore save attempt \(firestoreAttempt) failed: \(error.localizedDescription)")
                if firestoreAttempt < 3 {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                }
            }
        }
        
        if !firestoreSuccess {
            // If Firestore save failed, try to delete the uploaded file
            try? await storageRef.delete()
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save to Firestore after 3 attempts"])
        }
    }
    
    private func sanitizeFilename(_ filename: String) -> String {
        return filename
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "-", with: "_")
    }
}
