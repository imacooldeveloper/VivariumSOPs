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
    @EnvironmentObject var viewModel: PDFCategoryViewModel
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: String?
    @State private var showingPDFUploadView = false
    @State private var isDeleting = false
    @State private var showingAddCategorySheet = false
    @State private var newCategoryTitle = ""
    @State private var deletionCode = ""
    @State private var showingDeleteVerification = false
    @State private var showingIncorrectCodeError = false
    
    private let correctDeletionCode = "12345"
    
    var body: some View {
        ZStack {
            CategoryContentView(
                viewModel: viewModel,
                categoryToDelete: $categoryToDelete,
                showingDeleteVerification: $showingDeleteVerification
            )
            
            AddCategoryButton(showingAddCategorySheet: $showingAddCategorySheet)
        }
        .navigationTitle("PDF Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                UploadPDFButton(showingPDFUploadView: $showingPDFUploadView)
            }
        }
        .sheet(isPresented: $showingPDFUploadView) {
            PDFUploadView()
        }
        .sheet(isPresented: $showingAddCategorySheet) {
            AddCategorySheet(
                showingSheet: $showingAddCategorySheet,
                newCategoryTitle: $newCategoryTitle,
                viewModel: viewModel
            )
        }
        .alert("Verification Required", isPresented: $showingDeleteVerification) {
            DeleteVerificationAlert(
                deletionCode: $deletionCode,
                onDelete: verifyAndDelete,
                onCancel: { deletionCode = "" }
            )
        }
        .alert("Incorrect Code", isPresented: $showingIncorrectCodeError) {
            Button("OK", role: .cancel) { deletionCode = "" }
        } message: {
            Text("The deletion code entered was incorrect. Please try again.")
        }
    }
    
    private func verifyAndDelete() {
        if deletionCode == correctDeletionCode {
            if let category = categoryToDelete {
                Task {
                    do {
                        try await viewModel.deleteCategory(category)
                    } catch {
                        print("Error deleting category: \(error)")
                    }
                }
            }
        } else {
            showingIncorrectCodeError = true
        }
        deletionCode = ""
    }
}

// MARK: - Supporting Views
private struct CategoryContentView: View {
    @ObservedObject var viewModel: PDFCategoryViewModel
    @Binding var categoryToDelete: String?
    @Binding var showingDeleteVerification: Bool
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading categories...")
            } else if viewModel.uniqueCategories.isEmpty {
                EmptyCategoryView()
            } else {
                CategoryList(
                    categories: viewModel.uniqueCategories,
                    viewModel: viewModel,
                    categoryToDelete: $categoryToDelete,
                    showingDeleteVerification: $showingDeleteVerification
                )
            }
        }
    }
}

private struct EmptyCategoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("No categories found")
                .font(.headline)
            
            VStack {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Tap the + button below to add a category")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .padding(.top, 30)
        }
    }
}

private struct CategoryList: View {
    let categories: [String]
    let viewModel: PDFCategoryViewModel
    @Binding var categoryToDelete: String?
    @Binding var showingDeleteVerification: Bool
    
    var body: some View {
        List {
            ForEach(categories, id: \.self) { category in
                NavigationLink(destination: SubcategoryView(category: category, viewModel: viewModel)) {
                    Text(category)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        categoryToDelete = category
                        showingDeleteVerification = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

private struct AddCategoryButton: View {
    @Binding var showingAddCategorySheet: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 5) {
                    Text("Add Category")
                        .font(.caption)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.2), radius: 2)
                        .offset(y: -5)
                    
                    Button(action: { showingAddCategorySheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

private struct UploadPDFButton: View {
    @Binding var showingPDFUploadView: Bool
    
    var body: some View {
        HStack {
            Text("Upload PDF")
                .font(.caption)
                .foregroundColor(.blue)
            
            Button(action: { showingPDFUploadView = true }) {
                Image(systemName: "arrow.up.doc")
                    .foregroundColor(.blue)
            }
        }
    }
}

private struct AddCategorySheet: View {
    @Binding var showingSheet: Bool
    @Binding var newCategoryTitle: String
    let viewModel: PDFCategoryViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Category")) {
                    TextField("Category Title", text: $newCategoryTitle)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingSheet = false
                    newCategoryTitle = ""
                },
                trailing: Button("Save") {
                    if !newCategoryTitle.isEmpty {
                        Task {
                            await viewModel.addCategory(newCategoryTitle)
                            showingSheet = false
                            newCategoryTitle = ""
                        }
                    }
                }
            )
        }
    }
}

private struct DeleteVerificationAlert: View {
    @Binding var deletionCode: String
    let onDelete: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        TextField("Enter deletion code", text: $deletionCode)
            .keyboardType(.numberPad)
        Button("Delete", role: .destructive, action: onDelete)
        Button("Cancel", role: .cancel, action: onCancel)
    }
}

struct SubcategoryView: View {
    let category: String
       @ObservedObject var viewModel: PDFCategoryViewModel
       @State private var showingDeleteAlert = false
       @State private var subcategoryToDelete: String?
       @State private var deletionCode = ""
       @State private var showingDeleteVerification = false
       @State private var showingIncorrectCodeError = false
       @State private var subcategories: [String] = [] // Cache subcategories
       
