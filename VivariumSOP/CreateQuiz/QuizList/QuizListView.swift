//
//  QuizListView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI

struct QuizListView: View {
    @ObservedObject var viewModel: QuizListViewModel
       @State private var showingEditQuizView = false
       @State private var selectedQuiz: Quiz?
       @State private var showingDeleteAlert = false
       @State private var quizToDelete: Quiz?

       var body: some View {
           ZStack {
               List {
                   ForEach(viewModel.quizzes) { quiz in
                       QuizRowView(quiz: quiz)
                           .onTapGesture {
                               selectedQuiz = quiz
                               showingEditQuizView = true
                           }
                           .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                               Button(role: .destructive) {
                                   quizToDelete = quiz
                                   showingDeleteAlert = true
                               } label: {
                                   Label("Delete", systemImage: "trash")
                               }
                           }
                   }
               }
               .refreshable {
                   await viewModel.fetchQuizzesAsync()
               }
               .sheet(isPresented: $showingEditQuizView) {
                   if let quizToEdit = selectedQuiz {
                       EditQuizView(viewModel: EditQuizViewModel(quiz: quizToEdit))
                   }
               }
               .onAppear {
                   if viewModel.quizzes.isEmpty {
                       viewModel.fetchQuizzes()
                   }
               }

               if showingDeleteAlert, let quiz = quizToDelete {
                   Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                   CustomAlertView(
                       title: "Delete Quiz",
                       message: "Are you sure you want to delete '\(quiz.info.title)'? This action cannot be undone.",
                       primaryButton: AlertButton(title: "Delete", action: {
                           deleteQuiz(quiz)
                           showingDeleteAlert = false
                       }),
                       secondaryButton: AlertButton(title: "Cancel", action: {
                           showingDeleteAlert = false
                       })
                   )
               }
           }
       }

       private func deleteQuiz(_ quiz: Quiz) {
           Task {
               do {
                   try await viewModel.deleteQuiz(quiz)
                   await viewModel.fetchQuizzesAsync()
               } catch {
                   print("Error deleting quiz: \(error.localizedDescription)")
                   // Show an error alert to the user
                   await MainActor.run {
                       showDeleteErrorAlert(error: error)
                   }
               }
           }
       }

       private func showDeleteErrorAlert(error: Error) {
           showingDeleteAlert = true
           quizToDelete = nil
           DispatchQueue.main.async {
               self.showingDeleteAlert = true
               self.quizToDelete = nil
               let errorAlert = CustomAlertView(
                   title: "Error",
                   message: "Failed to delete quiz: \(error.localizedDescription)",
                   primaryButton: AlertButton(title: "OK", action: {
                       self.showingDeleteAlert = false
                   })
               )
               // You might need to adjust how you present this alert depending on your view hierarchy
           }
       }
}

struct QuizRowView: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(quiz.info.title)
                .font(.headline)
            Text(quiz.quizCategory)
                .font(.subheadline)
            Text("Due: \(quiz.dueDate?.formatted() ?? "No due date")")
                .font(.caption)
        }
    }
}

class QuizListViewModel: ObservableObject {
    @Published var quizzes: [Quiz] = []
    
    private let quizManager = QuizManager.shared
    
    init() {
        fetchQuizzes()
    }
    func fetchQuizzes() {
            Task {
                await fetchQuizzesAsync()
            }
        }
    
    func deleteQuiz(_ quiz: Quiz) async throws {
          try await quizManager.deleteQuiz(quiz)
      }
    
//    func fetchQuizzes() {
//        Task {
//            do {
//                let fetchedQuizzes = try await quizManager.getAllQuizzes()
//                await MainActor.run {
//                    self.quizzes = fetchedQuizzes
//                }
//            } catch {
//                print("Error fetching quizzes: \(error)")
//            }
//        }
//    }
    @MainActor
       func fetchQuizzesAsync() async {
           do {
               self.quizzes = try await quizManager.getAllQuizzes()
           } catch {
               print("Error fetching quizzes: \(error)")
           }
       }
}
