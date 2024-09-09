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
//struct EditQuizView: View {
//    @ObservedObject var viewModel: EditQuizViewModel
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
//                               ForEach(AccountType.allCases, id: \.self) { accountType in
//                                   Toggle(accountType.rawValue, isOn: Binding(
//                                    get: { viewModel.selectedAccountTypes.contains(accountType.rawValue) },
//                                       set: { isSelected in
//                                           if isSelected {
//                                               viewModel.selectedAccountTypes.insert(accountType.rawValue)
//                                           } else {
//                                               viewModel.selectedAccountTypes.remove(accountType.rawValue)
//                                           }
//                                       }
//                                   ))
//                               }
//                           }
//                Section(header: Text("Assign to Users")) {
//                                    if viewModel.isLoadingUsers {
//                                        ProgressView("Loading users...")
//                                    } else if let error = viewModel.userLoadingError {
//                                        Text("Error: \(error)")
//                                            .foregroundColor(.red)
//                                    } else if viewModel.availableUsers.isEmpty {
//                                        Text("No users available")
//                                    } else {
//                                        ForEach(viewModel.availableUsers, id: \.id) { user in
//                                            Toggle(isOn: Binding(
//                                                get: { viewModel.selectedUserIDs.contains(user.id ?? "") },
//                                                set: { isSelected in
//                                                    viewModel.toggleUserSelection(user.id ?? "")
//                                                }
//                                            )) {
//                                                Text("\(user.username) - \(user.accountType)")
//                                            }
//                                        }
//                                    }
//                                }
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
//            .navigationTitle("Edit Quiz")
//            .navigationBarItems(
//                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
//                trailing: Button("Save") { saveQuiz() }
//            )
//            .task {
//                           await  viewModel.fetchAvailableUsers()
//                        }
//            .sheet(isPresented: $showingAddQuestion) {
//                AddQuestionView(question: $newQuestion)
//                    .onDisappear {
//                        if !newQuestion.questionText.isEmpty {
//                            viewModel.questions.append(newQuestion)
//                            newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
//                        }
//                    }
//            }
//         
//        }
//    }
//
//    private func deleteQuestion(at offsets: IndexSet) {
//        viewModel.questions.remove(atOffsets: offsets)
//    }
//
//    private func saveQuiz() {
//          Task {
//              do {
//                  try await viewModel.updateQuiz()
//                  presentationMode.wrappedValue.dismiss()
//              } catch {
//                  print("Error updating quiz: \(error)")
//              }
//          }
//      }
//}
//@MainActor
//class EditQuizViewModel: ObservableObject {
//    @Published var quizTitle: String
//    @Published var quizDescription: String
//    @Published var quizCategory: String
//    @Published var quizCategoryID: String
//    @Published var quizDueDate: Date
//    @Published var questions: [Question]
//    @Published var selectedAccountTypes: Set<String>
//    
//    var availableAccountTypes: [AccountType] {
//           AccountType.allCases
//       }
//    private let userManager = UserManager.shared
//    private let quizManager = QuizManager.shared
//    private let quizId: String
//    
//    init(quiz: Quiz) {
//        self.quizId = quiz.id
//        self.quizTitle = quiz.info.title
//        self.quizDescription = quiz.info.description
//        self.quizCategory = quiz.quizCategory
//        self.quizCategoryID = quiz.quizCategoryID
//        self.quizDueDate = quiz.dueDate ?? Date()
//        self.selectedAccountTypes = Set(quiz.accountTypes)
//        
//        // Fetch questions
//        self.questions = []
//        Task {
//            do {
//                self.questions = try await quizManager.getQuestionsForQuiz(quizId: quiz.id)
//                await MainActor.run {
//                    self.objectWillChange.send()
//                }
//            } catch {
//                print("Error fetching questions: \(error)")
//            }
//        }
//        
//        Task {
//               do {
//                   let assignedUsers = try await userManager.getUsersWithCompletedQuizzes(quizId: quiz.id)
//                   await MainActor.run {
//                       self.selectedUserIDs = Set(assignedUsers.compactMap { $0.id })
//                   }
//               } catch {
//                   print("Error fetching assigned users: \(error)")
//               }
//           }
//    }
////    
////    func updateQuiz() async throws {
////        let updatedQuiz = Quiz(
////            id: quizId,
////            info: Info(
////                title: quizTitle,
////                description: quizDescription,
////                peopleAttended: 0,
////                rules: [""]
////            ),
////            quizCategory: quizCategory,
////            quizCategoryID: quizCategoryID,
////            accountTypes: Array(selectedAccountTypes),
////            dateCreated: nil, // We don't update the creation date
////            dueDate: quizDueDate
////        )
////        
////        try await quizManager.updateQuizWithQuestions(quiz: updatedQuiz, questions: questions)
////    }
//    
//    
//    @Published var availableUsers: [User] = []
//       @Published var selectedUserIDs: Set<String> = []
//       @Published var isLoadingUsers = false
//       @Published var userLoadingError: String?
//    func fetchAvailableUsers() {
//           isLoadingUsers = true
//           userLoadingError = nil
//           Task {
//               do {
//                   let users = try await userManager.getAllUsers()
//                   self.availableUsers = users
//                   self.isLoadingUsers = false
//               } catch {
//                   print("Error fetching users: \(error.localizedDescription)")
//                   self.availableUsers = []
//                   self.isLoadingUsers = false
//                   self.userLoadingError = error.localizedDescription
//               }
//           }
//       }
//       
//       func updateQuiz() async throws {
//           let updatedQuiz = Quiz(
//               id: quizId,
//               info: Info(
//                   title: quizTitle,
//                   description: quizDescription,
//                   peopleAttended: 0,
//                   rules: [""]
//               ),
//               quizCategory: quizCategory,
//               quizCategoryID: quizCategoryID,
//               accountTypes: Array(selectedAccountTypes),
//               dateCreated: nil,
//               dueDate: quizDueDate
//           )
//           
//           try await quizManager.updateQuizWithQuestions(quiz: updatedQuiz, questions: questions)
//           
//           // Assign quiz to selected users
//           for userID in selectedUserIDs {
//               try await userManager.assignQuizToUser(userID: userID, quizID: quizId, dueDate: quizDueDate)
//           }
//       }
//    
//    func toggleUserSelection(_ userId: String) {
//           if selectedUserIDs.contains(userId) {
//               selectedUserIDs.remove(userId)
//           } else {
//               selectedUserIDs.insert(userId)
//           }
//       }
//}



