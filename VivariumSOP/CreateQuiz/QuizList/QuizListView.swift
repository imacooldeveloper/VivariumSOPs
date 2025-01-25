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
        @State private var loginViewModel = LoginViewModel()
    @State private var refreshID = UUID() // Add this line
    @State private var selectedQuizID: String?
       var body: some View {
           ZStack {
               List {
                   ForEach(viewModel.quizzes) { quiz in
                                     ZStack {
                                         QuizRowView(quiz: quiz)
                                         
                                         NavigationLink(destination: EmptyView()) {
                                             EmptyView()
                                         }
                                         .opacity(0)
                                         .buttonStyle(PlainButtonStyle())
                                     }
                                     .contentShape(Rectangle())
                                     .onTapGesture {
                                         selectedQuiz = quiz
                                         showingEditQuizView = true
                                         refreshID = UUID()
                                     }
                                     .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                         Button(role: .destructive) {
                                             quizToDelete = quiz
                                             showingDeleteAlert = true
                                         } label: {
                                             Label("Delete", systemImage: "trash")
                                         }
                                     }
                                     .id(refreshID)
                                 }
                             }
                             .listStyle(PlainListStyle())// This removes the default list styling
               .onChange(of: selectedQuizID) { newValue in
                          if let id = newValue, let quiz = viewModel.quizzes.first(where: { $0.id == id }) {
                              selectedQuiz = quiz
                          }
                      }
               .sheet(isPresented: $showingEditQuizView) {
                          if let quizToEdit = selectedQuiz {
                              EditQuizView(viewModel: EditQuizViewModel(quiz: quizToEdit))
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
                      // viewModel.
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
           .toolbar {
                           ToolbarItem(placement: .navigationBarTrailing) {
                               Button("Sign Out") {
                                   loginViewModel.logOutUser()
                               }
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

//struct QuizRowView: View {
//    let quiz: Quiz
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(quiz.info.title)
//                .font(.headline)
//            Text(quiz.quizCategory)
//                .font(.subheadline)
//            Text("Due: \(quiz.dueDate?.formatted() ?? "No due date")")
//                .font(.caption)
//        }
//    }
//}
struct QuizRowView: View {
    let quiz: Quiz
    
    var body: some View {
        HStack(spacing: 16) {
            // Quiz icon
            ZStack {
                Circle()
                    .fill(colorForCategory(quiz.quizCategory))
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconForCategory(quiz.quizCategory))
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            }
            
            // Quiz details
            VStack(alignment: .leading, spacing: 4) {
                Text(quiz.info.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(quiz.quizCategory)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text(dueDateText)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Chevron icon
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    private var dueDateText: String {
        if let dueDate = quiz.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: dueDate)
        } else {
            return "No due date"
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "biology": return .green
        case "chemistry": return .blue
        case "physics": return .orange
        case "math": return .red
        default: return .gray
        }
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "biology": return "leaf.fill"
        case "chemistry": return "flask.fill"
        case "physics": return "atom"
        case "math": return "function"
        default: return "book.fill"
        }
    }
}
class QuizListViewModel: ObservableObject {
    
    @Published var quizzes: [Quiz] = []
        private let quizManager = QuizManager.shared
        @AppStorage("organizationId") private var organizationId: String = ""
        
        init() {
            fetchQuizzes()
        }
        
        func fetchQuizzes() {
            Task {
                await fetchQuizzesAsync()
            }
        }
        
        @MainActor
        func fetchQuizzesAsync() async {
            do {
                self.quizzes = try await quizManager.getAllQuizzes(for: organizationId)
            } catch {
                print("Error fetching quizzes: \(error)")
            }
        }
        
        func deleteQuiz(_ quiz: Quiz) async throws {
            try await quizManager.deleteQuiz(quiz)
            await fetchQuizzesAsync()
        }
    
    
}
