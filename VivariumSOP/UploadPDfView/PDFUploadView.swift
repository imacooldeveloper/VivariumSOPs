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
/// workingg
//struct PDFUploadView: View {
//    @ObservedObject var viewModel: PDFCategoryViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedPDFs: [URL] = []
//    @State private var showFileImporter = false
//    @State private var selectedFolder = "Husbandry"
//    @State private var sopForStaffTitle = "Standard Husbandry"
//    @State private var isUploading = false
//    @State private var showAlert = false
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var isSuccess = false
//    @State private var currentUploadingPDF = ""
//    @State private var uploadProgress: Double = 0
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
//                TextField("SOP For Staff Title", text: $sopForStaffTitle)
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
//                .disabled(selectedPDFs.isEmpty)
//            }
//            .navigationTitle("Add New PDFs")
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
//                      dismissButton: .default(Text("OK")) {
//                          if isSuccess {
//                              presentationMode.wrappedValue.dismiss()
//                          }
//                      })
//            }
//            .overlay(
//                Group {
//                    if isUploading {
//                        VStack {
//                            Text(currentUploadingPDF)
//                                .font(.headline)
//                                .lineLimit(1)
//                                .truncationMode(.middle)
//                            GeometryReader { geometry in
//                                ZStack(alignment: .leading) {
//                                    Rectangle()
//                                        .fill(Color.gray.opacity(0.3))
//                                        .frame(height: 20)
//                                    Rectangle()
//                                        .fill(Color.blue)
//                                        .frame(width: geometry.size.width * CGFloat(uploadProgress), height: 20)
//                                }
//                                .cornerRadius(10)
//                            }
//                            .frame(height: 20)
//                            Text("\(Int(uploadProgress * 100))%")
//                                .font(.headline)
//                        }
//                        .padding()
//                        .frame(width: 300, height: 150)
//                        .background(Color.white)
//                        .cornerRadius(20)
//                        .shadow(radius: 10)
//                    }
//                }
//            )
//        }
//    }
//    
//    private func handleFileImport(_ result: Result<[URL], Error>) {
//        switch result {
//        case .success(let urls):
//            selectedPDFs.append(contentsOf: urls)
//        case .failure(let error):
//            showAlert(title: "Error", message: "Error selecting PDFs: \(error.localizedDescription)", isSuccess: false)
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
//            do {
//                for (index, url) in selectedPDFs.enumerated() {
//                    let data = try Data(contentsOf: url)
//                    let pdfName = url.deletingPathExtension().lastPathComponent
//                    
//                    let pdfCategory = PDFCategory(
//                        id: UUID().uuidString,
//                        nameOfCategory: selectedFolder,
//                        SOPForStaffTittle: sopForStaffTitle,
//                        pdfName: pdfName
//                    )
//                    
//                    await MainActor.run {
//                        currentUploadingPDF = pdfName
//                    }
//                    
//                    try await viewModel.uploadPDF(data: data, category: pdfCategory)
//                    
//                    // Update progress after each PDF upload
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
//                await MainActor.run {
//                    isUploading = false
//                    showAlert(title: "Error", message: "Error uploading PDFs: \(error.localizedDescription)", isSuccess: false)
//                }
//            }
//        }
//    }
//    
//    private func showAlert(title: String, message: String, isSuccess: Bool) {
//        alertTitle = title
//        alertMessage = message
//        self.isSuccess = isSuccess
//        showAlert = true
//    }
//}



struct PDFUploadView: View {
    @ObservedObject var viewModel: PDFCategoryViewModel
       @Environment(\.presentationMode) var presentationMode
       @State private var selectedPDFs: [URL] = []
       @State private var showFileImporter = false
       @State private var selectedFolder = ""
       @State private var sopForStaffTitle = ""
       @State private var isUploading = false
       @State private var showAlert = false
       @State private var alertTitle = ""
       @State private var alertMessage = ""
       @State private var isSuccess = false
       @State private var currentUploadingPDF = ""
       @State private var uploadProgress: Double = 0
       
