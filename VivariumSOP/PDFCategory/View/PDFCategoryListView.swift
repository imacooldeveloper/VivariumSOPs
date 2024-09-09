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
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: String?
    @State private var showingPDFUploadView = false
    @State private var isDeleting = false
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading categories...")
            } else if viewModel.uniqueCategories.isEmpty {
                Text("No categories found")
            } else {
                List {
                    ForEach(viewModel.uniqueCategories, id: \.self) { category in
                        NavigationLink(destination: SubcategoryView(category: category, viewModel: viewModel)) {
                            Text(category)
                            
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                categoryToDelete = category
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("PDF Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingPDFUploadView = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            print("PDFCategoryListView appeared")
            Task {
                await  viewModel.fetchCategoriesIfNeeded()
            }
           
        }
        .overlay(deleteAlertView)
        .sheet(isPresented: $showingPDFUploadView) {
            PDFUploadView(viewModel: viewModel)
        }
    }
    
    private var deleteAlertView: some View {
        Group {
            if showingDeleteAlert, let category = categoryToDelete {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        CustomAlertView(
                            title: "Delete Category",
                            message: "Are you sure you want to delete the category '\(category)' and all its contents?",
                            primaryButton: AlertButton(title: "Delete", action: {
                                deleteCategory(category)
                            }),
                            secondaryButton: AlertButton(title: "Cancel", action: {
                                showingDeleteAlert = false
                            })
                        )
                    )
            }
        }
    }
    
    private func deleteCategory(_ category: String) {
           isDeleting = true
           Task {
               await viewModel.deleteCategory(category)
               showingDeleteAlert = false
               isDeleting = false
           }
       }
}

struct SubcategoryView: View {
    let category: String
    @ObservedObject var viewModel: PDFCategoryViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.getSubcategories(for: category), id: \.self) { subcategory in
                NavigationLink(destination: LazyView(PDFListView(category: category, subcategory: subcategory, viewModel: viewModel))) {
                    Text(subcategory)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(category)
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
///working ast of sept 9
//struct PDFListView: View {
//    let category: String
//    let subcategory: String
//    @ObservedObject var viewModel: PDFCategoryViewModel
//    @State private var showingDeleteAlert = false
//    @State private var pdfToDelete: PDFCategory?
//    @State private var showingErrorAlert = false
//    @State private var errorMessage = ""
//    @State private var showingCreateQuizView = false
//    @State private var selectedPDFName: String?
//    @State private var quizCreationCount = 0
//    var filteredPDFs: [PDFCategory] {
//        let pdfs = viewModel.pdfCategories.filter { $0.nameOfCategory == category && $0.SOPForStaffTittle == subcategory }
//        print("Filtered PDFs for \(category) - \(subcategory): \(pdfs.count)")
//        return pdfs.sorted(by: { $0.pdfName < $1.pdfName })
//    }
//
//    var body: some View {
//        VStack {
//            if filteredPDFs.isEmpty {
//                Text("No PDFs found for this subcategory")
//                    .foregroundColor(.gray)
//            } else {
//                List {
//                    ForEach(filteredPDFs, id: \.id) { pdf in
//                        NavigationLink(destination: PDFDetailView(pdf: pdf, viewModel: viewModel)) {
//                            Text(pdf.pdfName)
//                        }
//                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                            Button(role: .destructive) {
//                                pdfToDelete = pdf
//                                showingDeleteAlert = true
//                            } label: {
//                                Label("Delete", systemImage: "trash")
//                            }
//                        }
//                    }
//                }
//                .listStyle(InsetGroupedListStyle())
//            }
//        }
//        .navigationTitle(subcategory)
//       
//            .toolbar {
//                      ToolbarItem(placement: .bottomBar) {
//                          CreateQuizButton(action: createQuiz, isDisabled: filteredPDFs.isEmpty)
//                      }
//                  }
//     
//        .overlay(deleteAlert)
//        .alert("Error", isPresented: $showingErrorAlert, actions: {
//            Button("OK", role: .cancel) {}
//        }, message: {
//            Text(errorMessage)
//        })
//        .onAppear {
//            print("PDFListView appeared for \(category) - \(subcategory)")
//            print("Filtered PDFs: \(filteredPDFs.count)")
//        }
//        .sheet(isPresented: $showingCreateQuizView) {
//            CreateQuizView(viewModel: CreateQuizViewModel(category: subcategory, quizTitle: selectedPDFName ?? subcategory))
//            
////            let viewModel = CreateQuizViewModel(
////                category: "Husbandry",
////                subCategory: "What's the name",
////                quizTitle: "H-H-06 HBS Mortalities",
////                pdfName: "H-H-06 HBS Mortalities.pdf"
////               
////            )
////           CreateQuizView(viewModel: viewModel)
//                .onAppear {
//                    print("CreateQuizView sheet presented for category: \(subcategory), title: \(selectedPDFName ?? subcategory)")
//                }
//                .onDisappear {
//                    print("CreateQuizView sheet dismissed")
//                    self.selectedPDFName = nil
//                }
//        }
//    }
//
//    private func createQuiz() {
//           print("Create Quiz button tapped")
//           quizCreationCount += 1
//           
//           let quizTitle: String
//           if quizCreationCount == 1, let firstPDF = filteredPDFs.first {
//               quizTitle = firstPDF.pdfName
//               print("Selected PDF: \(firstPDF.pdfName)")
//           } else {
//               quizTitle = subcategory
//               print("Using subcategory as quiz title: \(subcategory)")
//           }
//           
//           selectedPDFName = quizTitle
//           showingCreateQuizView = true
//       }
//
//    private var deleteAlert: some View {
//        Group {
//            if showingDeleteAlert, let pdf = pdfToDelete {
//                Color.black.opacity(0.4)
//                    .edgesIgnoringSafeArea(.all)
//                    .overlay(
//                        CustomAlertView(
//                            title: "Delete PDF",
//                            message: "Are you sure you want to delete '\(pdf.pdfName)'?",
//                            primaryButton: AlertButton(title: "Delete", action: {
//                                deletePDF(pdf)
//                            }),
//                            secondaryButton: AlertButton(title: "Cancel", action: {
//                                showingDeleteAlert = false
//                            })
//                        )
//                    )
//            }
//        }
//    }
//
//    private func deletePDF(_ pdf: PDFCategory) {
//        Task {
//            do {
//                try await viewModel.deletePDF(pdf)
//                showingDeleteAlert = false
//            } catch {
//                errorMessage = error.localizedDescription
//                showingErrorAlert = true
//            }
//        }
//    }
//}
//
struct PDFListView: View {
    let category: String
    let subcategory: String
    @ObservedObject var viewModel: PDFCategoryViewModel
    @State private var showingDeleteAlert = false
    @State private var pdfToDelete: PDFCategory?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingCreateQuizView = false
    @State private var selectedPDFName: String?
    @State private var quizCreationCount = 0
    @State private var refreshToggle = false // Add this line
    @State private var isEditingExistingQuiz = false
    @State private var existingQuiz: Quiz?
    
    var filteredPDFs: [PDFCategory] {
        let pdfs = viewModel.pdfCategories.filter { $0.nameOfCategory == category && $0.SOPForStaffTittle == subcategory }
        print("Filtered PDFs for \(category) - \(subcategory): \(pdfs.count)")
        return pdfs.sorted(by: { $0.pdfName < $1.pdfName })
    }

    var body: some View {
        VStack {
            if filteredPDFs.isEmpty {
                Text("No PDFs found for this subcategory")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(filteredPDFs, id: \.id) { pdf in
                        NavigationLink(destination: PDFDetailView(pdf: pdf, viewModel: viewModel)) {
                            Text(pdf.pdfName)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                pdfToDelete = pdf
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle(subcategory)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                CreateQuizButton(action: createQuiz, isDisabled: filteredPDFs.isEmpty)
            }
        }
        .overlay(deleteAlert)
        .alert("Error", isPresented: $showingErrorAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(errorMessage)
        })
        .onAppear {
            print("PDFListView appeared for \(category) - \(subcategory)")
            print("Filtered PDFs: \(filteredPDFs.count)")
        }
        .sheet(isPresented: $showingCreateQuizView) {
            Group {
                if isEditingExistingQuiz, let quiz = existingQuiz {
                    EditQuizView(viewModel: EditQuizViewModel(quiz: quiz))
                } 
                
                else {
                    CreateQuizView(viewModel: CreateQuizViewModel(category: subcategory, quizTitle: selectedPDFName ?? subcategory))
                }
            }
            .onAppear {
                print("Quiz view presented for category: \(subcategory), title: \(selectedPDFName ?? subcategory), editing: \(isEditingExistingQuiz)")
            }
            .onDisappear {
                print("Quiz view dismissed")
                self.selectedPDFName = nil
                self.isEditingExistingQuiz = false
                self.existingQuiz = nil
                self.refreshToggle.toggle()
            }
        }
        //.id(refreshToggle) // Add this line
    }

    private func createQuiz() {
        print("Create Quiz button tapped")
        quizCreationCount += 1
        
        let quizTitle: String
        if quizCreationCount == 1, let firstPDF = filteredPDFs.first {
            quizTitle = firstPDF.pdfName
            print("Selected PDF: \(firstPDF.pdfName)")
        } else {
            quizTitle = subcategory
            print("Using subcategory as quiz title: \(subcategory)")
        }
        
        selectedPDFName = quizTitle
        
        Task {
            do {
                if let quiz = try await QuizManager.shared.getQuizForCategory(category: quizTitle) {
                    existingQuiz = quiz
                    isEditingExistingQuiz = true
                    print("Existing quiz found: \(quiz.id)")
                } else {
                    existingQuiz = nil
                    isEditingExistingQuiz = false
                    print("No existing quiz found")
                }
                showingCreateQuizView = true
            } catch {
                print("Error checking for existing quiz: \(error)")
                // Handle the error appropriately
            }
        }
    }
   
   
       private var deleteAlert: some View {
           Group {
               if showingDeleteAlert, let pdf = pdfToDelete {
                   Color.black.opacity(0.4)
                       .edgesIgnoringSafeArea(.all)
                       .overlay(
                           CustomAlertView(
                               title: "Delete PDF",
                               message: "Are you sure you want to delete '\(pdf.pdfName)'?",
                               primaryButton: AlertButton(title: "Delete", action: {
                                   deletePDF(pdf)
                               }),
                               secondaryButton: AlertButton(title: "Cancel", action: {
                                   showingDeleteAlert = false
                               })
                           )
                       )
               }
           }
       }
   
       private func deletePDF(_ pdf: PDFCategory) {
           Task {
               do {
                   try await viewModel.deletePDF(pdf)
                   showingDeleteAlert = false
               } catch {
                   errorMessage = error.localizedDescription
                   showingErrorAlert = true
               }
           }
       }
       
           
    // ... rest of the code remains the same
}

struct FetchQuizView: View {
    let quizId: String
    @State private var quiz: Quiz?
    @State private var isLoading = true
    @State private var error: Error?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading quiz...")
            } else if let quiz = quiz {
                EditQuizView(viewModel: EditQuizViewModel(quiz: quiz))
            } else if let error = error {
                Text("Error loading quiz: \(error.localizedDescription)")
            }
        }
        .onAppear {
            fetchQuiz()
        }
    }

    private func fetchQuiz() {
        Task {
            do {
                self.quiz = try await QuizManager.shared.getQuiz(id: quizId)
                self.isLoading = false
            } catch {
                self.error = error
                self.isLoading = false
            }
        }
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
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var hasChanges = false
    @State private var showingSaveConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
       @State private var showingErrorAlert = false
     
    init(pdf: PDFCategory, viewModel: PDFCategoryViewModel) {
        _pdf = State(initialValue: pdf)
        self.viewModel = viewModel
        _pdfDocument = State(initialValue: PDFKit.PDFDocument(url: URL(string: pdf.pdfURL ?? "")!))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    PDFKitRepresentedView(document: pdfDocument)
                        .frame(height: 900)  // Adjust this height as needed
                    
                    if isEditing {
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("Name of Category", text: Binding(
                                get: { pdf.nameOfCategory },
                                set: {
                                    pdf.nameOfCategory = $0
                                    hasChanges = true
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("SOP For Staff Title", text: Binding(
                                get: { pdf.SOPForStaffTittle },
                                set: {
                                    pdf.SOPForStaffTittle = $0
                                    hasChanges = true
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("PDF Name", text: Binding(
                                get: { pdf.pdfName },
                                set: {
                                    pdf.pdfName = $0
                                    hasChanges = true
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Change PDF") {
                                showingPDFPicker = true
                            }
                            .padding(.vertical)
                        }
                        .padding(.horizontal)
                    }
                    
                    if isUploading {
                        ProgressView("Uploading...")
                            .padding()
                    }
                }
            }
            .navigationTitle(pdf.pdfName)
            .navigationBarItems(trailing: Button(isEditing ? "Done" : "Edit") {
                if isEditing && hasChanges {
                    showingSaveConfirmation = true
                } else {
                    isEditing.toggle()
                }
                Button(action: {
                                      showingDeleteConfirmation = true
                                  }) {
                                      Image(systemName: "trash")
                                  }
                                  .foregroundColor(.red)
                
            })
            .fileImporter(
                isPresented: $showingPDFPicker,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                handlePDFSelection(result)
            }
            
            if showingSaveConfirmation {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        CustomAlertView(
                            title: "Save Changes",
                            message: "Do you want to save the changes?",
                            primaryButton: AlertButton(title: "Save", action: {
                                saveChanges()
                                showingSaveConfirmation = false
                            }),
                            secondaryButton: AlertButton(title: "Discard", action: {
                                isEditing = false
                                hasChanges = false
                                showingSaveConfirmation = false
                            }),
                            dismissButton: AlertButton(title: "Cancel", action: {
                                showingSaveConfirmation = false
                            })
                        )
                    )
            }
            if showingDeleteConfirmation {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .overlay(
                                CustomAlertView(
                                    title: "Delete PDF",
                                    message: "Are you sure you want to delete this PDF?",
                                    primaryButton: AlertButton(title: "Delete", action: {
                                        deletePDF()
                                        showingDeleteConfirmation = false
                                    }),
                                    secondaryButton: AlertButton(title: "Cancel", action: {
                                        showingDeleteConfirmation = false
                                    })
                                )
                            )
                    }
            if showAlert {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        CustomAlertView(
                            title: alertTitle,
                            message: alertMessage,
                            primaryButton: AlertButton(title: "OK", action: {
                                showAlert = false
                                if isSuccess {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }),
                            secondaryButton: nil,
                            dismissButton: AlertButton(title: "Cancel", action: {
                                showAlert = false
                            })
                        )
                    )
            }
        }
    
    }
    
    private func handlePDFSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                updatePDF(url: url)
            }
        case .failure(let error):
            errorMessage = "Error selecting PDF: \(error.localizedDescription)"
        }
    }
    private func deletePDF() {
           Task {
               do {
                   try await viewModel.deletePDF(pdf)
                   showSuccessAlert(message: "PDF deleted successfully")
               } catch {
                   showErrorAlert(message: "Error deleting PDF: \(error.localizedDescription)")
               }
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
                    hasChanges = true
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
                await MainActor.run {
                    isEditing = false
                    hasChanges = false
                    showSuccessAlert(message: "Changes saved successfully")
                }
            } catch {
                await MainActor.run {
                    showErrorAlert(message: "Error saving changes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showSuccessAlert(message: String) {
        alertTitle = "Success"
        alertMessage = message
        isSuccess = true
        showAlert = true
    }
    
    private func showErrorAlert(message: String) {
        alertTitle = "Error"
        alertMessage = message
        isSuccess = false
        showAlert = true
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