@MainActor
class EditQuizViewModel: ObservableObject {
    @Published var quizTitle: String
    @Published var quizDescription: String
    @Published var quizCategory: String
    @Published var quizCategoryID: String
    @Published var quizDueDate: Date
    @Published var questions: [Question]
    @Published var selectedAccountTypes: Set<String>
    @Published var availableUsers: [User] = []
    @Published var selectedUserIDs: Set<String> = []
    @Published var isLoadingUsers = false
    @Published var userLoadingError: String?
    
    private let userManager = UserManager.shared
    private let quizManager = QuizManager.shared
    private let quizId: String
    
    var availableAccountTypes: [AccountType] {
        AccountType.allCases
    }
    
    init(quiz: Quiz) {
//        self.quizId = quiz.id
//        self.quizTitle = quiz.info.title
//        self.quizDescription = quiz.info.description
//        self.quizCategory = quiz.quizCategory
//        self.quizCategoryID = quiz.quizCategoryID
//        self.quizDueDate = quiz.dueDate ?? Date()
//        self.selectedAccountTypes = Set(quiz.accountTypes)
//        self.questions = []
//        
//        Task {
//            await fetchQuestions()
//            await fetchAssignedUsers()
//            await fetchAvailableUsers()
//        }
        
        
        self.quizId = quiz.id
          self.quizTitle = quiz.info.title
          self.quizDescription = quiz.info.description
          self.quizCategory = quiz.quizCategory
          self.quizCategoryID = quiz.quizCategoryID
          self.quizDueDate = quiz.dueDate ?? Date()
          self.selectedAccountTypes = Set(quiz.accountTypes)
          self.questions = []
          
          print("Initializing EditQuizViewModel with quiz: \(quiz.id)")
          
          Task {
              await fetchQuestions()
              await fetchAssignedUsers()
              await fetchAvailableUsers()
          }
    }
    
    func fetchQuestions() async {
        do {
            self.questions = try await quizManager.getQuestionsForQuiz(quizId: quizId)
        } catch {
            print("Error fetching questions: \(error)")
        }
    }
    
    func fetchAssignedUsers() async {
        do {
            let assignedUsers = try await userManager.getUsersWithCompletedQuizzes(quizId: quizId)
            self.selectedUserIDs = Set(assignedUsers.compactMap { $0.id })
        } catch {
            print("Error fetching assigned users: \(error)")
        }
    }
    ///workingg
//    func fetchAvailableUsers() async {
//        isLoadingUsers = true
//        userLoadingError = nil
//        do {
//            self.availableUsers = try await userManager.getAllUserss()
//            self.isLoadingUsers = false
//        } catch {
//            print("Error fetching users: \(error.localizedDescription)")
//            self.availableUsers = []
//            self.isLoadingUsers = false
//            self.userLoadingError = error.localizedDescription
//        }
//    }
    
//    func fetchAvailableUsers() async {
//        print("Starting to fetch available users")
//        isLoadingUsers = true
//        userLoadingError = nil
//        do {
//            self.availableUsers = try await userManager.getAllUserss()
//            print("Fetched \(self.availableUsers.count) users")
//            await MainActor.run {
//                self.isLoadingUsers = false
//            }
//        } catch {
//            print("Error fetching users: \(error.localizedDescription)")
//            await MainActor.run {
//                self.availableUsers = []
//                self.isLoadingUsers = false
//                self.userLoadingError = error.localizedDescription
//            }
//        }
//    }
    
//    @MainActor
//       func fetchAvailableUsers() async {
//           print("Starting to fetch available users")
//           isLoadingUsers = true
//           userLoadingError = nil
//           do {
//               self.availableUsers = try await userManager.getAllUserss()
//               print("Fetched \(self.availableUsers.count) users")
//               self.isLoadingUsers = false
//           } catch {
//               print("Error fetching users: \(error.localizedDescription)")
//               self.availableUsers = []
//               self.isLoadingUsers = false
//               self.userLoadingError = error.localizedDescription
//           }
//       }
    
