//
//  PDFCategoryListView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI
import Firebase
import PDFKit

struct PDFCategoryListView: View {
    @StateObject private var viewModel = PDFCategoryViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(Set(viewModel.pdfCategories.map { $0.nameOfCategory })), id: \.self) { category in
                    NavigationLink(destination: SubcategoryView(category: category, viewModel: viewModel)) {
                        Text(category)
                    }
                }
            }
            .navigationTitle("PDF Categories")
            .onAppear {
                viewModel.fetchPDFCategories()
            }
        }
    }
}

struct SubcategoryView: View {
    let category: String
    @ObservedObject var viewModel: PDFCategoryViewModel
    
    var body: some View {
        List {
            ForEach(Array(Set(viewModel.pdfCategories.filter { $0.nameOfCategory == category }.map { $0.SOPForStaffTittle })), id: \.self) { subcategory in
                NavigationLink(destination: PDFListView(category: category, subcategory: subcategory, viewModel: viewModel)) {
                    Text(subcategory)
                }
            }
        }
        .navigationTitle(category)
    }
}

struct PDFListView: View {
    let category: String
    let subcategory: String
    @ObservedObject var viewModel: PDFCategoryViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.pdfCategories.filter { $0.nameOfCategory == category && $0.SOPForStaffTittle == subcategory }) { pdf in
                NavigationLink(destination: PDFDetailView(pdf: pdf, viewModel: viewModel)) {
                    Text(pdf.pdfName)
                }
            }
        }
        .navigationTitle(subcategory)
    }
}

struct PDFDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var pdf: PDFCategory
    @ObservedObject var viewModel: PDFCategoryViewModel
    @State private var isEditing = false
    @State private var showingPDFPicker = false
    @State private var pdfDocument: PDFKit.PDFDocument?
    @State private var errorMessage: String?
    @State private var isUploading = false
    
    init(pdf: PDFCategory, viewModel: PDFCategoryViewModel) {
        _pdf = State(initialValue: pdf)
        self.viewModel = viewModel
        _pdfDocument = State(initialValue: PDFKit.PDFDocument(url: URL(string: pdf.pdfURL ?? "")!))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PDFKitRepresentedView(document: pdfDocument)
                    .frame(height: 900)  // Adjust this height as needed
                
                if isEditing {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Name of Category", text: $pdf.nameOfCategory)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("SOP For Staff Title", text: $pdf.SOPForStaffTittle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("PDF Name", text: $pdf.pdfName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Change PDF") {
                            showingPDFPicker = true
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if isUploading {
                    ProgressView("Uploading...")
                        .padding()
                }
            }
        }
        .navigationTitle(pdf.pdfName)
        .navigationBarItems(trailing: Button(isEditing ? "Done" : "Edit") {
            if isEditing {
                saveChanges()
            }
            isEditing.toggle()
        })
        .fileImporter(
            isPresented: $showingPDFPicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handlePDFSelection(result)
        }
    }
    
     func handlePDFSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                updatePDF(url: url)
            }
        case .failure(let error):
            errorMessage = "Error selecting PDF: \(error.localizedDescription)"
        }
    }
    
    private func updatePDF(url: URL) {
        isUploading = true
        errorMessage = nil
        
        Task {
            do {
                let pdfData = try Data(contentsOf: url)
                let storageManager = PDFStorageManager.shared
                let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
                
                await MainActor.run {
                    pdf.pdfURL = newURL
                    pdfDocument = PDFKit.PDFDocument(url: url)
                    isUploading = false
                    
                    saveChanges()
                      presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error uploading PDF: \(error.localizedDescription)"
                    isUploading = false
                }
            }
        }
    }
    
    private func saveChanges() {
        Task {
            do {
                try await viewModel.updatePDFCategory(pdf)
                errorMessage = nil
            } catch {
                errorMessage = "Error saving changes: \(error.localizedDescription)"
            }
        }
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let document: PDFKit.PDFDocument?
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = document
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
       
        uiView.document = document
    }
}