       var body: some View {
           NavigationView {
               Form {
                   Picker("Select Folder", selection: $selectedFolder) {
                       ForEach(viewModel.uniqueCategories, id: \.self) { folder in
                           Text(folder).tag(folder)
                       }
                   }
                   
                   TextField("SOP Title", text: $sopForStaffTitle)
                       .padding()
                       .overlay(
                           RoundedRectangle(cornerRadius: 5)
                               .stroke(sopForStaffTitle.isEmpty ? Color.red : Color.clear, lineWidth: 1)
                       )
                   
                   if sopForStaffTitle.isEmpty {
                       Text("SOP Title is required")
                           .font(.caption)
                           .foregroundColor(.red)
                   }
                   
                   Section(header: Text("Selected PDFs")) {
                       ForEach(selectedPDFs, id: \.self) { url in
                           Text(url.lastPathComponent)
                       }
                       .onDelete(perform: deletePDFs)
                   }
                   
                   Button("Select PDFs") {
                       showFileImporter = true
                   }
                   
                   Button("Upload PDFs") {
                       uploadPDFs()
                   }
                   .disabled(selectedPDFs.isEmpty || selectedFolder.isEmpty || sopForStaffTitle.isEmpty)
               }
               .navigationTitle("Add New PDFs")
               .navigationBarItems(trailing: Button("Done") {
                   presentationMode.wrappedValue.dismiss()
               })
               .fileImporter(
                   isPresented: $showFileImporter,
                   allowedContentTypes: [.pdf],
                   allowsMultipleSelection: true
               ) { result in
                   handleFileImport(result)
               }
               .alert(isPresented: $showAlert) {
                   Alert(title: Text(alertTitle),
                         message: Text(alertMessage),
                         dismissButton: .default(Text("OK")) {
                             if isSuccess {
                                 presentationMode.wrappedValue.dismiss()
                             }
                         })
               }
               .overlay(uploadProgressView)
               .onAppear {
                   if viewModel.uniqueCategories.isEmpty {
                       Task {
                           await viewModel.fetchCategories()
                       }
                   }
                   if !viewModel.uniqueCategories.isEmpty {
                       selectedFolder = viewModel.uniqueCategories[0]
                   }
               }
           }
       }
       
       @ViewBuilder
       private var uploadProgressView: some View {
           if isUploading {
               VStack {
                   Text(currentUploadingPDF)
                       .font(.headline)
                       .lineLimit(1)
                       .truncationMode(.middle)
                   GeometryReader { geometry in
                       ZStack(alignment: .leading) {
                           Rectangle()
                               .fill(Color.gray.opacity(0.3))
                               .frame(height: 20)
                           Rectangle()
                               .fill(Color.blue)
                               .frame(width: geometry.size.width * CGFloat(uploadProgress), height: 20)
                       }
                       .cornerRadius(10)
                   }
                   .frame(height: 20)
                   Text("\(Int(uploadProgress * 100))%")
                       .font(.headline)
               }
               .padding()
               .frame(width: 300, height: 150)
               .background(Color.white)
               .cornerRadius(20)
               .shadow(radius: 10)
           }
       }
    
//    private func handleFileImport(_ result: Result<[URL], Error>) {
//        switch result {
//        case .success(let urls):
//            selectedPDFs.append(contentsOf: urls)
//        case .failure(let error):
//            showAlert(title: "Error", message: "Error selecting PDFs: \(error.localizedDescription)", isSuccess: false)
//        }
//    }
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                // Start accessing a security-scoped resource.
                guard url.startAccessingSecurityScopedResource() else {
                    print("Failed to access the resource.")
                    continue
                }
                
                // Make sure you release the security-scoped resource when you finish.
                defer { url.stopAccessingSecurityScopedResource() }
                
                // Here, you can create a local copy of the file if needed
                // For now, we'll just add the URL to our selectedPDFs array
                selectedPDFs.append(url)
            }
        case .failure(let error):
            showAlert(title: "Error", message: "Error selecting PDFs: \(error.localizedDescription)", isSuccess: false)
        }
    }
    private func deletePDFs(at offsets: IndexSet) {
        selectedPDFs.remove(atOffsets: offsets)
    }
    ///workingg
//    private func uploadPDFs() {
//        isUploading = true
//        uploadProgress = 0
//        
//        Task {
//            do {
//                for (index, url) in selectedPDFs.enumerated() {
//                    let data = try Data(contentsOf: url)
//                    let pdfName = url.deletingPathExtension().lastPathComponent
//                    
//                    let pdfCategory = PDFCategory(
//                        id: UUID().uuidString,
//                        nameOfCategory: selectedFolder,
//                        SOPForStaffTittle: sopForStaffTitle,
//                        pdfName: pdfName
//                    )
//                    
//                    await MainActor.run {
//                        currentUploadingPDF = pdfName
//                    }
//                    
//                    try await viewModel.uploadPDF(data: data, category: pdfCategory)
//                    
//                    // Update progress after each PDF upload
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
//                await MainActor.run {
//                    isUploading = false
//                    showAlert(title: "Error", message: "Error uploading PDFs: \(error.localizedDescription)", isSuccess: false)
//                }
//            }
//        }
//    }
    
    
    /// working on
