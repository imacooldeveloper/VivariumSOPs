//
//  QuizListView.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI

///


//struct QuizListView: View {
//    @ObservedObject var viewModel: QuizListViewModel
//       @State private var showingEditQuizView = false
//       @State private var selectedQuiz: Quiz?
//       @State private var showingDeleteAlert = false
//       @State private var quizToDelete: Quiz?
//       @State private var loginViewModel = LoginViewModel()
//       @State private var refreshID = UUID()
//       @State private var selectedQuizID: String?
//       @State private var searchText = ""
//       
//       var body: some View {
//           
//               ZStack {
//                   Color(.systemBackground)
//                       .ignoresSafeArea()
//                   
//                   VStack(spacing: 0) {
//                       QuizSearchBar(text: $searchText)
//                           .padding()
//                       
//                       ScrollView {
//                           LazyVStack(spacing: 16) {
//                               ForEach(filteredQuizzes) { quiz in
//                                   ModernQuizCard(
//                                       quiz: quiz,
//                                       onTap: {
//                                           selectedQuiz = quiz
//                                           showingEditQuizView = true
//                                       },
//                                       onDelete: {
//                                           quizToDelete = quiz
//                                           showingDeleteAlert = true
//                                       }
//                                   )
//                                   .padding(.horizontal)
//                               }
//                           }
//                           .padding(.vertical)
//                       }
//                       .refreshable {
//                           await viewModel.fetchQuizzesAsync()
//                       }
//                   }
//               }
//               .navigationTitle("Quizzes")
//               .sheet(item: $selectedQuiz) { quiz in  // Change to sheet(item:)
//                   EditQuizView(viewModel: EditQuizViewModel(quiz: quiz))
//               }
//               .alert("Delete Quiz", isPresented: $showingDeleteAlert) {
//                   Button("Cancel", role: .cancel) {}
//                   Button("Delete", role: .destructive) {
//                       if let quiz = quizToDelete {
//                           Task {
//                               await deleteQuiz(quiz)
//                           }
//                       }
//                   }
//               }
//               .toolbar {
//                   ToolbarItem(placement: .navigationBarTrailing) {
//                       Button("Sign Out") {
//                           loginViewModel.logOutUser()
//                       }
//                   }
//               }
//           
//       }
//    
//  
//    
//    private func deleteQuiz(_ quiz: Quiz) async {
//           do {
//               try await viewModel.deleteQuiz(quiz)
//               quizToDelete = nil
//           } catch {
//               print("Error deleting quiz: \(error)")
//           }
//       }
//       
//       private var filteredQuizzes: [Quiz] {
//           if searchText.isEmpty {
//               return viewModel.quizzes
//           }
//           return viewModel.quizzes.filter { quiz in
//               quiz.info.title.localizedCaseInsensitiveContains(searchText) ||
//               quiz.quizCategory.localizedCaseInsensitiveContains(searchText)
//           }
//       }
//}

struct ModernQuizCard: View {
    let quiz: Quiz
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 16) {
                    QuizCategoryIcon(category: quiz.quizCategory)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quiz.info.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(quiz.quizCategory)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                // Footer
                HStack {
                    Label(
                        dueDateText,
                        systemImage: "calendar"
                    )
                    .font(.caption)
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Label(
                        "\(quiz.info.peopleAttended) completed",
                        systemImage: "person.2.fill"
                    )
                    .font(.caption)
                    .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete Quiz", systemImage: "trash")
            }
        }
    }
    
    private var dueDateText: String {
        if let dueDate = quiz.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Due: \(formatter.string(from: dueDate))"
        }
        return "No due date"
    }
}

struct QuizCategoryIcon: View {
    let category: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(categoryColor.gradient)
                .frame(width: 40, height: 40)
            
            Image(systemName: categoryIcon)
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
    }
    
    private var categoryColor: Color {
        switch category.lowercased() {
        case "biology": return .green
        case "chemistry": return .blue
        case "physics": return .orange
        case "math": return .red
        default: return .gray
        }
    }
    
    private var categoryIcon: String {
        switch category.lowercased() {
        case "biology": return "leaf.fill"
        case "chemistry": return "flask.fill"
        case "physics": return "atom"
        case "math": return "function"
        default: return "book.fill"
        }
    }
}

