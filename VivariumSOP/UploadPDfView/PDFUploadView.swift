//
//  PDFUploadView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

//import SwiftUI
//
//import SwiftUI
//import UniformTypeIdentifiers


import SwiftUI
import UniformTypeIdentifiers
import Firebase
import FirebaseFirestoreSwift
///working?
//struct PDFUploadView: View {
//    @StateObject private var storageManager = PDFStorageManager.shared
//    @StateObject private var viewModel = PDFCategoryViewModel()
//    @State private var selectedPDFs: [URL] = []
//    @State private var showFileImporter = false
//    @State private var selectedFolder = "Husbandry"
//    @State private var sopForStaffTitle = "Standard Husbandry"
//    @State private var showingEditView = false
//    @State private var selectedCategory: PDFCategory?
//    
//    let folders = ["Husbandry", "Vet Services"]
//    
//    let columns = [GridItem(.adaptive(minimum: 150))]
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack {
//                    Picker("Select Folder", selection: $selectedFolder) {
//                        ForEach(folders, id: \.self) { folder in
//                            Text(folder).tag(folder)
//                        }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .padding()
//                    
//                    TextField("SOP For Staff Title", text: $sopForStaffTitle)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//                    
//                    List {
//                        ForEach(selectedPDFs, id: \.self) { url in
//                            Text(url.lastPathComponent)
//                        }
//                        .onDelete(perform: deletePDFs)
//                    }
//                    .frame(height: 200)
//                    
//                    Button("Select PDFs") {
//                        showFileImporter = true
//                    }
//                    .padding()
//                    
//                    Button("Upload PDFs") {
//                        uploadPDFs()
//                    }
//                    .padding()
//                    .disabled(selectedPDFs.isEmpty)
//                    
//                    if storageManager.isUploading {
//                        ProgressView("Uploading...", value: storageManager.uploadProgress, total: 1.0)
//                            .padding()
//                    }
//                    
//                    Text("PDF Categories")
//                        .font(.headline)
//                        .padding()
//                    
//                    LazyVGrid(columns: columns, spacing: 20) {
//                        ForEach(viewModel.pdfCategories) { category in
//                            CategoryItemView(category: category)
//                                .onTapGesture {
//                                    selectedCategory = category
//                                    showingEditView = true
//                                }
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("PDF Upload and Management")
//            .onAppear {
//                viewModel.fetchPDFCategories()
//            }
//            .fileImporter(
//                isPresented: $showFileImporter,
//                allowedContentTypes: [UTType.pdf],
//                allowsMultipleSelection: true
//            ) { result in
//                switch result {
//                case .success(let urls):
//                    selectedPDFs.append(contentsOf: urls)
//                case .failure(let error):
//                    print("Error selecting PDFs: \(error.localizedDescription)")
//                }
//            }
//            .sheet(isPresented: $showingEditView) {
//                if let category = selectedCategory {
//                    EditCategoryView(viewModel: viewModel, category: category)
//                }
//            }
//        }
//    }
//    
//    func deletePDFs(at offsets: IndexSet) {
//        selectedPDFs.remove(atOffsets: offsets)
//    }
//    
//    func uploadPDFs() {
//        for url in selectedPDFs {
//            guard let data = try? Data(contentsOf: url) else { continue }
//            let filename = url.lastPathComponent
//            let path = "pdfs/\(selectedFolder)/\(filename.replacingOccurrences(of: ".pdf", with: ""))"
//            
//            let pdfCategory = PDFCategory(
//                nameOfCategory: selectedFolder,
//                SOPForStaffTittle: sopForStaffTitle,
//                pdfName: filename.replacingOccurrences(of: ".pdf", with: "")
//            )
//            
//            storageManager.uploadPDF(data: data, path: path, filename: filename, category: pdfCategory) { result in
//                switch result {
//                case .success(let downloadURL):
//                    print("Successfully uploaded \(filename). Download URL: \(downloadURL)")
//                    viewModel.fetchPDFCategories()  // Refresh the list after upload
//                case .failure(let error):
//                    print("Error uploading \(filename): \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}


import SwiftUI
import UniformTypeIdentifiers

import PDFKit

struct PDFUploadView: View {
    @StateObject private var storageManager = PDFStorageManager.shared
    @StateObject private var viewModel = PDFCategoryViewModel()
    @State private var selectedPDFs: [URL] = []
    @State private var showFileImporter = false
    @State private var selectedFolder = "Husbandry"
    @State private var sopForStaffTitle = "Standard Husbandry"
    @State private var showingEditView = false
    @State private var selectedCategory: PDFCategory?
    @State private var isUploading = false
    @State private var uploadError: String?
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isAddingNew = false

    let folders = ["Husbandry", "Vet Services", "Testing"]
    let columns = [GridItem(.adaptive(minimum: 150))]
    
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
                    
                    if isAddingNew {
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
                        
                        Button("Select PDFs") {
                            showFileImporter = true
                        }
                        .padding()
                        
                        Button("Upload PDFs") {
                            uploadPDFs()
                        }
                        .padding()
                        .disabled(selectedPDFs.isEmpty)
                    }
                    
                    if storageManager.isUploading {
                        ProgressView("Uploading...", value: storageManager.uploadProgress, total: 1.0)
                            .padding()
                    }
                    
                    Text("PDF Categories")
                        .font(.headline)
                        .padding()
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.pdfCategories) { category in
                            CategoryItemView(category: category)
                                .onTapGesture {
                                    selectedCategory = category
                                    showingEditView = true
                                }
                        }
                    }
                    .padding()
                }

                if let error = uploadError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("PDF Upload and Management")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isAddingNew ? "Cancel" : "Add New") {
                        isAddingNew.toggle()
                        if !isAddingNew {
                            selectedPDFs = []
                            sopForStaffTitle = "Standard Husbandry"
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchPDFCategories()
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [UTType.pdf],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
            .sheet(isPresented: $showingEditView) {
                if let category = selectedCategory {
                    EditCategoryView(viewModel: viewModel, category: category)
                }
            }
            .overlay(
                Group {
                    if showAlert {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .overlay(
                                CustomAlertView(
                                    title: alertTitle,
                                    message: alertMessage,
                                    isSuccess: isSuccess,
                                    dismissAction: { showAlert = false }
                                )
                            )
                    }
                }
            )
        }
    }

    func deletePDFs(at offsets: IndexSet) {
        selectedPDFs.remove(atOffsets: offsets)
    }

    func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            selectedPDFs.append(contentsOf: urls)
            showSuccessAlert(message: "PDFs selected successfully")
        case .failure(let error):
            showErrorAlert(message: "Error selecting PDFs: \(error.localizedDescription)")
        }
    }

    func uploadPDFs() {
        isUploading = true
        uploadError = nil

        Task {
            do {
                for url in selectedPDFs {
                    guard let data = try? Data(contentsOf: url) else { continue }
                    let filename = url.lastPathComponent
                    
                    var pdfCategory = PDFCategory(
                        nameOfCategory: selectedFolder,
                        SOPForStaffTittle: sopForStaffTitle,
                        pdfName: filename.replacingOccurrences(of: ".pdf", with: "")
                    )
                    
                    let downloadURL = try await storageManager.uploadPDF(data: data, category: pdfCategory)
                    pdfCategory.pdfURL = downloadURL
                    try await viewModel.updatePDFCategory(pdfCategory)
                }
                await viewModel.fetchPDFCategories()
                showSuccessAlert(message: "All PDFs uploaded successfully")
                isAddingNew = false
                selectedPDFs = []
            } catch {
                showErrorAlert(message: "Error uploading PDFs: \(error.localizedDescription)")
            }
            isUploading = false
        }
    }

    func showSuccessAlert(message: String) {
        alertTitle = "Success"
        alertMessage = message
        isSuccess = true
        showAlert = true
    }

    func showErrorAlert(message: String) {
        alertTitle = "Error"
        alertMessage = message
        isSuccess = false
        showAlert = true
    }
}

