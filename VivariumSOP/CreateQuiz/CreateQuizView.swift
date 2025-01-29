//
//  CreateQuizView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI
///working
//struct CreateQuizView: View {
//    @StateObject var viewModel: CreateQuizViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showingAddQuestion = false
//    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Quiz Details")) {
//                    TextField("Quiz Title", text: $viewModel.quizTitle)
//                        .disabled(true)
//                    TextField("Description", text: $viewModel.quizDescription)
//                    DatePicker("Due Date", selection: $viewModel.quizDueDate, displayedComponents: .date)
//                }
//                
//                Section(header: Text("Account Types")) {
//                    ForEach(AccountType.allCases, id: \.self) { accountType in
//                        Toggle(accountType.rawValue, isOn: Binding(
//                            get: { viewModel.selectedAccountTypes.contains(accountType.rawValue) },
//                            set: { isSelected in
//                                if isSelected {
//                                    viewModel.selectedAccountTypes.insert(accountType.rawValue)
//                                } else {
//                                    viewModel.selectedAccountTypes.remove(accountType.rawValue)
//                                }
//                            }
//                        ))
//                    }
//                }
//                
//                Section(header: Text("Questions")) {
//                    ForEach(viewModel.questions.indices, id: \.self) { index in
//                        NavigationLink(destination: EditQuestionView(question: $viewModel.questions[index])) {
//                            Text("Question \(index + 1)")
//                        }
//                    }
//                    .onDelete(perform: deleteQuestion)
//                    
//                    Button(action: { showingAddQuestion = true }) {
//                        Label("Add Question", systemImage: "plus")
//                    }
//                }
//            }
//            .navigationTitle("Create Quiz")
//            .navigationBarItems(
//                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
//                trailing: Button("Save") { saveQuiz() }
//                    .disabled(viewModel.quizExists)
//            )
//        }
//        .sheet(isPresented: $showingAddQuestion) {
//            AddQuestionView(question: $newQuestion)
//                .onDisappear {
//                    if !newQuestion.questionText.isEmpty {
//                        viewModel.questions.append(newQuestion)
//                        newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//                    }
//                }
//        }
//        .alert(isPresented: $viewModel.showAlert) {
//            Alert(title: Text("Quiz Already Exists"),
//                  message: Text("A quiz with this title already exists. Would you like to edit it?"),
//                  primaryButton: .default(Text("Edit")) {
//                      // Navigate to edit existing quiz
//                  },
//                  secondaryButton: .cancel())
//        }
//        .onAppear {
//            viewModel.checkQuizExists()
//        }
//    }
//
//    private func deleteQuestion(at offsets: IndexSet) {
//        viewModel.questions.remove(atOffsets: offsets)
//    }
//
//    private func saveQuiz() {
//        Task {
//            do {
//                try await viewModel.uploadQuiz()
//                presentationMode.wrappedValue.dismiss()
//            } catch {
//                print("Error saving quiz: \(error)")
//                // Handle error (show alert, etc.)
//            }
//        }
//    }
//}
//


import UniformTypeIdentifiers



import SwiftUI