struct QuizSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search quizzes...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }
}


///
//struct QuizListView: View {
//    @ObservedObject var viewModel: QuizListViewModel
//       @State private var showingEditQuizView = false
//       @State private var selectedQuiz: Quiz?
//       @State private var showingDeleteAlert = false
//       @State private var quizToDelete: Quiz?
//        @State private var loginViewModel = LoginViewModel()
//    @State private var refreshID = UUID() // Add this line
//    @State private var selectedQuizID: String?
//       var body: some View {
//           ZStack {
//               List {
//                   ForEach(viewModel.quizzes) { quiz in
//                                     ZStack {
//                                         QuizRowView(quiz: quiz)
//                                         
//                                         NavigationLink(destination: EmptyView()) {
//                                             EmptyView()
//                                         }
//                                         .opacity(0)
//                                         .buttonStyle(PlainButtonStyle())
//                                     }
//                                     .contentShape(Rectangle())
//                                     .onTapGesture {
//                                         selectedQuiz = quiz
//                                         showingEditQuizView = true
//                                         refreshID = UUID()
//                                     }
//                                     .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                                         Button(role: .destructive) {
//                                             quizToDelete = quiz
//                                             showingDeleteAlert = true
//                                         } label: {
//                                             Label("Delete", systemImage: "trash")
//                                         }
//                                     }
//                                     .id(refreshID)
//                                 }
//                             }
//                             .listStyle(PlainListStyle())// This removes the default list styling
//               .onChange(of: selectedQuizID) { newValue in
//                          if let id = newValue, let quiz = viewModel.quizzes.first(where: { $0.id == id }) {
//                              selectedQuiz = quiz
//                          }
//                      }
//               .sheet(isPresented: $showingEditQuizView) {
//                          if let quizToEdit = selectedQuiz {
//                              EditQuizView(viewModel: EditQuizViewModel(quiz: quizToEdit))
//                          }
//                      }
//               .refreshable {
//                   await viewModel.fetchQuizzesAsync()
//               }
//               .sheet(isPresented: $showingEditQuizView) {
//                   if let quizToEdit = selectedQuiz {
//                       EditQuizView(viewModel: EditQuizViewModel(quiz: quizToEdit))
//                   }
//               }
//               .onAppear {
//                   if viewModel.quizzes.isEmpty {
//                       viewModel.fetchQuizzes()
//                      // viewModel.
//                   }
//               }
//
//               if showingDeleteAlert, let quiz = quizToDelete {
//                   Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
//                   CustomAlertView(
//                       title: "Delete Quiz",
//                       message: "Are you sure you want to delete '\(quiz.info.title)'? This action cannot be undone.",
//                       primaryButton: AlertButton(title: "Delete", action: {
//                           deleteQuiz(quiz)
//                           showingDeleteAlert = false
//                       }),
//                       secondaryButton: AlertButton(title: "Cancel", action: {
//                           showingDeleteAlert = false
//                       })
//                   )
//               }
//           }
//           .toolbar {
//                           ToolbarItem(placement: .navigationBarTrailing) {
//                               Button("Sign Out") {
//                                   loginViewModel.logOutUser()
//                               }
//                           }
//                       }
//       }
//       
//
//       private func deleteQuiz(_ quiz: Quiz) {
//           Task {
//               do {
//                   try await viewModel.deleteQuiz(quiz)
//                   await viewModel.fetchQuizzesAsync()
//               } catch {
//                   print("Error deleting quiz: \(error.localizedDescription)")
//                   // Show an error alert to the user
//                   await MainActor.run {
//                       showDeleteErrorAlert(error: error)
//                   }
//               }
//           }
//       }
//
//       private func showDeleteErrorAlert(error: Error) {
//           showingDeleteAlert = true
//           quizToDelete = nil
//           DispatchQueue.main.async {
//               self.showingDeleteAlert = true
//               self.quizToDelete = nil
//               let errorAlert = CustomAlertView(
//                   title: "Error",
//                   message: "Failed to delete quiz: \(error.localizedDescription)",
//                   primaryButton: AlertButton(title: "OK", action: {
//                       self.showingDeleteAlert = false
//                   })
//               )
//               // You might need to adjust how you present this alert depending on your view hierarchy
//           }
//       }
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
//class QuizListViewModel: ObservableObject {
//    
//    @Published var quizzes: [Quiz] = []
//        private let quizManager = QuizManager.shared
//        @AppStorage("organizationId") private var organizationId: String = ""
//        
//        init() {
//            fetchQuizzes()
//        }
//        
//        func fetchQuizzes() {
//            Task {
//                await fetchQuizzesAsync()
//            }
//        }
//        
//        @MainActor
//        func fetchQuizzesAsync() async {
//            do {
//                self.quizzes = try await quizManager.getAllQuizzes(for: organizationId)
//            } catch {
//                print("Error fetching quizzes: \(error)")
//            }
//        }
//        
//        func deleteQuiz(_ quiz: Quiz) async throws {
//            try await quizManager.deleteQuiz(quiz)
//            await fetchQuizzesAsync()
//        }
//    
//    
//}