struct CategoryItemView: View {
    let category: PDFCategory
    
    var body: some View {
        VStack {
            Image(systemName: "doc.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
            Text(category.nameOfCategory)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100, height: 100)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

//struct CustomAlertView: View {
//    let title: String
//    let message: String
//    let isSuccess: Bool
//    let dismissAction: () -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: isSuccess ? "checkmark.circle" : "exclamationmark.triangle")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 50, height: 50)
//                .foregroundColor(isSuccess ? .green : .red)
//            
//            Text(title)
//                .font(.headline)
//            
//            Text(message)
//                .font(.body)
//                .multilineTextAlignment(.center)
//            
//            Button(action: dismissAction) {
//                Text("OK")
//                    .padding(.horizontal, 30)
//                    .padding(.vertical, 10)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//        .shadow(radius: 10)
//    }
//}
//
//struct CategoryItemView: View {
//    let category: PDFCategory
//    
//    var body: some View {
//        VStack {
//            Image(systemName: "doc.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                .foregroundColor(.blue)
//            Text(category.nameOfCategory)
//                .font(.caption)
//                .lineLimit(2)
//                .multilineTextAlignment(.center)
//        }
//        .frame(width: 100, height: 100)
//        .padding()
//        .background(Color.gray.opacity(0.1))
//        .cornerRadius(10)
//    }
//}



import SwiftUI
import PDFKit

@MainActor
struct EditCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PDFCategoryViewModel
    @State private var editedCategory: PDFCategory
    @State private var showingPDFPicker = false
    @State private var selectedPDF: URL?
    @State private var pdfDocument: PDFKit.PDFDocument?
    @State private var isUploading = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    init(viewModel: PDFCategoryViewModel, category: PDFCategory) {
        self.viewModel = viewModel
        _editedCategory = State(initialValue: category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // ... (existing form content)
            }
            .navigationTitle("Edit Category")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveCategory()
                }
            )
            .overlay(
                Group {
                    if showAlert {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .overlay(
                                CustomAlertView(
                                    title: alertTitle,
                                    message: alertMessage,
                                    isSuccess: isSuccess,
                                    dismissAction: {
                                        showAlert = false
                                        if isSuccess {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                )
                            )
                    }
                }
            )
        }
        .fileImporter(
            isPresented: $showingPDFPicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handlePDFSelection(result)
        }
    }
    
    private func handlePDFSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                selectedPDF = url
                DispatchQueue.global(qos: .userInitiated).async {
                    let document = PDFKit.PDFDocument(url: url)
                    DispatchQueue.main.async {
                        self.pdfDocument = document
                        self.showSuccessAlert(message: "PDF selected successfully")
                    }
                }
            }
        case .failure(let error):
            showErrorAlert(message: "Error selecting PDF: \(error.localizedDescription)")
        }
    }
    
    private func saveCategory() {
        isUploading = true
        
        Task {
            do {
                let originalCategory = viewModel.pdfCategories.first(where: { $0.id == editedCategory.id })
                
                if editedCategory.nameOfCategory != originalCategory?.nameOfCategory {
                    if let pdfURL = editedCategory.pdfURL, let url = URL(string: pdfURL) {
                        let pdfData = try Data(contentsOf: url)
                        let storageManager = PDFStorageManager.shared
                        let newURL = try await storageManager.movePDF(from: originalCategory!, to: editedCategory)
                        editedCategory.pdfURL = newURL
                    }
                }
                
                if let selectedPDF = selectedPDF {
                    let pdfData = try Data(contentsOf: selectedPDF)
                    let storageManager = PDFStorageManager.shared
                    let url = try await storageManager.uploadPDF(data: pdfData, category: editedCategory)
                    editedCategory.pdfURL = url
                }
                
                try await viewModel.updatePDFCategory(editedCategory)
                
                await MainActor.run {
                    isUploading = false
                    showSuccessAlert(message: "Category updated successfully")
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    showErrorAlert(message: "Error saving category: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func showSuccessAlert(message: String) {
        alertTitle = "Success"
        alertMessage = message
        isSuccess = true
        showAlert = true
    }
    
    func showErrorAlert(message: String) {
        alertTitle = "Error"
        alertMessage = message
        isSuccess = false
        showAlert = true
    }
}
//    private func handlePDFSelection(_ result: Result<[URL], Error>) {
//        switch result {
//        case .success(let urls):
//            if let url = urls.first {
//                selectedPDF = url
//                DispatchQueue.global(qos: .userInitiated).async {
//                    let document = PDFKit.PDFDocument(url: url)
//                    DispatchQueue.main.async {
//                        self.pdfDocument = document
//                    }
//                }
//            }
//        case .failure(let error):
//            print("Error selecting PDF: \(error.localizedDescription)")
//        }
//    }
//    @MainActor
//    private func saveCategory() {
//           isUploading = true
//           errorMessage = nil
//           
//           Task {
//               do {
//                   let originalCategory = viewModel.pdfCategories.first(where: { $0.id == editedCategory.id })
//                   
//                   // Check if the category name has changed
//                   if editedCategory.nameOfCategory != originalCategory?.nameOfCategory {
//                       // If the name has changed, we need to update the storage path
//                       if let pdfURL = editedCategory.pdfURL, let url = URL(string: pdfURL) {
//                           let pdfData = try Data(contentsOf: url)
//                           let storageManager = PDFStorageManager.shared
//                           let newURL = try await storageManager.movePDF(from: originalCategory!, to: editedCategory)
//                           editedCategory.pdfURL = newURL
//                       }
//                   }
//                   
//                   // Check if we need to update the PDF in storage
//                   if let selectedPDF = selectedPDF {
//                       let pdfData = try Data(contentsOf: selectedPDF)
//                       let storageManager = PDFStorageManager.shared
//                       let url = try await storageManager.uploadPDF(data: pdfData, category: editedCategory)
//                       editedCategory.pdfURL = url
//                   }
//                   
//                   // Update the category in Firestore
//                   try await viewModel.updatePDFCategory(editedCategory)
//                   
//                   await MainActor.run {
//                       isUploading = false
//                       presentationMode.wrappedValue.dismiss()
//                   }
//               } catch {
//                   await MainActor.run {
//                       isUploading = false
//                       errorMessage = "Error saving category: \(error.localizedDescription)"
//                   }
//               }
//           }
//       }
//}

struct PDFPreviewView: View {
    let pdfDocument: PDFKit.PDFDocument?
    let pdfURL: String?
    
    var body: some View {
        Group {
            if let pdfDocument = pdfDocument {
                PDFKitView(document: pdfDocument)
            } else if let pdfURL = URL(string: pdfURL ?? "") {
                PDFKitView(url: pdfURL)
            } else {
                Text("No PDF available")
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFKit.PDFDocument?
    
    init(document: PDFKit.PDFDocument?) {
        self.document = document
    }
    
    init(url: URL) {
        self.document = PDFKit.PDFDocument(url: url)
    }
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}

//class PDFCategoryViewModel: ObservableObject {
//    @Published var pdfCategories: [PDFCategory] = []
//    private var db = Firestore.firestore()
//    
//    func fetchPDFCategories() {
//        db.collection("PDFCategories").addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            
//            self.pdfCategories = documents.compactMap { queryDocumentSnapshot -> PDFCategory? in
//                return try? queryDocumentSnapshot.data(as: PDFCategory.self)
//            }
//        }
//    }
//    
//    func updatePDFCategory(_ category: PDFCategory) {
//        do {
//               try db.collection("PDFCategories").document(category.id).setData(from: category)
//           } catch let error {
//               print("Error updating category: \(error)")
//           }
//    }
//}