       private let correctDeletionCode = "12345"
       @State private var isDeleting = false
       @State private var showingErrorAlert = false
       @State private var errorMessage = ""
       
       var body: some View {
           ZStack {
               if subcategories.isEmpty {
                   // Empty state UI - simplified without button
                   VStack(spacing: 25) {
                       Image(systemName: "doc.text.magnifyingglass")
                           .font(.system(size: 60))
                           .foregroundColor(.blue)
                       
                       Text("No SOPs Found")
                           .font(.title2)
                           .fontWeight(.semibold)
                       
                       Text("SOPs for '\(category)' will appear here.\nUse the Upload button in the main screen to add new SOPs.")
                           .multilineTextAlignment(.center)
                           .foregroundColor(.secondary)
                           .padding(.horizontal)
                   }
                   .padding()
               } else {
                   List {
                       ForEach(subcategories, id: \.self) { subcategory in
                           NavigationLink(destination: PDFListView(category: category, subcategory: subcategory, viewModel: viewModel)) {
                               Text(subcategory)
                           }
                           .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                               Button(role: .destructive) {
                                   subcategoryToDelete = subcategory
                                   showingDeleteVerification = true
                               } label: {
                                   Label("Delete", systemImage: "trash")
                               }
                           }
                       }
                   }
                   .listStyle(InsetGroupedListStyle())
               }
           }
           .navigationTitle(category)
           .onAppear {
               // Cache subcategories when view appears
               subcategories = viewModel.getSubcategories(for: category)
           }
        .alert("Verification Required", isPresented: $showingDeleteVerification) {
            TextField("Enter deletion code", text: $deletionCode)
                .keyboardType(.numberPad)
            Button("Delete", role: .destructive) {
                verifyAndDelete()
            }
            Button("Cancel", role: .cancel) {
                deletionCode = ""
            }
        } message: {
            Text("Enter the deletion code to remove this subcategory and all its contents.")
        }
        .alert("Incorrect Code", isPresented: $showingIncorrectCodeError) {
            Button("OK", role: .cancel) {
                deletionCode = ""
            }
        } message: {
            Text("The deletion code entered was incorrect. Please try again.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .overlay(Group {
            if isDeleting {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Deleting subcategory...")
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        })
    }
    
