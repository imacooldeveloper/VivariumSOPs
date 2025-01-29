//
//  PDFCategoryListView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI
import Firebase
import PDFKit

////struct PDFCategoryListView: View {
////    @StateObject private var viewModel = PDFCategoryViewModel()
////    @State private var showingDeleteAlert = false
////    @State private var categoryToDelete: String?
////    @State private var showingPDFUploadView = false
////    @State private var isDeleting = false
////    @State private var showingAddCategorySheet = false
////    @State private var newCategoryTitle = ""
////    
////    
////    // Add these new state variables
////        @State private var alertTitle = ""
////        @State private var alertMessage = ""
////        @State private var showAlert = false
////    var body: some View {
////        ZStack {
////            Group {
////                if viewModel.isLoading {
////                    ProgressView("Loading categories...")
////                } else if viewModel.uniqueCategories.isEmpty {
////                    Text("No categories found")
////                } else {
////                    List {
////                        ForEach(viewModel.uniqueCategories, id: \.self) { category in
////                            NavigationLink(destination: SubcategoryView(category: category, viewModel: viewModel)) {
////                                Text(category)
////                            }
////                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
////                                Button(role: .destructive) {
////                                    isDeleting = true
////                                    Task {
////                                        do {
////                                            try await viewModel.deleteCategory(category)
////                                            isDeleting = false
////                                        } catch {
////                                            isDeleting = false
////                                            // Handle error here
////                                            print("Error deleting category: \(error.localizedDescription)")
////                                        }
////                                    }
////                                } label: {
////                                    Label("Delete", systemImage: "trash")
////                                }
////                            }
////                        }
////                    }
////                    .listStyle(InsetGroupedListStyle())
////                }
////            }
////            
////            VStack {
////                Spacer()
////                HStack {
////                    Spacer()
////                    Button(action: {
////                        showingAddCategorySheet = true
////                    }) {
////                        Image(systemName: "plus.circle.fill")
////                            .resizable()
////                            .frame(width: 60, height: 60)
////                            .foregroundColor(.blue)
////                            .background(Color.white)
////                            .clipShape(Circle())
////                            .shadow(radius: 4)
////                    }
////                    .padding(.trailing, 20)
////                    .padding(.bottom, 20)
////                }
////            }
////        }
////        .navigationTitle("PDF Categories")
////        .toolbar {
////            ToolbarItem(placement: .navigationBarTrailing) {
////                Button(action: {
////                    showingPDFUploadView = true
////                }) {
////                    Image(systemName: "plus")
////                }
////            }
////        }
////        .onAppear {
////            Task {
////                await viewModel.fetchCategoriesonHome()
////            }
////        }
////        .overlay(deleteAlertView)
////        .sheet(isPresented: $showingPDFUploadView) {
////            PDFUploadView(viewModel: viewModel)
////        }
////        .sheet(isPresented: $showingAddCategorySheet) {
////            addCategoryView
////        }
////        .alert(isPresented: $showAlert) {
////            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
////        }
////        
////    }
////    
////    private var addCategoryView: some View {
////        NavigationView {
////            Form {
////                Section(header: Text("New Category")) {
////                    TextField("Category Title", text: $newCategoryTitle)
////                }
////            }
////            .navigationTitle("Add Category")
////            .navigationBarItems(
////                leading: Button("Cancel") {
////                    showingAddCategorySheet = false
////                    newCategoryTitle = ""
////                },
////                trailing: Button("Save") {
////                    if !newCategoryTitle.isEmpty {
////                        Task {
////                            await viewModel.addCategory(newCategoryTitle)
////                            showingAddCategorySheet = false
////                            newCategoryTitle = ""
////                        }
////                    }
////                }
////            )
////        }
////    }
////    
////    private var deleteAlertView: some View {
////        Group {
////            if showingDeleteAlert, let category = categoryToDelete {
////                Color.black.opacity(0.4)
////                    .edgesIgnoringSafeArea(.all)
////                    .overlay(
////                        CustomAlertView(
////                            title: "Delete Category",
////                            message: "Are you sure you want to delete the category '\(category)' and all its contents?",
////                            primaryButton: AlertButton(title: "Delete", action: {
////                                deleteCategory(category)
////                            }),
////                            secondaryButton: AlertButton(title: "Cancel", action: {
////                                showingDeleteAlert = false
////                            })
////                        )
////                    )
////            }
////        }
////    }
////    
//////    private func deleteCategory(_ category: String) {
//////        isDeleting = true
//////        Task {
//////            await viewModel.deleteCategory(category)
//////            showingDeleteAlert = false
//////            isDeleting = false
//////        }
//////    }
//////    
////    private func deleteCategory(_ category: String) {
////        isDeleting = true
////        Task {
////            do {
////                try await viewModel.deleteCategory(category)
////                await MainActor.run {
////                    showingDeleteAlert = false
////                    isDeleting = false
////                    // Optionally, you might want to refresh your view here
////                }
////            } catch {
////                await MainActor.run {
////                    isDeleting = false
////                    // Show an error alert to the user
////                    alertTitle = "Error"
////                    alertMessage = "Failed to delete category: \(error.localizedDescription)"
////                    showAlert = true
////                }
////            }
////        }
////    }
////    
////    struct SubcategoryView: View {
////        let category: String
////        @ObservedObject var viewModel: PDFCategoryViewModel
////        
////        var body: some View {
////            List {
////                ForEach(viewModel.getSubcategories(for: category), id: \.self) { subcategory in
////                    NavigationLink(destination: LazyView(PDFListView(category: category, subcategory: subcategory, viewModel: viewModel))) {
////                        Text(subcategory)
////                    }
////                }
////            }
////            .listStyle(InsetGroupedListStyle())
////            .navigationTitle(category)
////        }
////    }
////    
////    struct LazyView<Content: View>: View {
////        let build: () -> Content
////        init(_ build: @autoclosure @escaping () -> Content) {
////            self.build = build
////        }
////        var body: Content {
////            build()
////        }
////    }
////}
////  
//struct PDFCategoryListView: View {
//    @StateObject private var viewModel = PDFCategoryViewModel()
//    @State private var showingDeleteAlert = false
//    @State private var categoryToDelete: String?
//    @State private var showingPDFUploadView = false
//    @State private var isDeleting = false
//    @State private var showingAddCategorySheet = false
//    @State private var newCategoryTitle = ""
//    @State private var deletionCode = ""
//    @State private var showingDeleteVerification = false
//    @State private var showingIncorrectCodeError = false
//    
//    private let correctDeletionCode = "12345"
//    
//    var body: some View {
//        ZStack {
//            Group {
//                if viewModel.isLoading {
//                    ProgressView("Loading categories...")
//                } else if viewModel.uniqueCategories.isEmpty {
//                    Text("No categories found")
//                } else {
//                    List {
//                        ForEach(viewModel.uniqueCategories, id: \.self) { category in
//                            NavigationLink(destination: SubcategoryView(category: category, viewModel: viewModel)) {
//                                Text(category)
//                            }
//                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                                Button(role: .destructive) {
//                                    categoryToDelete = category
//                                    showingDeleteVerification = true
//                                } label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            }
//                        }
//                    }
//                    .listStyle(InsetGroupedListStyle())
//                }
//            }
//            
//            // Add Category Button
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: { showingAddCategorySheet = true }) {
//                        Image(systemName: "plus.circle.fill")
//                            .resizable()
//                            .frame(width: 60, height: 60)
//                            .foregroundColor(.blue)
//                            .background(Color.white)
//                            .clipShape(Circle())
//                            .shadow(radius: 4)
//                    }
//                    .padding(.trailing, 20)
//                    .padding(.bottom, 20)
//                }
//            }
//        }
//        .navigationTitle("PDF Categories")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: { showingPDFUploadView = true }) {
//                    Image(systemName: "plus")
//                }
//            }
//        }
//        .sheet(isPresented: $showingPDFUploadView) {
//            PDFUploadView(viewModel: viewModel)
//        }
//        .sheet(isPresented: $showingAddCategorySheet) {
//            addCategoryView
//        }
//        .alert("Verification Required", isPresented: $showingDeleteVerification) {
//            TextField("Enter deletion code", text: $deletionCode)
//                .keyboardType(.numberPad)
//            Button("Delete", role: .destructive) {
//                verifyAndDelete()
//            }
//            Button("Cancel", role: .cancel) {
//                deletionCode = ""
//            }
//        } message: {
//            Text("Enter the deletion code to remove this category and all its contents.")
//        }
//        .alert("Incorrect Code", isPresented: $showingIncorrectCodeError) {
//            Button("OK", role: .cancel) {
//                deletionCode = ""
//            }
//        } message: {
//            Text("The deletion code entered was incorrect. Please try again.")
//        }
//    }
//    
//    private func verifyAndDelete() {
//        if deletionCode == correctDeletionCode {
//            if let category = categoryToDelete {
//                Task {
//                    do {
//                        try await viewModel.deleteCategory(category)
//                    } catch {
//                        print("Error deleting category: \(error)")
//                    }
//                }
//            }
//        } else {
//            showingIncorrectCodeError = true
//        }
//        deletionCode = ""
//    }
//    
//    private var addCategoryView: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("New Category")) {
//                    TextField("Category Title", text: $newCategoryTitle)
//                }
//            }
//            .navigationTitle("Add Category")
//            .navigationBarItems(
//                leading: Button("Cancel") {
//                    showingAddCategorySheet = false
//                    newCategoryTitle = ""
//                },
//                trailing: Button("Save") {
//                    if !newCategoryTitle.isEmpty {
//                        Task {
//                            await viewModel.addCategory(newCategoryTitle)
//                            showingAddCategorySheet = false
//                            newCategoryTitle = ""
//                        }
//                    }
//                }
//            )
//        }
//    }
//}
//struct SubcategoryView: View {
//    let category: String
//    @ObservedObject var viewModel: PDFCategoryViewModel
//    @State private var showingDeleteAlert = false
//    @State private var subcategoryToDelete: String?
//    @State private var deletionCode = ""
//    @State private var showingDeleteVerification = false
//    @State private var showingIncorrectCodeError = false
//    
//    private let correctDeletionCode = "12345"
//    
//    var body: some View {
//        List {
//            ForEach(viewModel.getSubcategories(for: category), id: \.self) { subcategory in
//                NavigationLink(destination: LazyView(PDFListView(category: category, subcategory: subcategory, viewModel: viewModel))) {
//                    Text(subcategory)
//                }
//                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                    Button(role: .destructive) {
//                        subcategoryToDelete = subcategory
//                        showingDeleteVerification = true
//                    } label: {
//                        Label("Delete", systemImage: "trash")
//                    }
//                }
//            }
//        }
//        .listStyle(InsetGroupedListStyle())
//        .navigationTitle(category)
//        .alert("Verification Required", isPresented: $showingDeleteVerification) {
//            TextField("Enter deletion code", text: $deletionCode)
//                .keyboardType(.numberPad)
//            Button("Delete", role: .destructive) {
//                verifyAndDelete()
//            }
//            Button("Cancel", role: .cancel) {
//                deletionCode = ""
//            }
//        } message: {
//            Text("Enter the deletion code to remove this subcategory and all its contents.")
//        }
//        .alert("Incorrect Code", isPresented: $showingIncorrectCodeError) {
//            Button("OK", role: .cancel) {
//                deletionCode = ""
//            }
//        } message: {
//            Text("The deletion code entered was incorrect. Please try again.")
//        }
//    }
//    
//    private func verifyAndDelete() {
//        if deletionCode == correctDeletionCode {
//            if let subcategory = subcategoryToDelete {
//                // Here you would implement the deletion of the subcategory
//                // This would need to be added to your ViewModel
//                print("Deleting subcategory: \(subcategory)")
//            }
//        } else {
//            showingIncorrectCodeError = true
//        }
//        deletionCode = ""
//    }
//}
//
//struct LazyView<Content: View>: View {
//    let build: () -> Content
//    init(_ build: @autoclosure @escaping () -> Content) {
//        self.build = build
//    }
//    var body: Content {
//        build()
//    }
//}
/////
/////working ast of sept 9
//    //struct PDFListView: View {
//    //    let category: String
//    //    let subcategory: String
//    //    @ObservedObject var viewModel: PDFCategoryViewModel
//    //    @State private var showingDeleteAlert = false
//    //    @State private var pdfToDelete: PDFCategory?
//    //    @State private var showingErrorAlert = false
//    //    @State private var errorMessage = ""
//    //    @State private var showingCreateQuizView = false
//    //    @State private var selectedPDFName: String?
//    //    @State private var quizCreationCount = 0
//    //    var filteredPDFs: [PDFCategory] {
//    //        let pdfs = viewModel.pdfCategories.filter { $0.nameOfCategory == category && $0.SOPForStaffTittle == subcategory }
//    //        print("Filtered PDFs for \(category) - \(subcategory): \(pdfs.count)")
//    //        return pdfs.sorted(by: { $0.pdfName < $1.pdfName })
//    //    }
//    //
//    //    var body: some View {
//    //        VStack {
//    //            if filteredPDFs.isEmpty {
//    //                Text("No PDFs found for this subcategory")
//    //                    .foregroundColor(.gray)
//    //            } else {
//    //                List {
//    //                    ForEach(filteredPDFs, id: \.id) { pdf in
//    //                        NavigationLink(destination: PDFDetailView(pdf: pdf, viewModel: viewModel)) {
//    //                            Text(pdf.pdfName)
//    //                        }
//    //                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//    //                            Button(role: .destructive) {
//    //                                pdfToDelete = pdf
//    //                                showingDeleteAlert = true
//    //                            } label: {
//    //                                Label("Delete", systemImage: "trash")
//    //                            }
//    //                        }
//    //                    }
//    //                }
//    //                .listStyle(InsetGroupedListStyle())
//    //            }
//    //        }
//    //        .navigationTitle(subcategory)
//    //
//    //            .toolbar {
//    //                      ToolbarItem(placement: .bottomBar) {
//    //                          CreateQuizButton(action: createQuiz, isDisabled: filteredPDFs.isEmpty)
//    //                      }
//    //                  }
//    //
//    //        .overlay(deleteAlert)
//    //        .alert("Error", isPresented: $showingErrorAlert, actions: {
//    //            Button("OK", role: .cancel) {}
//    //        }, message: {
//    //            Text(errorMessage)
//    //        })
//    //        .onAppear {
//    //            print("PDFListView appeared for \(category) - \(subcategory)")
//    //            print("Filtered PDFs: \(filteredPDFs.count)")
//    //        }
//    //        .sheet(isPresented: $showingCreateQuizView) {
//    //            CreateQuizView(viewModel: CreateQuizViewModel(category: subcategory, quizTitle: selectedPDFName ?? subcategory))
//    //
//    ////            let viewModel = CreateQuizViewModel(
//    ////                category: "Husbandry",
//    ////                subCategory: "What's the name",
//    ////                quizTitle: "H-H-06 HBS Mortalities",
//    ////                pdfName: "H-H-06 HBS Mortalities.pdf"
//    ////
//    ////            )
//    ////           CreateQuizView(viewModel: viewModel)
//    //                .onAppear {
//    //                    print("CreateQuizView sheet presented for category: \(subcategory), title: \(selectedPDFName ?? subcategory)")
//    //                }
//    //                .onDisappear {
//    //                    print("CreateQuizView sheet dismissed")
//    //                    self.selectedPDFName = nil
//    //                }
//    //        }
//    //    }
//    //
//    //    private func createQuiz() {
//    //           print("Create Quiz button tapped")
//    //           quizCreationCount += 1
//    //
//    //           let quizTitle: String
//    //           if quizCreationCount == 1, let firstPDF = filteredPDFs.first {
//    //               quizTitle = firstPDF.pdfName
//    //               print("Selected PDF: \(firstPDF.pdfName)")
//    //           } else {
//    //               quizTitle = subcategory
//    //               print("Using subcategory as quiz title: \(subcategory)")
//    //           }
//    //
//    //           selectedPDFName = quizTitle
//    //           showingCreateQuizView = true
//    //       }
//    //
//    //    private var deleteAlert: some View {
//    //        Group {
//    //            if showingDeleteAlert, let pdf = pdfToDelete {
//    //                Color.black.opacity(0.4)
//    //                    .edgesIgnoringSafeArea(.all)
//    //                    .overlay(
//    //                        CustomAlertView(
//    //                            title: "Delete PDF",
//    //                            message: "Are you sure you want to delete '\(pdf.pdfName)'?",
//    //                            primaryButton: AlertButton(title: "Delete", action: {
//    //                                deletePDF(pdf)
//    //                            }),
//    //                            secondaryButton: AlertButton(title: "Cancel", action: {
//    //                                showingDeleteAlert = false
//    //                            })
//    //                        )
//    //                    )
//    //            }
//    //        }
//    //    }
//    //
//    //    private func deletePDF(_ pdf: PDFCategory) {
//    //        Task {
//    //            do {
//    //                try await viewModel.deletePDF(pdf)
//    //                showingDeleteAlert = false
//    //            } catch {
//    //                errorMessage = error.localizedDescription
//    //                showingErrorAlert = true
//    //            }
//    //        }
//    //    }
//    //}
//    //
//    struct PDFListView: View {
//        let category: String
//        let subcategory: String
//        @ObservedObject var viewModel: PDFCategoryViewModel
//        @State private var showingDeleteAlert = false
//        @State private var pdfToDelete: PDFCategory?
//        @State private var showingErrorAlert = false
//        @State private var errorMessage = ""
//        @State private var showingCreateQuizView = false
//        @State private var selectedPDFName: String?
//        @State private var quizCreationCount = 0
//        @State private var refreshToggle = false // Add this line
//        @State private var isEditingExistingQuiz = false
//        @State private var existingQuiz: Quiz?
//        @State private var createQuizViewModel: CreateQuizViewModel?
//        @State private var hasUnsavedChanges = false
//         @State private var showingUnsavedChangesAlert = false
//        var filteredPDFs: [PDFCategory] {
//            let pdfs = viewModel.pdfCategories.filter { $0.nameOfCategory == category && $0.SOPForStaffTittle == subcategory }
//            print("Filtered PDFs for \(category) - \(subcategory): \(pdfs.count)")
//            return pdfs.sorted(by: { $0.pdfName < $1.pdfName })
//        }
//        
//        var body: some View {
//            VStack {
//                if filteredPDFs.isEmpty {
//                    Text("No PDFs found for this subcategory")
//                        .foregroundColor(.gray)
//                } else {
//                    List {
//                        ForEach(filteredPDFs, id: \.id) { pdf in
//                            NavigationLink(destination: PDFDetailView(pdf: pdf, viewModel: viewModel)) {
//                                Text(pdf.pdfName)
//                            }
//                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                                Button(role: .destructive) {
//                                    pdfToDelete = pdf
//                                    showingDeleteAlert = true
//                                } label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            }
//                        }
//                    }
//                    .listStyle(InsetGroupedListStyle())
//                }
//            }
//            .navigationTitle(subcategory)
//            .toolbar {
//                ToolbarItem(placement: .bottomBar) {
//                    CreateQuizButton(action: createQuiz, isDisabled: filteredPDFs.isEmpty)
//                }
//            }
//            .overlay(deleteAlert)
//            .alert("Error", isPresented: $showingErrorAlert, actions: {
//                Button("OK", role: .cancel) {}
//            }, message: {
//                Text(errorMessage)
//            })
//            .onAppear {
//                print("PDFListView appeared for \(category) - \(subcategory)")
//                print("Filtered PDFs: \(filteredPDFs.count)")
//            }
//            // Updated section of PDFListView
//            .fullScreenCover(isPresented: $showingCreateQuizView) {
//                if isEditingExistingQuiz, let quiz = existingQuiz {
//                    EditQuizView(viewModel: EditQuizViewModel(quiz: quiz))
//                } else {
//                    if let selectedPDF = filteredPDFs.first(where: { $0.pdfName == selectedPDFName }) {
//                        
//                        Text("DImelo")
////                        CreateQuizView(
////                            viewModel: CreateQuizViewModel(category: subcategory, quizTitle: selectedPDFName ?? subcategory),
////                            hasUnsavedChanges: $hasUnsavedChanges,
////                            document: {
////                                if let pdfURL = URL(string: selectedPDF.pdfURL ?? ""),
////                                   let document = PDFDocument(url: pdfURL) {
////                                    return document
////                                }
////                                return PDFDocument()
////                            }()
////                        )
//                    } else {
//                        // Fallback if no PDF is selected
//                        CreateQuizView(
//                            viewModel: CreateQuizViewModel(category: subcategory, quizTitle: subcategory),
//                            hasUnsavedChanges: $hasUnsavedChanges,
//                            document: PDFDocument()
//                        )
//                    }
//                }
//            }
//                  .onAppear {
//                      print("Quiz view presented for category: \(subcategory), title: \(selectedPDFName ?? subcategory), editing: \(isEditingExistingQuiz)")
//                  }
//                  .onDisappear {
//                      print("Quiz view dismissed")
//                      self.selectedPDFName = nil
//                      self.isEditingExistingQuiz = false
//                      self.existingQuiz = nil
//                      self.refreshToggle.toggle()
//                  }
//                  .alert("Unsaved Changes", isPresented: $showingUnsavedChangesAlert) {
//                             Button("Discard Changes", role: .destructive) {
//                                 hasUnsavedChanges = false
//                                 showingCreateQuizView = false
//                             }
//                             Button("Continue Editing", role: .cancel) {}
//                         } message: {
//                             Text("You have unsaved changes. Are you sure you want to leave?")
//                         }
//                     }
//     
//        
//        private func createQuiz() {
//            print("Create Quiz button tapped")
//            
//            // Select the first PDF if none is selected
//            if selectedPDFName == nil, let firstPDF = filteredPDFs.first {
//                selectedPDFName = firstPDF.pdfName
//            }
//            
//            let quizTitle = selectedPDFName ?? subcategory
//            print("Selected quiz title: \(quizTitle)")
//            
//            Task {
//                do {
//                    if let quiz = try await QuizManager.shared.getQuizForCategory(category: quizTitle) {
//                        await MainActor.run {
//                            existingQuiz = quiz
//                            isEditingExistingQuiz = true
//                            selectedPDFName = quiz.info.title
//                            print("Existing quiz found: \(quiz.id)")
//                        }
//                    } else {
//                        await MainActor.run {
//                            existingQuiz = nil
//                            isEditingExistingQuiz = false
//                            print("No existing quiz found for title: \(quizTitle)")
//                        }
//                    }
//                    
//                    await MainActor.run {
//                        showingCreateQuizView = true
//                    }
//                } catch {
//                    print("Error checking for existing quiz: \(error)")
//                    await MainActor.run {
//                        errorMessage = "Failed to load quiz information: \(error.localizedDescription)"
//                        showingErrorAlert = true
//                    }
//                }
//            }
//        }
//        private var deleteAlert: some View {
//            Group {
//                if showingDeleteAlert, let pdf = pdfToDelete {
//                    Color.black.opacity(0.4)
//                        .edgesIgnoringSafeArea(.all)
//                        .overlay(
//                            CustomAlertView(
//                                title: "Delete PDF",
//                                message: "Are you sure you want to delete '\(pdf.pdfName)'?",
//                                primaryButton: AlertButton(title: "Delete", action: {
//                                    deletePDF(pdf)
//                                }),
//                                secondaryButton: AlertButton(title: "Cancel", action: {
//                                    showingDeleteAlert = false
//                                })
//                            )
//                        )
//                }
//            }
//        }
//        
//        private func deletePDF(_ pdf: PDFCategory) {
//            Task {
//                do {
//                    try await viewModel.deletePDF(pdf)
//                    showingDeleteAlert = false
//                } catch {
//                    errorMessage = error.localizedDescription
//                    showingErrorAlert = true
//                }
//            }
//        }
//        
//        
//        // ... rest of the code remains the same
//    }
//    
//    struct FetchQuizView: View {
//        let quizId: String
//        @State private var quiz: Quiz?
//        @State private var isLoading = true
//        @State private var error: Error?
//        
//        var body: some View {
//            Group {
//                if isLoading {
//                    ProgressView("Loading quiz...")
//                } else if let quiz = quiz {
//                    EditQuizView(viewModel: EditQuizViewModel(quiz: quiz))
//                } else if let error = error {
//                    Text("Error loading quiz: \(error.localizedDescription)")
//                }
//            }
//            .onAppear {
//                fetchQuiz()
//            }
//        }
//        
//        private func fetchQuiz() {
//            Task {
//                do {
//                    self.quiz = try await QuizManager.shared.getQuiz(id: quizId)
//                    self.isLoading = false
//                } catch {
//                    self.error = error
//                    self.isLoading = false
//                }
//            }
//        }
//    }
//    struct PDFDetailView: View {
//        @Environment(\.presentationMode) var presentationMode
//        @State private var pdf: PDFCategory
//        @ObservedObject var viewModel: PDFCategoryViewModel
//        @State private var isEditing = false
//        @State private var showingPDFPicker = false
//        @State private var pdfDocument: PDFKit.PDFDocument?
//        @State private var errorMessage: String?
//        @State private var isUploading = false
//        @State private var showAlert = false
//        @State private var alertTitle = ""
//        @State private var alertMessage = ""
//        @State private var isSuccess = false
//        @State private var hasChanges = false
//        @State private var showingSaveConfirmation = false
//        @State private var showingDeleteConfirmation = false
//        @State private var isDeleting = false
//        @State private var showingErrorAlert = false
//        @State private var refreshID = UUID()
//        @State private var pendingPDFURL: URL? // Add this to track selected PDF
//           @State private var hasPendingPDFChange = false // Add this to track if PDF was changed
//        init(pdf: PDFCategory, viewModel: PDFCategoryViewModel) {
//            _pdf = State(initialValue: pdf)
//            self.viewModel = viewModel
//            _pdfDocument = State(initialValue: PDFKit.PDFDocument(url: URL(string: pdf.pdfURL ?? "")!))
//        }
//        
//        var body: some View {
//            ZStack {
//                ScrollView {
//                    VStack(spacing: 20) {
//                        PDFKitRepresentedView(document: pdfDocument)
//                            .frame(height: 900)  // Adjust this height as needed
//                        
//                        if isEditing {
//                            VStack(spacing: 20) {
//                                   // Category Section
//                                   GroupBox(label:
//                                       Label("Category Selection", systemImage: "folder")
//                                           .font(.headline)
//                                   ) {
//                                       VStack(alignment: .leading, spacing: 15) {
//                                           // Category Picker
//                                           HStack {
//                                               Text("Category:")
//                                                   .foregroundColor(.secondary)
//                                               Spacer()
//                                               Picker("", selection: Binding(
//                                                   get: { pdf.nameOfCategory },
//                                                   set: {
//                                                       pdf.nameOfCategory = $0
//                                                       hasChanges = true
//                                                   }
//                                               )) {
//                                                   ForEach(viewModel.uniqueCategories, id: \.self) { category in
//                                                       Text(category).tag(category)
//                                                   }
//                                               }
//                                               .pickerStyle(MenuPickerStyle())
//                                               .accentColor(.blue)
//                                           }
//                                           
//                                           Divider()
//                                           
//                                           // Subcategory Picker
//                                           HStack {
//                                               Text("SOP Title:")
//                                                   .foregroundColor(.secondary)
//                                               Spacer()
//                                               Picker("", selection: Binding(
//                                                   get: { pdf.SOPForStaffTittle },
//                                                   set: {
//                                                       pdf.SOPForStaffTittle = $0
//                                                       hasChanges = true
//                                                   }
//                                               )) {
//                                                   ForEach(viewModel.getSubcategories(for: pdf.nameOfCategory), id: \.self) { subcategory in
//                                                       Text(subcategory).tag(subcategory)
//                                                   }
//                                               }
//                                               .pickerStyle(MenuPickerStyle())
//                                               .accentColor(.blue)
//                                           }
//                                       }
//                                       .padding()
//                                   }
//                                   .padding(.horizontal)
//                                   
//                                   // PDF Information Section
//                                   GroupBox(label:
//                                       Label("PDF Information", systemImage: "doc.fill")
//                                           .font(.headline)
//                                   ) {
//                                       VStack(alignment: .leading, spacing: 15) {
//                                           HStack {
//                                               Text("PDF Name:")
//                                                   .foregroundColor(.secondary)
//                                               Text(pdf.pdfName)
//                                                   .bold()
//                                           }
//                                           
//                                           Button(action: {
//                                               showingPDFPicker = true
//                                           }) {
//                                               HStack {
//                                                   Image(systemName: "arrow.up.doc.fill")
//                                                   Text("Change PDF File")
//                                               }
//                                               .foregroundColor(.white)
//                                               .frame(maxWidth: .infinity)
//                                               .padding()
//                                               .background(Color.blue)
//                                               .cornerRadius(10)
//                                           }
//                                       }
//                                       .padding()
//                                   }
//                                   .padding(.horizontal)
//                               }
//                            .padding(.horizontal)
//                        }
//                        
//                        if isUploading {
//                            ProgressView("Uploading...")
//                                .padding()
//                        }
//                    }
//                }
//                .onAppear {
//                    Task {
//                        await viewModel.fetchCategoriesIfNeeded()
//                    }
//                }
//                .id(refreshID)  // Add this line
//                .navigationTitle(pdf.pdfName)
//                .navigationBarTitleDisplayMode(.inline)
//                .navigationBarItems(trailing: HStack(spacing: 15) {
//                    if isEditing {
//                        Button("Done") {
//                            if hasChanges {
//                                showingSaveConfirmation = true
//                            } else {
//                                isEditing.toggle()
//                            }
//                        }
//                    } else {
//                        HStack(spacing: 15) {
//                            Button("Edit") {
//                                isEditing.toggle()
//                            }
//                            
//                            Button(action: {
//                                showingDeleteConfirmation = true
//                            }) {
//                                Image(systemName: "trash")
//                            }
//                            .foregroundColor(.red)
//                        }
//                    }
//                })
//                .fileImporter(
//                    isPresented: $showingPDFPicker,
//                    allowedContentTypes: [.pdf],
//                    allowsMultipleSelection: true
//                ) { result in
//                    handlePDFSelection(result)
//                }
//                
//                if showingSaveConfirmation {
//                    Color.black.opacity(0.4)
//                        .edgesIgnoringSafeArea(.all)
//                        .overlay(
//                            CustomAlertView(
//                                title: "Save Changes",
//                                message: "Do you want to save the changes?",
//                                primaryButton: AlertButton(title: "Save", action: {
//                                    saveChanges()
//                                    showingSaveConfirmation = false
//                                }),
//                                secondaryButton: AlertButton(title: "Discard", action: {
//                                    isEditing = false
//                                    hasChanges = false
//                                    showingSaveConfirmation = false
//                                }),
//                                dismissButton: AlertButton(title: "Cancel", action: {
//                                    showingSaveConfirmation = false
//                                })
//                            )
//                        )
//                }
//                if showingDeleteConfirmation {
//                    Color.black.opacity(0.4)
//                        .edgesIgnoringSafeArea(.all)
//                        .overlay(
//                            CustomAlertView(
//                                title: "Delete PDF",
//                                message: "Are you sure you want to delete this PDF?",
//                                primaryButton: AlertButton(title: "Delete", action: {
//                                    deletePDF()
//                                    showingDeleteConfirmation = false
//                                }),
//                                secondaryButton: AlertButton(title: "Cancel", action: {
//                                    showingDeleteConfirmation = false
//                                })
//                            )
//                        )
//                }
//                if showAlert {
//                    Color.black.opacity(0.4)
//                        .edgesIgnoringSafeArea(.all)
//                        .overlay(
//                            CustomAlertView(
//                                title: alertTitle,
//                                message: alertMessage,
//                                primaryButton: AlertButton(title: "OK", action: {
//                                    showAlert = false
//                                    if isSuccess {
//                                        presentationMode.wrappedValue.dismiss()
//                                    }
//                                }),
//                                secondaryButton: nil,
//                                dismissButton: AlertButton(title: "Cancel", action: {
//                                    showAlert = false
//                                })
//                            )
//                        )
//                }
//            }
//            
//        }
//        
////        private func handlePDFSelection(_ result: Result<[URL], Error>) {
////            switch result {
////            case .success(let urls):
////                if let url = urls.first {
////                    updatePDF(url: url)
////                }
////            case .failure(let error):
////                errorMessage = "Error selecting PDF: \(error.localizedDescription)"
////            }
////        }
//        private func deletePDF() {
//            Task {
//                do {
//                    try await viewModel.deletePDF(pdf)
//                    showSuccessAlert(message: "PDF deleted successfully")
//                } catch {
//                    showErrorAlert(message: "Error deleting PDF: \(error.localizedDescription)")
//                }
//            }
//        }
//        
//        //    private func updatePDF(url: URL) {
//        //        isUploading = true
//        //        errorMessage = nil
//        //
//        //        Task {
//        //            do {
//        //                let pdfData = try Data(contentsOf: url)
//        //                let storageManager = PDFStorageManager.shared
//        //                let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
//        //
//        //                await MainActor.run {
//        //                    pdf.pdfURL = newURL
//        //                    pdfDocument = PDFKit.PDFDocument(url: url)
//        //                    isUploading = false
//        //                    hasChanges = true
//        //                }
//        //            } catch {
//        //                await MainActor.run {
//        //                    errorMessage = "Error uploading PDF: \(error.localizedDescription)"
//        //                    isUploading = false
//        //                }
//        //            }
//        //        }
//        //    }
//        //
//        //    private func saveChanges() {
//        //        Task {
//        //            do {
//        //                try await viewModel.updatePDFCategory(pdf)
//        //                await MainActor.run {
//        //                    isEditing = false
//        //                    hasChanges = false
//        //                    showSuccessAlert(message: "Changes saved successfully")
//        //                }
//        //            } catch {
//        //                await MainActor.run {
//        //                    showErrorAlert(message: "Error saving changes: \(error.localizedDescription)")
//        //                }
//        //            }
//        //        }
//        //    }
//        // Modify saveChanges:
//            private func saveChanges() {
//                Task {
//                    do {
//                        isUploading = true
//                        
//                        // If there's a pending PDF change, handle it first
//                        if hasPendingPDFChange, let url = pendingPDFURL {
//                            let pdfData = try Data(contentsOf: url)
//                            let newPdfName = url.deletingPathExtension().lastPathComponent
//                            pdf.pdfName = newPdfName
//                            
//                            let storageManager = PDFStorageManager.shared
//                            let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
//                            pdf.pdfURL = newURL
//                        }
//                        
//                        // Update category in Firestore
//                        try await viewModel.updatePDFCategory(pdf)
//                        
//                        await MainActor.run {
//                            isUploading = false
//                            isEditing = false
//                            hasChanges = false
//                            hasPendingPDFChange = false
//                            pendingPDFURL = nil
//                            
//                            // Refresh view
//                            if let url = URL(string: pdf.pdfURL ?? "") {
//                                pdfDocument = PDFKit.PDFDocument(url: url)
//                            }
//                            if let updatedPdf = viewModel.pdfCategories.first(where: { $0.id == pdf.id }) {
//                                pdf = updatedPdf
//                            }
//                            showSuccessAlert(message: "Changes saved successfully")
//                            self.refreshID = UUID()
//                        }
//                    } catch {
//                        await MainActor.run {
//                            isUploading = false
//                            showErrorAlert(message: "Error saving changes: \(error.localizedDescription)")
//                        }
//                    }
//                }
//            }
//        private func handlePDFSelection(_ result: Result<[URL], Error>) {
//               switch result {
//               case .success(let urls):
//                   if let url = urls.first {
//                       // Just store the URL and mark changes
//                       pendingPDFURL = url
//                       hasPendingPDFChange = true
//                       hasChanges = true
//                       
//                       // Update PDF preview only
//                       DispatchQueue.global(qos: .userInitiated).async {
//                           let document = PDFKit.PDFDocument(url: url)
//                           DispatchQueue.main.async {
//                               self.pdfDocument = document
//                           }
//                       }
//                   }
//               case .failure(let error):
//                   errorMessage = "Error selecting PDF: \(error.localizedDescription)"
//               }
//           }
////        private func updatePDF(url: URL) {
////            isUploading = true
////            errorMessage = nil
////            
////            Task {
////                do {
////                    let pdfData = try Data(contentsOf: url)
////                    let storageManager = PDFStorageManager.shared
////                    let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
////                    
////                    await MainActor.run {
////                        pdf.pdfURL = newURL
////                        pdfDocument = PDFKit.PDFDocument(url: URL(string: newURL)!)
////                        isUploading = false
////                        hasChanges = true
////                        // Force view to refresh
////                        self.pdf = pdf
////                        self.refreshID = UUID()
////                    }
////                } catch {
////                    await MainActor.run {
////                        errorMessage = "Error uploading PDF: \(error.localizedDescription)"
////                        isUploading = false
////                    }
////                }
////            }
////        }
////     
//        private func updatePDF(url: URL) {
//            isUploading = true
//            errorMessage = nil
//            
//            Task {
//                do {
//                    let pdfData = try Data(contentsOf: url)
//                    let storageManager = PDFStorageManager.shared
//                    
//                    // Update the PDF name from the new file
//                    let newPdfName = url.deletingPathExtension().lastPathComponent
//                    pdf.pdfName = newPdfName
//                    
//                    let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
//                    
//                    await MainActor.run {
//                        pdf.pdfURL = newURL
//                        pdfDocument = PDFKit.PDFDocument(url: URL(string: newURL)!)
//                        isUploading = false
//                        hasChanges = true
//                        // Force view to refresh
//                        self.pdf = pdf
//                        self.refreshID = UUID()
//                    }
//                } catch {
//                    await MainActor.run {
//                        errorMessage = "Error uploading PDF: \(error.localizedDescription)"
//                        isUploading = false
//                    }
//                }
//            }
//        }
//        
//        private func showSuccessAlert(message: String) {
//            alertTitle = "Success"
//            alertMessage = message
//            isSuccess = true
//            showAlert = true
//        }
//        
//        private func showErrorAlert(message: String) {
//            alertTitle = "Error"
//            alertMessage = message
//            isSuccess = false
//            showAlert = true
//        }
//    }
//    
//    struct PDFKitRepresentedView: UIViewRepresentable {
//        let document: PDFKit.PDFDocument?
//        
//        func makeUIView(context: Context) -> PDFView {
//            let pdfView = PDFView()
//            pdfView.autoScales = true
//            pdfView.document = document
//            
//            return pdfView
//        }
//        
//        func updateUIView(_ uiView: PDFView, context: Context) {
//            
//            uiView.document = document
//        }
//    }
//



//
//  PDFCategoryListView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI
import Firebase
import PDFKit

//struct PDFCategoryListView: View {
//    @StateObject private var viewModel = PDFCategoryViewModel()
//    @State private var showingDeleteAlert = false
//    @State private var categoryToDelete: String?
//    @State private var showingPDFUploadView = false
//    @State private var isDeleting = false
//    @State private var showingAddCategorySheet = false
//    @State private var newCategoryTitle = ""
//
//
//    // Add these new state variables
//        @State private var alertTitle = ""
//        @State private var alertMessage = ""
//        @State private var showAlert = false
//    var body: some View {
//        ZStack {
//            Group {
//                if viewModel.isLoading {
//                    ProgressView("Loading categories...")
//                } else if viewModel.uniqueCategories.isEmpty {
//                    Text("No categories found")
//                } else {
//                    List {
//                        ForEach(viewModel.uniqueCategories, id: \.self) { category in
//                            NavigationLink(destination: SubcategoryView(category: category, viewModel: viewModel)) {
//                                Text(category)
//                            }
//                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                                Button(role: .destructive) {
//                                    isDeleting = true
//                                    Task {
//                                        do {
//                                            try await viewModel.deleteCategory(category)
//                                            isDeleting = false
//                                        } catch {
//                                            isDeleting = false
//                                            // Handle error here
//                                            print("Error deleting category: \(error.localizedDescription)")
//                                        }
//                                    }
//                                } label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            }
//                        }
//                    }
//                    .listStyle(InsetGroupedListStyle())
//                }
//            }
//
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        showingAddCategorySheet = true
//                    }) {
//                        Image(systemName: "plus.circle.fill")
//                            .resizable()
//                            .frame(width: 60, height: 60)
//                            .foregroundColor(.blue)
//                            .background(Color.white)
//                            .clipShape(Circle())
//                            .shadow(radius: 4)
//                    }
//                    .padding(.trailing, 20)
//                    .padding(.bottom, 20)
//                }
//            }
//        }
//        .navigationTitle("PDF Categories")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    showingPDFUploadView = true
//                }) {
//                    Image(systemName: "plus")
//                }
//            }
//        }
//        .onAppear {
//            Task {
//                await viewModel.fetchCategoriesonHome()
//            }
//        }
//        .overlay(deleteAlertView)
//        .sheet(isPresented: $showingPDFUploadView) {
//            PDFUploadView(viewModel: viewModel)
//        }
//        .sheet(isPresented: $showingAddCategorySheet) {
//            addCategoryView
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//        }
//
//    }
//
//    private var addCategoryView: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("New Category")) {
//                    TextField("Category Title", text: $newCategoryTitle)
//                }
//            }
//            .navigationTitle("Add Category")
//            .navigationBarItems(
//                leading: Button("Cancel") {
//                    showingAddCategorySheet = false
//                    newCategoryTitle = ""
//                },
//                trailing: Button("Save") {
//                    if !newCategoryTitle.isEmpty {
//                        Task {
//                            await viewModel.addCategory(newCategoryTitle)
//                            showingAddCategorySheet = false
//                            newCategoryTitle = ""
//                        }
//                    }
//                }
//            )
//        }
//    }
//
//    private var deleteAlertView: some View {
//        Group {
//            if showingDeleteAlert, let category = categoryToDelete {
//                Color.black.opacity(0.4)
//                    .edgesIgnoringSafeArea(.all)
//                    .overlay(
//                        CustomAlertView(
//                            title: "Delete Category",
//                            message: "Are you sure you want to delete the category '\(category)' and all its contents?",
//                            primaryButton: AlertButton(title: "Delete", action: {
//                                deleteCategory(category)
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
////    private func deleteCategory(_ category: String) {
////        isDeleting = true
////        Task {
////            await viewModel.deleteCategory(category)
////            showingDeleteAlert = false
////            isDeleting = false
////        }
////    }
////
//    private func deleteCategory(_ category: String) {
//        isDeleting = true
//        Task {
//            do {
//                try await viewModel.deleteCategory(category)
//                await MainActor.run {
//                    showingDeleteAlert = false
//                    isDeleting = false
//                    // Optionally, you might want to refresh your view here
//                }
//            } catch {
//                await MainActor.run {
//                    isDeleting = false
//                    // Show an error alert to the user
//                    alertTitle = "Error"
//                    alertMessage = "Failed to delete category: \(error.localizedDescription)"
//                    showAlert = true
//                }
//            }
//        }
//    }
//
//    struct SubcategoryView: View {
//        let category: String
//        @ObservedObject var viewModel: PDFCategoryViewModel
//
//        var body: some View {
//            List {
//                ForEach(viewModel.getSubcategories(for: category), id: \.self) { subcategory in
//                    NavigationLink(destination: LazyView(PDFListView(category: category, subcategory: subcategory, viewModel: viewModel))) {
//                        Text(subcategory)
//                    }
//                }
//            }
//            .listStyle(InsetGroupedListStyle())
//            .navigationTitle(category)
//        }
//    }
//
//    struct LazyView<Content: View>: View {
//        let build: () -> Content
//        init(_ build: @autoclosure @escaping () -> Content) {
//            self.build = build
//        }
//        var body: Content {
//            build()
//        }
//    }
//}
//
struct PDFCategoryListView: View {
    @StateObject private var viewModel = PDFCategoryViewModel()
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
            
            // Add Category Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddCategorySheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("PDF Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingPDFUploadView = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingPDFUploadView) {
            PDFUploadView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddCategorySheet) {
            addCategoryView
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
            Text("Enter the deletion code to remove this category and all its contents.")
        }
        .alert("Incorrect Code", isPresented: $showingIncorrectCodeError) {
            Button("OK", role: .cancel) {
                deletionCode = ""
            }
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
    
    private var addCategoryView: some View {
        NavigationView {
            Form {
                Section(header: Text("New Category")) {
                    TextField("Category Title", text: $newCategoryTitle)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingAddCategorySheet = false
                    newCategoryTitle = ""
                },
                trailing: Button("Save") {
                    if !newCategoryTitle.isEmpty {
                        Task {
                            await viewModel.addCategory(newCategoryTitle)
                            showingAddCategorySheet = false
                            newCategoryTitle = ""
                        }
                    }
                }
            )
        }
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
    
    private let correctDeletionCode = "12345"
    
    var body: some View {
        List {
            ForEach(viewModel.getSubcategories(for: category), id: \.self) { subcategory in
                NavigationLink(destination: LazyView(PDFListView(category: category, subcategory: subcategory, viewModel: viewModel))) {
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
        .navigationTitle(category)
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
    }
    
    private func verifyAndDelete() {
        if deletionCode == correctDeletionCode {
            if let subcategory = subcategoryToDelete {
                // Here you would implement the deletion of the subcategory
                // This would need to be added to your ViewModel
                print("Deleting subcategory: \(subcategory)")
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
///
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
        @State private var createQuizViewModel: CreateQuizViewModel?
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
             
                      if isEditingExistingQuiz, let quiz = existingQuiz {
                          EditQuizView(viewModel: EditQuizViewModel(quiz: quiz))
                      } else {
                          CreateQuizView(viewModel: CreateQuizViewModel(category: subcategory, quizTitle: selectedPDFName ?? subcategory))
                      }
                  
                  
//                  .onDisappear {
//                      print("Quiz view dismissed")
//                      self.selectedPDFName = nil
//                      self.isEditingExistingQuiz = false
//                      self.existingQuiz = nil
//                      self.refreshToggle.toggle()
//                  }
            }
            //.id(refreshToggle) // Add this line
        }
        
//        private func createQuiz() {
//            print("Create Quiz button tapped")
//            quizCreationCount += 1
//
//            let quizTitle: String
//            if quizCreationCount == 1, let firstPDF = filteredPDFs.first {
//                quizTitle = firstPDF.pdfName
//                print("Selected PDF: \(firstPDF.pdfName)")
//            } else {
//                quizTitle = subcategory
//                print("Using subcategory as quiz title: \(subcategory)")
//            }
//
//            selectedPDFName = quizTitle
//
//            Task {
//                do {
//                    if let quiz = try await QuizManager.shared.getQuizForCategory(category: quizTitle) {
//                        existingQuiz = quiz
//                        isEditingExistingQuiz = true
//                        print("Existing quiz found: \(quiz.id)")
//                    } else {
//                        existingQuiz = nil
//                        isEditingExistingQuiz = false
//                        print("No existing quiz found")
//                    }
//                    showingCreateQuizView = true
//                } catch {
//                    print("Error checking for existing quiz: \(error)")
//                    // Handle the error appropriately
//                }
//            }
//        }
        
        private func createQuiz() {
            print("Create Quiz button tapped")
            
            let quizTitle = selectedPDFName ?? subcategory
            print("Selected quiz title: \(quizTitle)")
            
            Task {
                do {
                    if let quiz = try await QuizManager.shared.getQuizForCategory(category: quizTitle) {
                        await MainActor.run {
                            existingQuiz = quiz
                            isEditingExistingQuiz = true
                            selectedPDFName = quiz.info.title
                            print("Existing quiz found: \(quiz.id)")
                        }
                    } else {
                        await MainActor.run {
                            existingQuiz = nil
                            isEditingExistingQuiz = false
                            selectedPDFName = quizTitle
                            print("No existing quiz found for title: \(quizTitle)")
                        }
                    }
                    
                    await MainActor.run {
                        showingCreateQuizView = true
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
        
//        private func handlePDFSelection(_ result: Result<[URL], Error>) {
//            switch result {
//            case .success(let urls):
//                if let url = urls.first {
//                    updatePDF(url: url)
//                }
//            case .failure(let error):
//                errorMessage = "Error selecting PDF: \(error.localizedDescription)"
//            }
//        }
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
        
        //    private func updatePDF(url: URL) {
        //        isUploading = true
        //        errorMessage = nil
        //
        //        Task {
        //            do {
        //                let pdfData = try Data(contentsOf: url)
        //                let storageManager = PDFStorageManager.shared
        //                let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
        //
        //                await MainActor.run {
        //                    pdf.pdfURL = newURL
        //                    pdfDocument = PDFKit.PDFDocument(url: url)
        //                    isUploading = false
        //                    hasChanges = true
        //                }
        //            } catch {
        //                await MainActor.run {
        //                    errorMessage = "Error uploading PDF: \(error.localizedDescription)"
        //                    isUploading = false
        //                }
        //            }
        //        }
        //    }
        //
        //    private func saveChanges() {
        //        Task {
        //            do {
        //                try await viewModel.updatePDFCategory(pdf)
        //                await MainActor.run {
        //                    isEditing = false
        //                    hasChanges = false
        //                    showSuccessAlert(message: "Changes saved successfully")
        //                }
        //            } catch {
        //                await MainActor.run {
        //                    showErrorAlert(message: "Error saving changes: \(error.localizedDescription)")
        //                }
        //            }
        //        }
        //    }
        // Modify saveChanges:
            private func saveChanges() {
                Task {
                    do {
                        isUploading = true
                        
                        // If there's a pending PDF change, handle it first
                        if hasPendingPDFChange, let url = pendingPDFURL {
                            let pdfData = try Data(contentsOf: url)
                            let newPdfName = url.deletingPathExtension().lastPathComponent
                            pdf.pdfName = newPdfName
                            
                            let storageManager = PDFStorageManager.shared
                            let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
                            pdf.pdfURL = newURL
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
        private func handlePDFSelection(_ result: Result<[URL], Error>) {
               switch result {
               case .success(let urls):
                   if let url = urls.first {
                       // Just store the URL and mark changes
                       pendingPDFURL = url
                       hasPendingPDFChange = true
                       hasChanges = true
                       
                       // Update PDF preview only
                       DispatchQueue.global(qos: .userInitiated).async {
                           let document = PDFKit.PDFDocument(url: url)
                           DispatchQueue.main.async {
                               self.pdfDocument = document
                           }
                       }
                   }
               case .failure(let error):
                   errorMessage = "Error selecting PDF: \(error.localizedDescription)"
               }
           }
//        private func updatePDF(url: URL) {
//            isUploading = true
//            errorMessage = nil
//
//            Task {
//                do {
//                    let pdfData = try Data(contentsOf: url)
//                    let storageManager = PDFStorageManager.shared
//                    let newURL = try await storageManager.uploadPDF(data: pdfData, category: pdf)
//
//                    await MainActor.run {
//                        pdf.pdfURL = newURL
//                        pdfDocument = PDFKit.PDFDocument(url: URL(string: newURL)!)
//                        isUploading = false
//                        hasChanges = true
//                        // Force view to refresh
//                        self.pdf = pdf
//                        self.refreshID = UUID()
//                    }
//                } catch {
//                    await MainActor.run {
//                        errorMessage = "Error uploading PDF: \(error.localizedDescription)"
//                        isUploading = false
//                    }
//                }
//            }
//        }
//
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