//    private func uploadPDFs() {
//        Task {
//            do {
//                isUploading = true
//                uploadProgress = 0
//                
//                for (index, url) in selectedPDFs.enumerated() {
//                    let data = try Data(contentsOf: url)
//                    let pdfName = url.deletingPathExtension().lastPathComponent
//                    
//                    let pdfCategory = PDFCategory(
//                        id: UUID().uuidString,
//                        nameOfCategory: selectedFolder,
//                        SOPForStaffTittle: sopForStaffTitle,
//                        pdfName: pdfName
//                    )
//                    
//                    await MainActor.run {
//                        currentUploadingPDF = pdfName
//                    }
//                   
//                    
//                    try await viewModel.uploadPDF(data: data, category: pdfCategory)
//                    
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
//                await MainActor.run {
//                    isUploading = false
//                    showAlert(title: "Error", message: "Error uploading PDFs: \(error.localizedDescription)", isSuccess: false)
//                }
//            }
//        }
//    }
//    
    
    private func uploadPDFs() {
        Task {
            do {
                isUploading = true
                uploadProgress = 0
                
                for (index, url) in selectedPDFs.enumerated() {
                    guard url.startAccessingSecurityScopedResource() else {
                        print("Failed to access the resource.")
                        continue
                    }
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    let data = try Data(contentsOf: url)
                    let pdfName = url.deletingPathExtension().lastPathComponent
                    
                    let pdfCategory = PDFCategory(
                        id: UUID().uuidString,
                        nameOfCategory: selectedFolder,
                        SOPForStaffTittle: sopForStaffTitle,
                        pdfName: pdfName
                    )
                    
                    await MainActor.run {
                        currentUploadingPDF = pdfName
                    }
                    
                    try await viewModel.uploadPDF(data: data, category: pdfCategory)
                    
                    await MainActor.run {
                        uploadProgress = Double(index + 1) / Double(selectedPDFs.count)
                    }
                }
                
                await MainActor.run {
                    isUploading = false
                    showAlert(title: "Success", message: "All PDFs uploaded successfully", isSuccess: true)
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    showAlert(title: "Error", message: "Error uploading PDFs: \(error.localizedDescription)", isSuccess: false)
                }
            }
        }
    }
    private func showAlert(title: String, message: String, isSuccess: Bool) {
        alertTitle = title
        alertMessage = message
        self.isSuccess = isSuccess
        showAlert = true
    }
}

struct UploadProgressView: View {
    let progress: Double
    let currentPDF: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(currentPDF)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: geometry.size.width, height: 20)
                    
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: geometry.size.width * CGFloat(progress), height: 20)
                }
                .cornerRadius(10)
            }
            .frame(height: 20)
            
            Text("\(Int(progress * 100))%")
                .font(.subheadline)
                .bold()
        }
        .padding()
        .frame(width: 250)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}
struct UploadSummaryView: View {
    let uploadedPDFs: [String]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(uploadedPDFs, id: \.self) { pdf in
                    Text(pdf)
                }
            }
            .navigationTitle("Uploaded PDFs")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
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
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var showingSaveConfirmation = false
    
    
    @State private var customSOPTitle: String = ""
      @State private var isCustomSOP: Bool = false

    init(viewModel: PDFCategoryViewModel, category: PDFCategory) {
        self.viewModel = viewModel
        _editedCategory = State(initialValue: category)
        _pdfDocument = State(initialValue: PDFKit.PDFDocument(url: URL(string: category.pdfURL ?? "")!))
    }

    var body: some View {
        Form {
            Section(header: Text("Category Details")) {
                TextField("Name of Category", text: $editedCategory.nameOfCategory)
                TextField("SOP For Staff Title", text: $editedCategory.SOPForStaffTittle)
                TextField("PDF Name", text: $editedCategory.pdfName)
            }

            Section(header: Text("PDF Preview")) {
                PDFPreviewView(pdfDocument: pdfDocument, pdfURL: editedCategory.pdfURL)
                    .frame(height: 300)

                Button("Change PDF") {
                    showingPDFPicker = true
                }
            }

            if isUploading {
                Section {
                    ProgressView("Uploading...")
                }
            }
        }
        .navigationTitle("Edit Category")
        .navigationBarItems(trailing: Button("Save") {
            showingSaveConfirmation = true
        })
        .fileImporter(
            isPresented: $showingPDFPicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handlePDFSelection(result)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if isSuccess {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
        .actionSheet(isPresented: $showingSaveConfirmation) {
            ActionSheet(
                title: Text("Save Changes"),
                message: Text("Are you sure you want to save these changes?"),
                buttons: [
                    .default(Text("Save")) {
                        saveCategory()
                    },
                    .cancel()
                ]
            )
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

