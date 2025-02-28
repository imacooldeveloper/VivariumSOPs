//
//  PDFUploadView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//



import SwiftUI
import UniformTypeIdentifiers
import Firebase
import PDFKit


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
    @State private var showingTemplateSOPs = false
    @State private var existingSOPTitles: [String] = []
    @State private var isNewSOP = true // Toggle between new and existing SOP
    @State private var selectedExistingSOP = "" // For existing SOP selection
    @AppStorage("organizationId") private var organizationId: String = ""
    
    private var isTitleValid: Bool {
        if isNewSOP {
            return !sopForStaffTitle.isEmpty && !existingSOPTitles.contains(sopForStaffTitle)
        } else {
            return !selectedExistingSOP.isEmpty
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Selection")) {
                    Picker("Select Folder", selection: $selectedFolder) {
                        ForEach(viewModel.uniqueCategories, id: \.self) { folder in
                            Text(folder).tag(folder)
                        }
                    }
                    .onChange(of: selectedFolder) { newValue in
                        fetchExistingSOPTitles(for: newValue)
                    }
                }
                
                Section(header: Text("SOP Selection")) {
                    Picker("SOP Type", selection: $isNewSOP) {
                        Text("New SOP").tag(true)
                        Text("Existing SOP").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if isNewSOP {
                        TextField("New SOP Title", text: $sopForStaffTitle)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(!isTitleValid ? Color.red : Color.clear, lineWidth: 1)
                            )
                        
                        if !sopForStaffTitle.isEmpty && existingSOPTitles.contains(sopForStaffTitle) {
                            Text("This SOP Title already exists")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    } else {
                        Picker("Select Existing SOP", selection: $selectedExistingSOP) {
                            Text("Select an SOP").tag("")
                            ForEach(existingSOPTitles, id: \.self) { title in
                                Text(title).tag(title)
                            }
                        }
                    }
                }
                
                Section(header: Text("Template SOPs")) {
                    Button(action: {
                        showingTemplateSOPs = true
                    }) {
                        HStack {
                            Image(systemName: "doc.fill.badge.plus")
                            Text("Browse Template SOPs")
                        }
                    }
                }
                
                Section(header: Text("Selected PDFs")) {
                    if selectedPDFs.isEmpty {
                        Text("No PDFs selected")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(selectedPDFs, id: \.self) { url in
                            Text(url.lastPathComponent)
                        }
                        .onDelete(perform: deletePDFs)
                    }
                }
                
                Section {
                    Button("Select PDFs") {
                        showFileImporter = true
                    }
                    
                    Button("Upload PDFs") {
                        uploadPDFs()
                    }
                    .disabled(!isTitleValid || selectedPDFs.isEmpty || selectedFolder.isEmpty)
                }
            }
            .navigationTitle("Add New PDFs")
//            .navigationBarItems(trailing: Button("Done") {
//                presentationMode.wrappedValue.dismiss()
//            })
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if isSuccess {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
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
                    fetchExistingSOPTitles(for: selectedFolder)
                }
            }
        }
    }
    
    private func fetchExistingSOPTitles(for category: String) {
        Task {
            do {
                let sopCategories = try await viewModel.getCategoryList(for: organizationId, title: category)
                await MainActor.run {
                    existingSOPTitles = sopCategories.map { $0.SOPForStaffTittle }
                }
            } catch {
                print("Error fetching SOP titles: \(error)")
            }
        }
    }
    
    private func uploadPDFs() {
        Task {
            do {
                isUploading = true
                uploadProgress = 0
                let title = isNewSOP ? sopForStaffTitle : selectedExistingSOP
                
                try await viewModel.uploadAllPDFs(
                    selectedPDFs: selectedPDFs,
                    selectedTemplates: [],
                    folder: selectedFolder,
                    title: title,
                    onProgress: { progress, currentFile in
                        Task { @MainActor in
                            uploadProgress = progress
                            currentUploadingPDF = currentFile
                        }
                    }
                )
                
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
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else { continue }
                defer { url.stopAccessingSecurityScopedResource() }
                selectedPDFs.append(url)
            }
        case .failure(let error):
            showAlert(title: "Error", message: "Error selecting PDFs: \(error.localizedDescription)", isSuccess: false)
        }
    }
    
    private func deletePDFs(at offsets: IndexSet) {
        selectedPDFs.remove(atOffsets: offsets)
    }
    
    private func showAlert(title: String, message: String, isSuccess: Bool) {
        alertTitle = title
        alertMessage = message
        self.isSuccess = isSuccess
        showAlert = true
    }
    
    private var uploadProgressView: some View {
        Group {
            if isUploading {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Uploading \(currentUploadingPDF)...")
                            .foregroundColor(.white)
                        Text("\(Int(uploadProgress * 100))%")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        }
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
   
        @State private var selectedCategoryName: String
        @State private var selectedSubcategory: String
    
    @State private var customSOPTitle: String = ""
      @State private var isCustomSOP: Bool = false

    init(viewModel: PDFCategoryViewModel, category: PDFCategory) {
        self.viewModel = viewModel
        _editedCategory = State(initialValue: category)
        _selectedCategoryName = State(initialValue: category.nameOfCategory)
        _selectedSubcategory = State(initialValue: category.SOPForStaffTittle)
        _pdfDocument = State(initialValue: PDFKit.PDFDocument(url: URL(string: category.pdfURL ?? "")!))
    }

    var body: some View {
        Form {
            Section(header: Text("Category Details")) {
                Picker("Category", selection: $selectedCategoryName) {
                                  ForEach(viewModel.uniqueCategories, id: \.self) { category in
                                      Text(category).tag(category)
                                  }
                              }
                              
                              // Subcategory Picker (updates based on selected category)
                              Picker("SOP Title", selection: $selectedSubcategory) {
                                  ForEach(viewModel.getSubcategories(for: selectedCategoryName), id: \.self) { subcategory in
                                      Text(subcategory).tag(subcategory)
                                  }
                              }
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
        .onChange(of: selectedCategoryName) { newCategory in
                  // Update edited category when selection changes
                  editedCategory.nameOfCategory = newCategory
                  // Reset subcategory if needed
                  if !viewModel.getSubcategories(for: newCategory).contains(selectedSubcategory) {
                      selectedSubcategory = viewModel.getSubcategories(for: newCategory).first ?? ""
                  }
              }
              .onChange(of: selectedSubcategory) { newSubcategory in
                  // Update edited category when subcategory changes
                  editedCategory.SOPForStaffTittle = newSubcategory
              }
              .onAppear {
                  // Make sure categories are loaded
                  Task {
                      await viewModel.fetchCategoriesIfNeeded()
                  }
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