    private func verifyAndDelete() {
        if deletionCode == correctDeletionCode {
            if let subcategoryToDelete = subcategoryToDelete {
                isDeleting = true
                
                Task {
                    do {
                        try await viewModel.deleteSubcategory(category: category, subcategory: subcategoryToDelete)
                        
                        await MainActor.run {
                            isDeleting = false
                            // Update local subcategories array to remove the deleted item
                            subcategories.removeAll { $0 == subcategoryToDelete }
                        }
                    } catch {
                        await MainActor.run {
                            isDeleting = false
                            errorMessage = "Failed to delete subcategory: \(error.localizedDescription)"
                            showingErrorAlert = true
                        }
                    }
                }
            }
        } else {
            showingIncorrectCodeError = true
        }
        deletionCode = ""
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

struct PDFListView: View {
    let category: String
    let subcategory: String
    @StateObject var viewModel: PDFCategoryViewModel
    
    // Alert and UI state
    @State private var showingDeleteAlert = false
    @State private var pdfToDelete: PDFCategory?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // Quiz-related state
    @State private var showingCreateQuizView = false
    @State private var selectedPDFName: String?
    @State private var quizCreationCount = 0
    @State private var isEditingExistingQuiz = false
    @State private var existingQuiz: Quiz?
    @State private var createQuizViewModel: CreateQuizViewModel?
    
    // Pagination state
    @State private var pdfs: [PDFCategory] = []
    @State private var isLoading = true
    @State private var hasMoreData = true
    @State private var currentPage = 0
    private let pageSize = 20
    
    var body: some View {
        VStack {
            if isLoading && pdfs.isEmpty {
                ProgressView("Loading PDFs...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if pdfs.isEmpty {
                Text("No PDFs found for this subcategory")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(pdfs, id: \.id) { pdf in
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
                    
                    if hasMoreData {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .onAppear {
                                loadMorePDFs()
                            }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .refreshable {
                    await refreshPDFs()
                }
            }
        }
        .navigationTitle(subcategory)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                QuizButtonView(subcategory: subcategory)
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                   
                   
            }
            
        }
        
        .overlay(deleteAlert)
        .alert("Error", isPresented: $showingErrorAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(errorMessage)
        })
        .onAppear {
            Task {
                await loadInitialPDFs()
            }
        }
        // Add refresh functionality
        .refreshable {
            Task {
                await loadInitialPDFs()
            }
        }
        
        .sheet(isPresented: $showingCreateQuizView) {
            // Add debug prints
            let _ = print("Sheet triggered")
            let _ = print("isEditingExistingQuiz: \(isEditingExistingQuiz)")
            let _ = print("existingQuiz: \(String(describing: existingQuiz))")
            let _ = print("selectedPDFName: \(String(describing: selectedPDFName))")
            
            if isEditingExistingQuiz, let quiz = existingQuiz {
                let _ = print("Showing EditQuizView for quiz: \(quiz.id)")
                EditQuizView(viewModel: EditQuizViewModel(quiz: quiz))
                    .onDisappear {
                        let _ = print("EditQuizView disappeared")
                        isEditingExistingQuiz = false
                        existingQuiz = nil
                        selectedPDFName = nil
                    }
            } else {
                let _ = print("Showing CreateQuizView")
                CreateQuizView(
                    viewModel: CreateQuizViewModel(
                        category: subcategory,
                        quizTitle: selectedPDFName ?? subcategory
                    )
                )
            }
        }
    }
    
    private func loadInitialPDFs() async {
        isLoading = true
        currentPage = 0
        do {
            let initialPDFs = try await viewModel.fetchPDFsForSubcategory(
                category: category,
                subcategory: subcategory,
                limit: pageSize
            )
            await MainActor.run {
                pdfs = initialPDFs
                hasMoreData = initialPDFs.count >= pageSize
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showingErrorAlert = true
                isLoading = false
            }
        }
    }
    
    private func loadMorePDFs() {
        guard !isLoading && hasMoreData else { return }
        
        Task {
            isLoading = true
            do {
                let nextPage = try await viewModel.fetchPDFsForSubcategory(
                    category: category,
                    subcategory: subcategory,
                    startAfter: pdfs.last,
                    limit: pageSize
                )
                await MainActor.run {
                    pdfs.append(contentsOf: nextPage)
                    hasMoreData = nextPage.count >= pageSize
                    currentPage += 1
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingErrorAlert = true
                    isLoading = false
                }
            }
        }
    }
    
    private func refreshPDFs() async {
        await loadInitialPDFs()
    }
    
    private func createQuiz() {
        print("Create Quiz button tapped")
        
        // Set the quiz title based on selected PDF or subcategory
        let quizTitle = selectedPDFName ?? subcategory
        print("Selected quiz title: \(quizTitle)")
        
        Task {
            do {
                if let quiz = try await QuizManager.shared.getQuizForCategory(category: quizTitle) {
                    await MainActor.run {
                        // Set up for editing existing quiz
                        self.existingQuiz = quiz
                        self.isEditingExistingQuiz = true
                        self.selectedPDFName = quiz.info.title
                        print("Existing quiz found: \(quiz.id)")
                        self.showingCreateQuizView = true
                    }
                } else {
                    await MainActor.run {
                        // Set up for creating new quiz
                        self.existingQuiz = nil
                        self.isEditingExistingQuiz = false
                        self.selectedPDFName = quizTitle
                        print("No existing quiz found, creating new quiz with title: \(quizTitle)")
                        self.showingCreateQuizView = true
                    }
                }
            } catch {
                print("Error checking for existing quiz: \(error)")
                await MainActor.run {
                    errorMessage = "Failed to load quiz information: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
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
                // Refresh the list after deletion
                await loadInitialPDFs()
            } catch {
                errorMessage = error.localizedDescription
                showingErrorAlert = true
            }
        }
    }
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
   
struct QuizButtonView: View {
    let subcategory: String
    @State private var existingQuiz: Quiz?
    @State private var isLoading = true
    @State private var showingQuizView = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var viewId = UUID() // Add this for forcing view refresh
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                if let quiz = existingQuiz {
                    Button(action: {
                        showingQuizView = true
                    }) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                            Text("Edit Quiz")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(20)
                    .sheet(isPresented: $showingQuizView, onDismiss: {
                        // Refresh quiz data when returning from edit view
                        checkForExistingQuiz()
                    }) {
                        EditQuizView(viewModel: EditQuizViewModel(quiz: quiz), onSave: {
                            // This will be called when saving from EditQuizView
                            checkForExistingQuiz()
                        })
                    }
                } else {
                    Button(action: {
                        showingQuizView = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Quiz")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(20)
                    .sheet(isPresented: $showingQuizView, onDismiss: {
                        // Refresh quiz data when returning from create view
                        checkForExistingQuiz()
                    }) {
                        CreateQuizView(
                            viewModel: CreateQuizViewModel(
                                category: subcategory,
                                quizTitle: subcategory
                            )
                        )
                    }
                }
            }
        }
        .id(viewId) // Force view refresh when viewId changes
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .onAppear {
            checkForExistingQuiz()
        }
    }
    
    private func checkForExistingQuiz() {
        isLoading = true
        
        Task {
            do {
                let quiz = try await QuizManager.shared.getQuizForCategory(category: subcategory)
                
                await MainActor.run {
                    self.existingQuiz = quiz
                    self.isLoading = false
                    self.viewId = UUID() // Force view to refresh
                    print("Quiz check completed: \(quiz != nil ? "Found quiz" : "No quiz found") for \(subcategory)")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                    self.isLoading = false
                }
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
        @State private var refreshID = UUID()
        @State private var pendingPDFURL: URL? // Add this to track selected PDF
           @State private var hasPendingPDFChange = false // Add this to track if PDF was changed
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
                            VStack(spacing: 20) {
                                   // Category Section
                                   GroupBox(label:
                                       Label("Category Selection", systemImage: "folder")
                                           .font(.headline)
                                   ) {
                                       VStack(alignment: .leading, spacing: 15) {
                                           // Category Picker
                                           HStack {
                                               Text("Category:")
                                                   .foregroundColor(.secondary)
                                               Spacer()
                                               Picker("", selection: Binding(
                                                   get: { pdf.nameOfCategory },
                                                   set: {
                                                       pdf.nameOfCategory = $0
                                                       hasChanges = true
                                                   }
                                               )) {
                                                   ForEach(viewModel.uniqueCategories, id: \.self) { category in
                                                       Text(category).tag(category)
                                                   }
                                               }
                                               .pickerStyle(MenuPickerStyle())
                                               .accentColor(.blue)
                                           }
                                           
                                           Divider()
                                           
                                           // Subcategory Picker
                                           HStack {
                                               Text("SOP Title:")
                                                   .foregroundColor(.secondary)
                                               Spacer()
                                               Picker("", selection: Binding(
                                                   get: { pdf.SOPForStaffTittle },
                                                   set: {
                                                       pdf.SOPForStaffTittle = $0
                                                       hasChanges = true
                                                   }
                                               )) {
                                                   ForEach(viewModel.getSubcategories(for: pdf.nameOfCategory), id: \.self) { subcategory in
                                                       Text(subcategory).tag(subcategory)
                                                   }
                                               }
                                               .pickerStyle(MenuPickerStyle())
                                               .accentColor(.blue)
                                           }
                                       }
                                       .padding()
                                   }
                                   .padding(.horizontal)
                                   
                                   // PDF Information Section
                                   GroupBox(label:
                                       Label("PDF Information", systemImage: "doc.fill")
                                           .font(.headline)
                                   ) {
                                       VStack(alignment: .leading, spacing: 15) {
                                           HStack {
                                               Text("PDF Name:")
                                                   .foregroundColor(.secondary)
                                               Text(pdf.pdfName)
                                                   .bold()
                                           }
                                           
                                           Button(action: {
                                               showingPDFPicker = true
                                           }) {
                                               HStack {
                                                   Image(systemName: "arrow.up.doc.fill")
                                                   Text("Change PDF File")
                                               }
                                               .foregroundColor(.white)
                                               .frame(maxWidth: .infinity)
                                               .padding()
                                               .background(Color.blue)
                                               .cornerRadius(10)
                                           }
                                       }
                                       .padding()
                                   }
                                   .padding(.horizontal)
                               }
                            .padding(.horizontal)
                        }
                        
                        if isUploading {
                            ProgressView("Uploading...")
                                .padding()
                        }
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.fetchCategoriesIfNeeded()
                    }
                }
                .id(refreshID)  // Add this line
                .navigationTitle(pdf.pdfName)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: HStack(spacing: 15) {
                    if isEditing {
                        Button("Done") {
                            if hasChanges {
                                showingSaveConfirmation = true
                            } else {
                                isEditing.toggle()
                            }
                        }
                    } else {
                        HStack(spacing: 15) {
                            Button("Edit") {
                                isEditing.toggle()
                            }
                            
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                            }
                            .foregroundColor(.red)
                        }
                    }
                })
                .fileImporter(
                    isPresented: $showingPDFPicker,
                    allowedContentTypes: [.pdf],
                    allowsMultipleSelection: true
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
        
        private func handlePDFSelection(_ result: Result<[URL], Error>) {
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    // Start accessing the security-scoped resource
                    let securityScopedSuccess = url.startAccessingSecurityScopedResource()
                    
                    if !securityScopedSuccess {
                        errorMessage = "Permission denied: Cannot access the selected PDF file."
                        return
                    }
                    
                    // Just store the URL and mark changes
                    pendingPDFURL = url
                    hasPendingPDFChange = true
                    hasChanges = true
                    
                    // Update PDF preview only
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            // Load the PDF document
                            let document = PDFKit.PDFDocument(url: url)
                            
                            // Update UI on main thread
                            DispatchQueue.main.async {
                                self.pdfDocument = document
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.errorMessage = "Error loading PDF: \(error.localizedDescription)"
                            }
                        }
                    }
                    
                    // Note: Don't stop accessing resource here, as we need it for later
                    // The resource access will be stopped in saveChanges() after the file is uploaded
                }
            case .failure(let error):
                errorMessage = "Error selecting PDF: \(error.localizedDescription)"
            }
        }

        private func saveChanges() {
            Task {
                do {
                    isUploading = true
                    
                    // If there's a pending PDF change, handle it first
                    if hasPendingPDFChange, let url = pendingPDFURL {
                        do {
                            // The URL should still have access granted from handlePDFSelection
                            let pdfData = try Data(contentsOf: url)
                            let newPdfName = url.deletingPathExtension().lastPathComponent
                            pdf.pdfName = newPdfName
                            
                            let storageManager = PDFStorageManager.shared
                            let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
                            pdf.pdfURL = newURL
                            
                            // Now that we've uploaded the data, stop accessing the resource
                            url.stopAccessingSecurityScopedResource()
                        } catch {
                            await MainActor.run {
                                isUploading = false
                                showErrorAlert(message: "Error reading or uploading PDF: \(error.localizedDescription)")
                            }
                            return
                        }
                    }
                    
                    // Update category in Firestore
                    try await viewModel.updatePDFCategory(pdf)
                    
                    await MainActor.run {
                        isUploading = false
                        isEditing = false
                        hasChanges = false
                        hasPendingPDFChange = false
                        pendingPDFURL = nil
                        
                        // Refresh view
                        if let url = URL(string: pdf.pdfURL ?? "") {
                            pdfDocument = PDFKit.PDFDocument(url: url)
                        }
                        if let updatedPdf = viewModel.pdfCategories.first(where: { $0.id == pdf.id }) {
                            pdf = updatedPdf
                        }
                        showSuccessAlert(message: "Changes saved successfully")
                        self.refreshID = UUID()
                    }
                } catch {
                    await MainActor.run {
                        isUploading = false
                        showErrorAlert(message: "Error saving changes: \(error.localizedDescription)")
                    }
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
                    
                    // Update the PDF name from the new file
                    let newPdfName = url.deletingPathExtension().lastPathComponent
                    pdf.pdfName = newPdfName
                    
                    let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
                    
                    await MainActor.run {
                        pdf.pdfURL = newURL
                        pdfDocument = PDFKit.PDFDocument(url: URL(string: newURL)!)
                        isUploading = false
                        hasChanges = true
                        // Force view to refresh
                        self.pdf = pdf
                        self.refreshID = UUID()
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Error uploading PDF: \(error.localizedDescription)"
                        isUploading = false
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