import SwiftUI
/// trabajando
//struct CreateQuizView: View {
//    @ObservedObject var viewModel: CreateQuizViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showingAddQuestion = false
//    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//    @State private var isLoading = true  // Add this line
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Quiz Details")) {
//                    Text("Category: \(viewModel.quizCategory)")
//                    TextField("Quiz Title", text: $viewModel.quizTitle)
//                    TextField("Description", text: $viewModel.quizDescription)
//                    DatePicker("Due Date", selection: $viewModel.quizDueDate, displayedComponents: .date)
//                }
//                
//                Section(header: Text("Account Types")) {
//                                   ForEach(viewModel.availableAccountTypes, id: \.self) { accountType in
//                                       Toggle(accountType, isOn: Binding(
//                                           get: { viewModel.selectedAccountTypes.contains(accountType) },
//                                           set: { _ in viewModel.toggleAccountType(accountType) }
//                                       ))
//                                   }
//                               }
//
//                               Section(header: Text("Assign to Users")) {
//                                   if viewModel.availableUsers.isEmpty {
//                                       Text("Loading users...")
//                                   } else {
//                                       ForEach(viewModel.availableUsers, id: \.id) { user in
//                                           Toggle(isOn: Binding(
//                                               get: { viewModel.selectedUserIDs.contains(user.id ?? "") },
//                                               set: { _ in viewModel.toggleUserSelection(user.id ?? "") }
//                                           )) {
//                                               Text("\(user.firstName) \(user.lastName) - \(user.accountType)")
//                                           }
//                                       }
//                                   }
//                               }
//                
//                Section(header: Text("Questions")) {
//                    ForEach(viewModel.questions.indices, id: \.self) { index in
//                        NavigationLink(destination: EditQuestionView(question: $viewModel.questions[index])) {
//                            Text("Question \(index + 1)")
//                        }
//                    }
//                    .onDelete(perform: deleteQuestion)
//                    
//                    Button(action: { showingAddQuestion = true }) {
//                        Label("Add Question", systemImage: "plus")
//                    }
//                }
//            }
//            .navigationTitle(viewModel.quizExists ? "Edit Quiz" : "Create Quiz")
//                            .navigationBarItems(
//                                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
//                                trailing: Button("Save") { saveQuiz() }
//                            )
//                            .sheet(isPresented: $showingAddQuestion) {
//                                AddQuestionView(question: $newQuestion)
//                                    .onDisappear {
//                                        if !newQuestion.questionText.isEmpty {
//                                            viewModel.questions.append(newQuestion)
//                                            newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//                                            viewModel.refreshQuiz() // Refresh after adding a question
//                                        }
//                                    }
//                            }
//                            .alert(isPresented: $viewModel.showAlert) {
//                                Alert(
//                                    title: Text("Quiz Already Exists"),
//                                    message: Text("A quiz with this title already exists. You are now editing the existing quiz."),
//                                    dismissButton: .default(Text("OK"))
//                                )
//                            }
//                            .onAppear {
////                                viewModel.refreshQuiz() // Refresh when the view appears
////                                viewModel.fetchAvailableUsers()
//                                
//                                
//                                Task {
//                                    await viewModel.loadDatas()
//                                                    }
//                            }
//
//                            if viewModel.isLoading {
//                                ProgressView()
//                                    .scaleEffect(1.5)
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                    .background(Color.black.opacity(0.1))
//                                    .edgesIgnoringSafeArea(.all)
//                            }
//                        }
//                    }
//                
//  
//    private func deleteQuestion(at offsets: IndexSet) {
//        viewModel.questions.remove(atOffsets: offsets)
//    }
//
////    private func saveQuiz() {
////            Task {
////                do {
////                    try await viewModel.uploadQuiz()
////                    viewModel.refreshQuiz() // Refresh after saving
////                    presentationMode.wrappedValue.dismiss()
////                } catch {
////                    print("Error saving quiz: \(error)")
////                }
////            }
////        }
//    
//    private func saveQuiz() {
//        Task {
//            do {
//                try await viewModel.uploadQuiz()
//                presentationMode.wrappedValue.dismiss()
//            } catch {
//                print("Error saving quiz: \(error)")
//                // Show an error alert to the user
//                await MainActor.run {
//                    // Update your UI to show an error message
//                }
//            }
//        }
//    }
//}

