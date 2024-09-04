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

struct CreateQuizView: View {
    @ObservedObject var viewModel: CreateQuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddQuestion = false
    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")

    var body: some View {
        NavigationView {
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
                            set: { isSelected in
                                if isSelected {
                                    viewModel.selectedAccountTypes.insert(accountType)
                                } else {
                                    viewModel.selectedAccountTypes.remove(accountType)
                                }
                            }
                        ))
                    }
                }
                
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
                                            viewModel.refreshQuiz() // Refresh after adding a question
                                        }
                                    }
                            }
                            .alert(isPresented: $viewModel.showAlert) {
                                Alert(
                                    title: Text("Quiz Already Exists"),
                                    message: Text("A quiz with this title already exists. You are now editing the existing quiz."),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                            .onAppear {
                                viewModel.refreshQuiz() // Refresh when the view appears
                            }

                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black.opacity(0.1))
                                    .edgesIgnoringSafeArea(.all)
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
                    viewModel.refreshQuiz() // Refresh after saving
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print("Error saving quiz: \(error)")
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

struct EditQuestionView: View {
    @Binding var question: Question
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Question")) {
                TextField("Question text", text: $question.questionText)
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
        .navigationTitle("Edit Question")
        .navigationBarItems(trailing: Button("Save") { presentationMode.wrappedValue.dismiss() })
    }
}