class QuizListViewModel: ObservableObject {
    @Published var quizzes: [Quiz] = []
    @Published var deletionCode = ""
    @Published var showingDeleteVerification = false
    @Published var showingIncorrectCodeError = false
    @Published var quizToDelete: Quiz?
    private let correctDeletionCode = "12345"
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
    
    func verifyAndDelete() {
        if deletionCode == correctDeletionCode {
            if let quiz = quizToDelete {
                Task {
                    do {
                        try await deleteQuiz(quiz)
                    } catch {
                        print("Error deleting quiz: \(error)")
                    }
                }
            }
        } else {
            showingIncorrectCodeError = true
        }
        deletionCode = ""
        showingDeleteVerification = false
    }
    
    func deleteQuiz(_ quiz: Quiz) async throws {
        try await quizManager.deleteQuiz(quiz)
        await fetchQuizzesAsync()
    }
}

struct QuizListView: View {
    @ObservedObject var viewModel: QuizListViewModel
    @State private var showingEditQuizView = false
    @State private var selectedQuiz: Quiz?
    @State private var showingDeleteAlert = false
    @State private var quizToDelete: Quiz?
    @State private var loginViewModel = LoginViewModel()
    @State private var refreshID = UUID()
    @State private var selectedQuizID: String?
    @State private var searchText = ""
    
    // Add new state variables for verification
    @State private var deletionCode = ""
    @State private var showingDeleteVerification = false
    @State private var showingIncorrectCodeError = false
    
    private let correctDeletionCode = "12345" // This should match your PDFCategoryListView code
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                QuizSearchBar(text: $searchText)
                    .padding()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredQuizzes) { quiz in
                            ModernQuizCard(
                                quiz: quiz,
                                onTap: {
                                    selectedQuiz = quiz
                                    showingEditQuizView = true
                                },
                                onDelete: {
                                    quizToDelete = quiz
                                    showingDeleteVerification = true
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await viewModel.fetchQuizzesAsync()
                }
            }
        }
        .navigationTitle("Quizzes")
        .sheet(item: $selectedQuiz) { quiz in
            EditQuizView(viewModel: EditQuizViewModel(quiz: quiz))
        }
        // Add verification alert
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
            Text("Enter the deletion code to remove this quiz and all its contents.")
        }
        // Add incorrect code alert
        .alert("Incorrect Code", isPresented: $showingIncorrectCodeError) {
            Button("OK", role: .cancel) {
                deletionCode = ""
            }
        } message: {
            Text("The deletion code entered was incorrect. Please try again.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sign Out") {
                    loginViewModel.logOutUser()
                }
            }
        }
    }
    
    private var filteredQuizzes: [Quiz] {
        if searchText.isEmpty {
            return viewModel.quizzes
        }
        return viewModel.quizzes.filter { quiz in
            quiz.info.title.localizedCaseInsensitiveContains(searchText) ||
            quiz.quizCategory.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func verifyAndDelete() {
        if deletionCode == correctDeletionCode {
            if let quiz = quizToDelete {
                Task {
                    do {
                        try await viewModel.deleteQuiz(quiz)
                    } catch {
                        print("Error deleting quiz: \(error)")
                    }
                }
            }
        } else {
            showingIncorrectCodeError = true
        }
        deletionCode = ""
    }
}