//struct CreateQuizView: View {
//    @ObservedObject var viewModel: CreateQuizViewModel
//    @Environment(\.presentationMode) var presentationMode
//        @Binding var hasUnsavedChanges: Bool
//    @State private var showingAddQuestion = false
//    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//    @State private var attemptingToDismiss = false
//    
//    @State private var showingQuestionGenerator = false
//    @State private var generationError: Error?
//    let quizService = QuizGenerationService(apiKey: "your-api-key")
//    var body: some View {
//        NavigationView {
//            ZStack {
//                if viewModel.isLoading {
//                    ProgressView("Loading...")
//                        .scaleEffect(1.5)
//                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Color.black.opacity(0.1))
//                        .edgesIgnoringSafeArea(.all)
//                } else {
//                    Form {
//                        Section(header: Text("Quiz Details")) {
//                            Text("Category: \(viewModel.quizCategory)")
//                            TextField("Quiz Title", text: $viewModel.quizTitle)
//                            TextField("Description", text: $viewModel.quizDescription)
//                            DatePicker("Due Date", selection: $viewModel.quizDueDate, displayedComponents: .date)
//                        }
//                        
//                        Section(header: Text("Account Types")) {
//                            ForEach(viewModel.availableAccountTypes, id: \.self) { accountType in
//                                Toggle(accountType, isOn: Binding(
//                                    get: { viewModel.selectedAccountTypes.contains(accountType) },
//                                    set: { _ in viewModel.toggleAccountType(accountType) }
//                                ))
//                            }
//                        }
//                        
//                        Section(header: Text("Assign to Users")) {
//                            if viewModel.availableUsers.isEmpty {
//                                Text("No users available")
//                            } else {
//                                ForEach(viewModel.availableUsers, id: \.id) { user in
//                                    Toggle(isOn: Binding(
//                                        get: { viewModel.selectedUserIDs.contains(user.id ?? "") },
//                                        set: { _ in viewModel.toggleUserSelection(user.id ?? "") }
//                                    )) {
//                                        Text("\(user.firstName) \(user.lastName) - \(user.accountType)")
//                                    }
//                                }
//                            }
//                        }
//                        Section(header: Text("VERIFICATION TYPE")) {
//                                                  Picker("Verification Type", selection: $viewModel.verificationType) {
//                                                      ForEach(Quiz.VerificationType.allCases, id: \.self) { type in
//                                                          Text(type.displayTitle).tag(type)
//                                                      }
//                                                  }
//                                                  .pickerStyle(.menu)
//                                                  
//                                                  if viewModel.verificationType != .quiz {
//                                                      TextField("Acknowledgment Text", text: $viewModel.acknowledgmentText, axis: .vertical)
//                                                          .lineLimit(3...6)
//                                                  }
//                                              }
//
//                                              if viewModel.verificationType != .acknowledgment {
//                                                  Section(header: Text("Questions")) {
//                                                      ForEach(viewModel.questions.indices, id: \.self) { index in
//                                                          NavigationLink(destination: EditQuestionView(question: $viewModel.questions[index])) {
//                                                              Text("Question \(index + 1)")
//                                                          }
//                                                      }
//                                                      .onDelete(perform: deleteQuestion)
//                                                      
//                                                      Button(action: { showingAddQuestion = true }) {
//                                                          Label("Add Question", systemImage: "plus")
//                                                      }
//                                                      Button(action: {
//                                                          showingQuestionGenerator = true
//                                                      }) {
//                                                          Label("Generate Questions", systemImage: "wand.and.stars")
//                                                      }
//                                                  }
//                                              }
//                                          }
//                                      }
//                                  }
//                                  .navigationTitle(viewModel.quizExists ? "Edit Quiz" : "Create Quiz")
////                       .navigationBarItems(
////                           leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
////                           trailing: Button("Save") { saveQuiz() }
////                       )
//                       .sheet(isPresented: $showingAddQuestion) {
//                           AddQuestionView(question: $newQuestion)
//                               .onDisappear {
//                                   if !newQuestion.questionText.isEmpty {
//                                       viewModel.questions.append(newQuestion)
//                                       newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//                                   }
//                               }
//                       }
//                       .sheet(isPresented: $showingQuestionGenerator) {
//                           QuizGenerationReviewView(
//                               viewModel: QuizGenerationReviewViewModel(
//                                   document: yourPDFDocument,
//                                   quizService: quizService
//                               ) { questions in
//                                   // Handle the generated questions
//                                   viewModel.questions.append(contentsOf: questions)
//                               }
//                           )
//                       }
////                       .alert(item: Binding<AlertItem?>(
////                           get: { viewModel.alert.map { AlertItem(title: $0.title, message: $0.message) } },
////                           set: { viewModel.alert = $0.map { ($0.title, $0.message) } }
////                       )) { alert in
////                           Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
////                       }
//                       .navigationBarItems(
//                                      leading: Button("Cancel") {
//                                          if hasUnsavedChanges {
//                                              attemptingToDismiss = true
//                                          } else {
//                                              presentationMode.wrappedValue.dismiss()
//                                          }
//                                      },
//                                      trailing: Button("Save") { saveQuiz() }
//                                  )
//                                  .onChange(of: viewModel.quizDescription) { _ in hasUnsavedChanges = true }
//                                  .onChange(of: viewModel.selectedAccountTypes) { _ in hasUnsavedChanges = true }
//                                  .onChange(of: viewModel.questions) { _ in hasUnsavedChanges = true }
//                                  .onChange(of: viewModel.acknowledgmentText) { _ in hasUnsavedChanges = true }
//                                  .onChange(of: viewModel.verificationType) { _ in hasUnsavedChanges = true }
//                                  .alert("Unsaved Changes", isPresented: $attemptingToDismiss) {
//                                      Button("Discard Changes", role: .destructive) {
//                                          hasUnsavedChanges = false
//                                          presentationMode.wrappedValue.dismiss()
//                                      }
//                                      Button("Continue Editing", role: .cancel) {}
//                                  } message: {
//                                      Text("You have unsaved changes. Are you sure you want to leave?")
//                                  }
//                              }
//                       .onAppear {
//                           Task {
//                               await viewModel.loadDatas()
//                           }
//                       }
//                   }
//               
//    
//    private func deleteQuestion(at offsets: IndexSet) {
//        viewModel.questions.remove(atOffsets: offsets)
//    }
//    
//    private func saveQuiz() {
//           Task {
//               do {
//                   try await viewModel.uploadQuiz()
//                   presentationMode.wrappedValue.dismiss()
//               } catch {
//                   print("Error saving quiz: \(error)")
//                   await MainActor.run {
//                       viewModel.alert = ("Error", "Failed to save quiz: \(error.localizedDescription)")
//                   }
//               }
//           }
//       }
//}

