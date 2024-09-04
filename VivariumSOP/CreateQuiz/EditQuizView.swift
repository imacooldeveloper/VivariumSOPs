//
//  EditQuizView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
struct EditQuizView: View {
    @ObservedObject var viewModel: EditQuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddQuestion = false
    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quiz Details")) {
                    TextField("Quiz Title", text: $viewModel.quizTitle)
                        .disabled(true)
                    TextField("Description", text: $viewModel.quizDescription)
                    DatePicker("Due Date", selection: $viewModel.quizDueDate, displayedComponents: .date)
                }
                
                Section(header: Text("Account Types")) {
                               ForEach(AccountType.allCases, id: \.self) { accountType in
                                   Toggle(accountType.rawValue, isOn: Binding(
                                    get: { viewModel.selectedAccountTypes.contains(accountType.rawValue) },
                                       set: { isSelected in
                                           if isSelected {
                                               viewModel.selectedAccountTypes.insert(accountType.rawValue)
                                           } else {
                                               viewModel.selectedAccountTypes.remove(accountType.rawValue)
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
            .navigationTitle("Edit Quiz")
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
        }
    }

    private func deleteQuestion(at offsets: IndexSet) {
        viewModel.questions.remove(atOffsets: offsets)
    }

    private func saveQuiz() {
        Task {
            do {
                try await viewModel.updateQuiz()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Error updating quiz: \(error)")
            }
        }
    }
}
@MainActor
class EditQuizViewModel: ObservableObject {
    @Published var quizTitle: String
    @Published var quizDescription: String
    @Published var quizCategory: String
    @Published var quizCategoryID: String
    @Published var quizDueDate: Date
    @Published var questions: [Question]
    @Published var selectedAccountTypes: Set<String>
    
    var availableAccountTypes: [AccountType] {
           AccountType.allCases
       }
    
    private let quizManager = QuizManager.shared
    private let quizId: String
    
    init(quiz: Quiz) {
        self.quizId = quiz.id
        self.quizTitle = quiz.info.title
        self.quizDescription = quiz.info.description
        self.quizCategory = quiz.quizCategory
        self.quizCategoryID = quiz.quizCategoryID
        self.quizDueDate = quiz.dueDate ?? Date()
        self.selectedAccountTypes = Set(quiz.accountTypes)
        
        // Fetch questions
        self.questions = []
        Task {
            do {
                self.questions = try await quizManager.getQuestionsForQuiz(quizId: quiz.id)
                await MainActor.run {
                    self.objectWillChange.send()
                }
            } catch {
                print("Error fetching questions: \(error)")
            }
        }
    }
    
    func updateQuiz() async throws {
        let updatedQuiz = Quiz(
            id: quizId,
            info: Info(
                title: quizTitle,
                description: quizDescription,
                peopleAttended: 0,
                rules: [""]
            ),
            quizCategory: quizCategory,
            quizCategoryID: quizCategoryID,
            accountTypes: Array(selectedAccountTypes),
            dateCreated: nil, // We don't update the creation date
            dueDate: quizDueDate
        )
        
        try await quizManager.updateQuizWithQuestions(quiz: updatedQuiz, questions: questions)
    }
}
