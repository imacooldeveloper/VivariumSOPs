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

    var body: some View {
        List {
            ForEach(viewModel.quizzes) { quiz in
                QuizRowView(quiz: quiz)
                    .onTapGesture {
                        selectedQuiz = quiz
                        showingEditQuizView = true
                    }
            }
        }
        .navigationTitle("Quizzes")
        .sheet(isPresented: $showingEditQuizView) {
            if let quizToEdit = selectedQuiz {
                EditQuizView(viewModel: EditQuizViewModel(quiz: quizToEdit))
            }
        }
        .onChange(of: showingEditQuizView) { newValue in
            if newValue == false {
                viewModel.fetchQuizzes()
            }
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
            do {
                let fetchedQuizzes = try await quizManager.getAllQuizzes()
                await MainActor.run {
                    self.quizzes = fetchedQuizzes
                }
            } catch {
                print("Error fetching quizzes: \(error)")
            }
        }
    }
}