///Working
//struct CreateQuizView: View {
//    @ObservedObject var viewModel: CreateQuizViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var hasUnsavedChanges: Bool
//    @State private var showingAddQuestion = false
//    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//    @State private var attemptingToDismiss = false
//    
//    @State private var showingQuestionGenerator = false
//    @State private var generationError: Error?
//    
//    let quizService = QuizGenerationService(apiKey: "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")
//    let document: PDFDocument // ✅ Add this
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                if viewModel.isLoading {
//                    ProgressView("Loading...")
//                        .scaleEffect(1.5)
//                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Color.black.opacity(0.1))
//                        .edgesIgnoringSafeArea(.all)
//                } else {
//                    Form {
//                        // ... Your existing form content
//                    }
//                }
//            }
//            .navigationTitle(viewModel.quizExists ? "Edit Quiz" : "Create Quiz")
//            .sheet(isPresented: $showingQuestionGenerator) {
//                QuizGenerationReviewView(
//                    viewModel: QuizGenerationReviewViewModel(
//                        document: nil, // ✅ Prevents crashes if no document is available
//                        quizService: quizService
//                    ) { questions in
//                        viewModel.questions.append(contentsOf: questions.map { generated in
//                            Question(
//                                questionText: generated.questionText,
//                                options: generated.options,
//                                answer: generated.correctAnswer
//                            )
//                        })
//                    }
//                )
//            }
//
//        }
//        .onAppear {
//            Task {
//                await viewModel.loadDatas()
//            }
//        }
//    }
//}
///
///

import SwiftUI
import PDFKit




//



import SwiftUI
///working
//struct CreateQuizView: View {
//    @StateObject var viewModel: CreateQuizViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showingAddQuestion = false
//    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Quiz Details")) {
//                    TextField("Quiz Title", text: $viewModel.quizTitle)
//                        .disabled(true)
//                    TextField("Description", text: $viewModel.quizDescription)
//                    DatePicker("Due Date", selection: $viewModel.quizDueDate, displayedComponents: .date)
//                }
//
//                Section(header: Text("Account Types")) {
//                    ForEach(AccountType.allCases, id: \.self) { accountType in
//                        Toggle(accountType.rawValue, isOn: Binding(
//                            get: { viewModel.selectedAccountTypes.contains(accountType.rawValue) },
//                            set: { isSelected in
//                                if isSelected {
//                                    viewModel.selectedAccountTypes.insert(accountType.rawValue)
//                                } else {
//                                    viewModel.selectedAccountTypes.remove(accountType.rawValue)
//                                }
//                            }
//                        ))
//                    }
//                }
//
//                Section(header: Text("Questions")) {
//                    ForEach(viewModel.questions.indices, id: \.self) { index in
//                        NavigationLink(destination: EditQuestionView(question: $viewModel.questions[index])) {
//                            Text("Question \(index + 1)")
//                        }
//                    }
//                    .onDelete(perform: deleteQuestion)
//
//                    Button(action: { showingAddQuestion = true }) {
//                        Label("Add Question", systemImage: "plus")
//                    }
//                }
//            }
//            .navigationTitle("Create Quiz")
//            .navigationBarItems(
//                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
//                trailing: Button("Save") { saveQuiz() }
//                    .disabled(viewModel.quizExists)
//            )
//        }
//        .sheet(isPresented: $showingAddQuestion) {
//            AddQuestionView(question: $newQuestion)
//                .onDisappear {
//                    if !newQuestion.questionText.isEmpty {
//                        viewModel.questions.append(newQuestion)
//                        newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//                    }
//                }
//        }
//        .alert(isPresented: $viewModel.showAlert) {
//            Alert(title: Text("Quiz Already Exists"),
//                  message: Text("A quiz with this title already exists. Would you like to edit it?"),
//                  primaryButton: .default(Text("Edit")) {
//                      // Navigate to edit existing quiz
//                  },
//                  secondaryButton: .cancel())
//        }
//        .onAppear {
//            viewModel.checkQuizExists()
//        }
//    }
//
//    private func deleteQuestion(at offsets: IndexSet) {
//        viewModel.questions.remove(atOffsets: offsets)
//    }
//
//    private func saveQuiz() {
//        Task {
//            do {
//                try await viewModel.uploadQuiz()
//                presentationMode.wrappedValue.dismiss()
//            } catch {
//                print("Error saving quiz: \(error)")
//                // Handle error (show alert, etc.)
//            }
//        }
//    }
//}
//


import UniformTypeIdentifiers



/// trabajando
//struct CreateQuizView: View {
//    @ObservedObject var viewModel: CreateQuizViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showingAddQuestion = false
//    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//    @State private var isLoading = true  // Add this line
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Quiz Details")) {
//                    Text("Category: \(viewModel.quizCategory)")
//                    TextField("Quiz Title", text: $viewModel.quizTitle)
//                    TextField("Description", text: $viewModel.quizDescription)
//                    DatePicker("Due Date", selection: $viewModel.quizDueDate, displayedComponents: .date)
//                }
//
//                Section(header: Text("Account Types")) {
//                                   ForEach(viewModel.availableAccountTypes, id: \.self) { accountType in
//                                       Toggle(accountType, isOn: Binding(
//                                           get: { viewModel.selectedAccountTypes.contains(accountType) },
//                                           set: { _ in viewModel.toggleAccountType(accountType) }
//                                       ))
//                                   }
//                               }
//
//                               Section(header: Text("Assign to Users")) {
//                                   if viewModel.availableUsers.isEmpty {
//                                       Text("Loading users...")
//                                   } else {
//                                       ForEach(viewModel.availableUsers, id: \.id) { user in
//                                           Toggle(isOn: Binding(
//                                               get: { viewModel.selectedUserIDs.contains(user.id ?? "") },
//                                               set: { _ in viewModel.toggleUserSelection(user.id ?? "") }
//                                           )) {
//                                               Text("\(user.firstName) \(user.lastName) - \(user.accountType)")
//                                           }
//                                       }
//                                   }
//                               }
//
//                Section(header: Text("Questions")) {
//                    ForEach(viewModel.questions.indices, id: \.self) { index in
//                        NavigationLink(destination: EditQuestionView(question: $viewModel.questions[index])) {
//                            Text("Question \(index + 1)")
//                        }
//                    }
//                    .onDelete(perform: deleteQuestion)
//
//                    Button(action: { showingAddQuestion = true }) {
//                        Label("Add Question", systemImage: "plus")
//                    }
//                }
//            }
//            .navigationTitle(viewModel.quizExists ? "Edit Quiz" : "Create Quiz")
//                            .navigationBarItems(
//                                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
//                                trailing: Button("Save") { saveQuiz() }
//                            )
//                            .sheet(isPresented: $showingAddQuestion) {
//                                AddQuestionView(question: $newQuestion)
//                                    .onDisappear {
//                                        if !newQuestion.questionText.isEmpty {
//                                            viewModel.questions.append(newQuestion)
//                                            newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//                                            viewModel.refreshQuiz() // Refresh after adding a question
//                                        }
//                                    }
//                            }
//                            .alert(isPresented: $viewModel.showAlert) {
//                                Alert(
//                                    title: Text("Quiz Already Exists"),
//                                    message: Text("A quiz with this title already exists. You are now editing the existing quiz."),
//                                    dismissButton: .default(Text("OK"))
//                                )
//                            }
//                            .onAppear {
////                                viewModel.refreshQuiz() // Refresh when the view appears
////                                viewModel.fetchAvailableUsers()
//
//
//                                Task {
//                                    await viewModel.loadDatas()
//                                                    }
//                            }
//
//                            if viewModel.isLoading {
//                                ProgressView()
//                                    .scaleEffect(1.5)
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                    .background(Color.black.opacity(0.1))
//                                    .edgesIgnoringSafeArea(.all)
//                            }
//                        }
//                    }
//
//
//    private func deleteQuestion(at offsets: IndexSet) {
//        viewModel.questions.remove(atOffsets: offsets)
//    }
//
////    private func saveQuiz() {
////            Task {
////                do {
////                    try await viewModel.uploadQuiz()
////                    viewModel.refreshQuiz() // Refresh after saving
////                    presentationMode.wrappedValue.dismiss()
////                } catch {
////                    print("Error saving quiz: \(error)")
////                }
////            }
////        }
//
//    private func saveQuiz() {
//        Task {
//            do {
//                try await viewModel.uploadQuiz()
//                presentationMode.wrappedValue.dismiss()
//            } catch {
//                print("Error saving quiz: \(error)")
//                // Show an error alert to the user
//                await MainActor.run {
//                    // Update your UI to show an error message
//                }
//            }
//        }
//    }
//}

struct CreateQuizView: View {
    @ObservedObject var viewModel: CreateQuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddQuestion = false
    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Form {
                        Section(header: Text("Quiz Details")) {
                            Text("Category: \(viewModel.quizCategory)")
                            TextField("Quiz Title", text: $viewModel.quizTitle)
                            TextField("Description", text: $viewModel.quizDescription)
                            DatePicker("Due Date", selection: $viewModel.quizDueDate, displayedComponents: .date)
                        }
                        
                        Section(header: Text("Account Types")) {
                            ForEach(viewModel.availableAccountTypes, id: \.self) { accountType in
                                Toggle(accountType, isOn: Binding(
                                    get: { viewModel.selectedAccountTypes.contains(accountType) },
                                    set: { _ in viewModel.toggleAccountType(accountType) }
                                ))
                            }
                        }
                        
                        Section(header: Text("Assign to Users")) {
                            if viewModel.availableUsers.isEmpty {
                                Text("No users available")
                            } else {
                                ForEach(viewModel.availableUsers, id: \.id) { user in
                                    Toggle(isOn: Binding(
                                        get: { viewModel.selectedUserIDs.contains(user.id ?? "") },
                                        set: { _ in viewModel.toggleUserSelection(user.id ?? "") }
                                    )) {
                                        Text("\(user.firstName) \(user.lastName) - \(user.accountType)")
                                    }
                                }
                            }
                        }
                        Section(header: Text("VERIFICATION TYPE")) {
                                                  Picker("Verification Type", selection: $viewModel.verificationType) {
                                                      ForEach(Quiz.VerificationType.allCases, id: \.self) { type in
                                                          Text(type.displayTitle).tag(type)
                                                      }
                                                  }
                                                  .pickerStyle(.menu)
                                                  
                                                  if viewModel.verificationType != .quiz {
                                                      TextField("Acknowledgment Text", text: $viewModel.acknowledgmentText, axis: .vertical)
                                                          .lineLimit(3...6)
                                                  }
                                              }

                                              if viewModel.verificationType != .acknowledgment {
                                                  Section(header: Text("Questions")) {
                                                      ForEach(viewModel.questions.indices, id: \.self) { index in
                                                          NavigationLink(destination: EditQuestionView(question: $viewModel.questions[index])) {
                                                              Text("Question \(index + 1)")
                                                          }
                                                      }
                                                      .onDelete(perform: deleteQuestion)
                                                      
                                                      Button(action: { showingAddQuestion = true }) {
                                                          Label("Add Question", systemImage: "plus")
                                                      }
                                                  }
                                              }
                                          }
                                      }
                                  }
                                  .navigationTitle(viewModel.quizExists ? "Edit Quiz" : "Create Quiz")
                       .navigationBarItems(
                           leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                           trailing: Button("Save") { saveQuiz() }
                       )
                       .sheet(isPresented: $showingAddQuestion) {
                           AddQuestionView(question: $newQuestion)
                               .onDisappear {
                                   if !newQuestion.questionText.isEmpty {
                                       viewModel.questions.append(newQuestion)
                                       newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
                                   }
                               }
                       }
                       .alert(item: Binding<AlertItem?>(
                           get: { viewModel.alert.map { AlertItem(title: $0.title, message: $0.message) } },
                           set: { viewModel.alert = $0.map { ($0.title, $0.message) } }
                       )) { alert in
                           Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
                       }
                       .onAppear {
                           Task {
                               await viewModel.loadDatas()
                           }
                       }
                   }
               }
    
    private func deleteQuestion(at offsets: IndexSet) {
        viewModel.questions.remove(atOffsets: offsets)
    }
    
    private func saveQuiz() {
           Task {
               do {
                   try await viewModel.uploadQuiz()
                   presentationMode.wrappedValue.dismiss()
               } catch {
                   print("Error saving quiz: \(error)")
                   await MainActor.run {
                       viewModel.alert = ("Error", "Failed to save quiz: \(error.localizedDescription)")
                   }
               }
           }
       }
}