    //
    
//    func toggleUserSelection(_ userId: String) {
//        if selectedUserIDs.contains(userId) {
//            selectedUserIDs.remove(userId)
//        } else {
//            selectedUserIDs.insert(userId)
//        }
//    }
    
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
            dateCreated: nil,
            dueDate: quizDueDate
        )
        
        try await quizManager.updateQuizWithQuestions(quiz: updatedQuiz, questions: questions)
        
        // Assign quiz to selected users
        for userID in selectedUserIDs {
            try await userManager.assignQuizToUser(userID: userID, quizID: quizId, dueDate: quizDueDate)
        }
        
        // Remove quiz from unselected users
        let unselectedUsers = Set(availableUsers.compactMap { $0.id }).subtracting(selectedUserIDs)
        for userID in unselectedUsers {
            try await userManager.removeQuizFromUser(userID: userID, quizID: quizId)
        }
    }
    
//    func toggleUserSelection(_ userId: String) {
//            if selectedUserIDs.contains(userId) {
//                selectedUserIDs.remove(userId)
//            } else {
//                selectedUserIDs.insert(userId)
//            }
//            objectWillChange.send()
//        }
//    
//    func toggleAccountType(_ accountType: String) {
//           if selectedAccountTypes.contains(accountType) {
//               selectedAccountTypes.remove(accountType)
//               // Deselect users with this account type
//               selectedUserIDs = selectedUserIDs.filter { userID in
//                   availableUsers.first(where: { $0.id == userID })?.accountType != accountType
//               }
//           } else {
//               selectedAccountTypes.insert(accountType)
//               // Select users with this account type
//               let usersToAdd = availableUsers.filter { $0.accountType == accountType }.compactMap { $0.id }
//               selectedUserIDs.formUnion(usersToAdd)
//           }
//           objectWillChange.send()
//       }
    
    
    func fetchAvailableUsers() async {
            print("Starting to fetch available users")
            isLoadingUsers = true
            userLoadingError = nil
            do {
                self.availableUsers = try await userManager.getAllUsers()
                print("Fetched \(self.availableUsers.count) users")
                // Update selectedUserIDs based on the fetched users and the current quiz
                updateSelectedUsers()
                self.isLoadingUsers = false
            } catch {
                print("Error fetching users: \(error.localizedDescription)")
                self.availableUsers = []
                self.isLoadingUsers = false
                self.userLoadingError = error.localizedDescription
            }
        }

        private func updateSelectedUsers() {
            // Update selectedUserIDs based on the current quiz and fetched users
            selectedUserIDs = Set(availableUsers.filter { user in
                // Check if the user has this quiz assigned
                return user.quizScores?.contains(where: { $0.quizID == quizId }) ?? false
            }.compactMap { $0.id })
        }
       func toggleUserSelection(_ userId: String) {
           if selectedUserIDs.contains(userId) {
               selectedUserIDs.remove(userId)
           } else {
               selectedUserIDs.insert(userId)
           }
           objectWillChange.send()
       }

       func toggleAccountType(_ accountType: String) {
           if selectedAccountTypes.contains(accountType) {
               selectedAccountTypes.remove(accountType)
               // Deselect users with this account type
               selectedUserIDs = selectedUserIDs.filter { userID in
                   availableUsers.first(where: { $0.id == userID })?.accountType != accountType
               }
           } else {
               selectedAccountTypes.insert(accountType)
               // Select users with this account type
               let usersToAdd = availableUsers.filter { $0.accountType == accountType }.compactMap { $0.id }
               selectedUserIDs.formUnion(usersToAdd)
           }
           objectWillChange.send()
       }
}
struct EditQuizView: View {
    @ObservedObject var viewModel: EditQuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddQuestion = false
    @State private var newQuestion = Question(questionText: "", options: ["", "", "", ""], answer: "")
    @State private var refreshToggle = false
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
                                         set: { _ in viewModel.toggleAccountType(accountType.rawValue) }
                                     ))
                                 }
                             }
                
                Section(header: Text("Assign to Users")) {
                                   if viewModel.isLoadingUsers {
                                       ProgressView("Loading users...")
                                   } else if let error = viewModel.userLoadingError {
                                       Text("Error: \(error)")
                                           .foregroundColor(.red)
                                   } else if viewModel.availableUsers.isEmpty {
                                       Text("No users available")
                                   } else {
                                       ForEach(viewModel.availableUsers, id: \.id) { user in
                                           Toggle(isOn: Binding(
                                               get: { viewModel.selectedUserIDs.contains(user.id ?? "") },
                                               set: { _ in viewModel.toggleUserSelection(user.id ?? "") }
                                           )) {
                                               Text("\(user.username) - \(user.accountType)")
                                           }
                                       }
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
        .id(refreshToggle)
        .onAppear{
            Task {
                await viewModel.fetchAvailableUsers()
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