struct AddQuestionView: View {
    @Binding var question: Question
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question")) {
                    TextField("Enter question", text: $question.questionText)
                }
                
                Section(header: Text("Options")) {
                    ForEach(0..<4) { index in
                        TextField("Option \(index + 1)", text: $question.options[index])
                    }
                }
                
                Section(header: Text("Correct Answer")) {
                    Picker("Select correct answer", selection: $question.answer) {
                        ForEach(question.options, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Add Question")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") { presentationMode.wrappedValue.dismiss() }
            )
        }
    }
}



//struct EditQuestionView: View {
//    @Binding var question: Question
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        Form {
//            Section(header: Text("Question")) {
//                TextField("Question text", text: $question.questionText)
//            }
//
//            Section(header: Text("Options")) {
//                ForEach(0..<4) { index in
//                    TextField("Option \(index + 1)", text: $question.options[index])
//                }
//            }
//
//            Section(header: Text("Correct Answer")) {
//                Picker("Select correct answer", selection: $question.answer) {
//                    ForEach(question.options, id: \.self) { option in
//                        Text(option).tag(option)
//                    }
//                }
//            }
//        }
//        .navigationTitle("Edit Question")
//        .navigationBarItems(trailing: Button("Save") { presentationMode.wrappedValue.dismiss() })
//    }
//}

struct EditQuestionView: View {
    @Binding var question: Question
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            TextField("Question", text: $question.questionText)
            ForEach(0..<4) { index in
                TextField("Option \(index + 1)", text: $question.options[index])
            }
            Picker("Correct Answer", selection: $question.answer) {
                ForEach(question.options.indices, id: \.self) { index in
                    Text(question.options[index]).tag(question.options[index])
                }
            }
        }
        .navigationTitle("Edit Question")
        .navigationBarItems(trailing: Button("Save") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}



//struct EditQuestionView: View {
//    @Binding var question: Question
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        Form {
//            Section(header: Text("Question")) {
//                TextField("Question text", text: $question.questionText)
//            }
//
//            Section(header: Text("Options")) {
//                ForEach(0..<4) { index in
//                    TextField("Option \(index + 1)", text: $question.options[index])
//                }
//            }
//
//            Section(header: Text("Correct Answer")) {
//                Picker("Select correct answer", selection: $question.answer) {
//                    ForEach(question.options, id: \.self) { option in
//                        Text(option).tag(option)
//                    }
//                }
//            }
//        }
//        .navigationTitle("Edit Question")
//        .navigationBarItems(trailing: Button("Save") { presentationMode.wrappedValue.dismiss() })
//    }
//}
//
//









struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}



