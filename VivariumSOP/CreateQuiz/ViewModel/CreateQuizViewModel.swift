//
//  CreateQuizViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import PDFKit
import Vision
import UIKit


@MainActor

class CreateQuizViewModel: ObservableObject {
    @Published var quizTitle: String
    @Published var quizDescription = ""
    @Published var quizCategory: String
    @Published var quizCategoryID = UUID().uuidString
    @Published var quizDueDate = Date()
    @Published var questions: [Question] = []
    @Published var selectedAccountTypes = Set<String>()
    @Published var quizExists = false
    @Published var showAlert = false
    @Published var isLoading = false
    let availableAccountTypes = ["Husbandry", "Supervisor", "Admin", "Vet Services"] // Add more account types as needed
    private var existingQuizId: String?
    private let quizManager = QuizManager.shared
    @Published var alert: (title: String, message: String)?
    
   
    init(category: String, quizTitle: String) {
        self.quizCategory = category
          self.quizTitle = quizTitle
       // print("CreateQuizViewModel initialized with category: \(category), title: \(quizTitle)")
      //  print("CreateQuizViewModel initialized with category: \(category), title: \(quizTitle)")
        print("CreateQuizViewModel initialized with category: \(category), title: \(quizTitle)")
//        Task {
//                   await loadDatas()
//               }
    }
    
    func refreshQuiz() {
            isLoading = true
            Task {
                do {
                    if let existingQuiz = try await quizManager.getQuizByTitle(quizTitle) {
                        updateViewModelWithExistingQuiz(existingQuiz)
                    }
                    await MainActor.run {
                        isLoading = false
                    }
                } catch {
                    print("Error refreshing quiz: \(error)")
                    await MainActor.run {
                        isLoading = false
                    }
                }
            }
        }
    
//    func checkQuizExists() {
//           Task {
//               do {
//                   let existingQuiz = try await quizManager.getQuizByTitle(quizTitle)
//                   await MainActor.run {
//                       self.quizExists = existingQuiz != nil
//                       self.showAlert = self.quizExists
//                       if let quiz = existingQuiz {
//                           self.existingQuizId = quiz.id // Store the existing quiz ID
//                           self.updateViewModelWithExistingQuiz(quiz)
//                       }
//                   }
//               } catch {
//                   print("Error checking if quiz exists: \(error)")
//               }
//           }
//       }
       /// this was wroking
//       func uploadQuiz() async throws {
//           let quizToUpload = Quiz(
//               id: existingQuizId ?? UUID().uuidString, // Use existing ID if available
//               info: Info(
//                   title: quizTitle,
//                   description: quizDescription,
//                   peopleAttended: 0,
//                   rules: [""]
//               ),
//               quizCategory: quizCategory,
//               quizCategoryID: quizCategoryID,
//               accountTypes: Array(selectedAccountTypes),
//               dateCreated: existingQuizId == nil ? Date() : nil, // Only set creation date for new quizzes
//               dueDate: quizDueDate
//           )
//           
//           if existingQuizId != nil {
//               // Update existing quiz
//               try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
//           } else {
//               // Create new quiz
//               try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
//           }
//       }
//    func uploadQuiz() async throws {
//        // Upload the quiz and get the quiz ID
//        let uploadedQuizID = try await uploadQuizs()
//        
//        // Assign quiz to selected users
//        for userID in selectedUserIDs {
//            try await UserManager.shared.assignQuizToUser(userID: userID, quizID: uploadedQuizID, dueDate: quizDueDate)
//        }
//    }
    
//    func uploadQuizs() async throws -> String {
//        let quizToUpload = Quiz(
//            id: existingQuizId ?? UUID().uuidString,
//            info: Info(
//                title: quizTitle,
//                description: quizDescription,
//                peopleAttended: 0,
//                rules: [""]
//            ),
//            quizCategory: quizCategory,
//            quizCategoryID: quizCategoryID,
//            accountTypes: Array(selectedAccountTypes),
//            dateCreated: existingQuizId == nil ? Date() : nil,
//            dueDate: quizDueDate
//        )
//        
//        if let existingQuizId = existingQuizId {
//            // Update existing quiz
//            try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
//            return existingQuizId
//        } else {
//            // Create new quiz
//            let newQuizId = try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
//            return newQuizId
//        }
//    }
    private func updateViewModelWithExistingQuiz(_ quiz: Quiz) {
            self.quizDescription = quiz.info.description
            self.quizCategory = quiz.quizCategory
            self.quizCategoryID = quiz.quizCategoryID
            self.quizDueDate = quiz.dueDate ?? Date()
            self.selectedAccountTypes = Set(quiz.accountTypes)
            self.existingQuizId = quiz.id
            
            // Fetch questions for the existing quiz
            Task {
                do {
                    let fetchedQuestions = try await quizManager.getQuestionsForQuiz(quizId: quiz.id)
                    await MainActor.run {
                        self.questions = fetchedQuestions
                    }
                } catch {
                    print("Error fetching questions for existing quiz: \(error)")
                }
            }
        }
    
    
    /// asign quiz to user
    ///
    @Published var availableUsers: [User] = []
       @Published var selectedUserIDs: Set<String> = []
    func fetchAvailableUsers() {
           Task {
               do {
                   let users = try await UserManager.shared.getAllUserss()
                   await MainActor.run {
                       self.availableUsers = users
                   }
               } catch {
                   print("Error fetching users: \(error.localizedDescription)")
               }
           }
       }
       
//    func uploadQuiz() async throws {
//        // Upload the quiz and get the quiz ID
//        let uploadedQuizID = try await uploadQuizs()
//        
//        // Fetch the uploaded quiz
//        guard let uploadedQuiz = try await quizManager.getQuizByTitle(quizTitle) else {
//            throw NSError(domain: "CreateQuizViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Uploaded quiz not found"])
//        }
//        
//        // Assign quiz to selected users
//        for userID in selectedUserIDs {
//            do {
//                let user = try await UserManager.shared.fetchUser(by: userID)
//                try await UserManager.shared.assignQuizToUser(user: user, quiz: uploadedQuiz)
//            } catch {
//                print("Error assigning quiz to user \(userID): \(error)")
//            }
//        }
//    }
    func uploadQuiz() async throws {
        var quizToUpload = Quiz(
            id: existingQuizId ?? UUID().uuidString,
            info: Info(
                title: quizTitle,
                description: quizDescription,
                peopleAttended: 0,
                rules: [""]
            ),
            quizCategory: quizCategory,
            quizCategoryID: quizCategoryID,
            accountTypes: Array(selectedAccountTypes),
            dateCreated: existingQuizId == nil ? Date() : nil,
            dueDate: quizDueDate
        )

        if existingQuizId != nil {
            // Update existing quiz
            try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
        } else {
            // Create new quiz
            let newQuizId = try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
            quizToUpload.id = newQuizId
        }

        // Assign quiz to selected users
        for userID in selectedUserIDs {
            do {
                let user = try await UserManager.shared.fetchUser(by: userID)
                try await UserManager.shared.assignQuizToUser(user: user, quiz: quizToUpload)
            } catch {
                print("Error assigning quiz to user \(userID): \(error.localizedDescription)")
                // Optionally, you can throw an error here if you want to stop the process when a user assignment fails
                // throw error
            }
        }
    }

    func uploadQuizs() async throws -> String {
        let quizToUpload = Quiz(
            id: existingQuizId ?? UUID().uuidString,
            info: Info(
                title: quizTitle,
                description: quizDescription,
                peopleAttended: 0,
                rules: [""]
            ),
            quizCategory: quizCategory,
            quizCategoryID: quizCategoryID,
            accountTypes: Array(selectedAccountTypes),
            dateCreated: existingQuizId == nil ? Date() : nil,
            dueDate: quizDueDate
        )
        
        if let existingQuizId = existingQuizId {
            // Update existing quiz
            try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
            return existingQuizId
        } else {
            // Create new quiz
            let newQuizId = try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
            return newQuizId
        }
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

    func toggleUserSelection(_ userId: String) {
        if selectedUserIDs.contains(userId) {
            selectedUserIDs.remove(userId)
            // Update selectedAccountTypes if necessary
            if let user = availableUsers.first(where: { $0.id == userId }),
               !availableUsers.contains(where: { $0.id != userId && $0.accountType == user.accountType && selectedUserIDs.contains($0.id ?? "") }) {
                selectedAccountTypes.remove(user.accountType)
            }
        } else {
            selectedUserIDs.insert(userId)
            if let user = availableUsers.first(where: { $0.id == userId }) {
                selectedAccountTypes.insert(user.accountType)
            }
        }
        objectWillChange.send()
    }
    @Published var isDataLoaded = false
    @MainActor
       func loadDatas() async {
           print("Loading data for quiz title: \(quizTitle)")
           await checkQuizExists()
           await fetchAvailableUsers()
       }
    @MainActor
    func fetchAvailableUsers() async {
        do {
            self.availableUsers = try await UserManager.shared.getAllUserss()
        } catch {
            print("Error fetching users: \(error.localizedDescription)")
        }
    }
    @MainActor
    func checkQuizExists() async {
        do {
            let existingQuiz = try await quizManager.getQuizByTitle(quizTitle)
            self.quizExists = existingQuiz != nil
            self.showAlert = self.quizExists
            if let quiz = existingQuiz {
                self.existingQuizId = quiz.id
                self.updateViewModelWithExistingQuiz(quiz)
            }
        } catch {
            print("Error checking if quiz exists: \(error)")
        }
    }
    
    func checkQuizExists() {
        Task {
            do {
                print("Checking if quiz exists with title: \(quizTitle)")
                let existingQuiz = try await quizManager.getQuizByTitle(quizTitle)
                await MainActor.run {
                    self.quizExists = existingQuiz != nil
                    self.showAlert = self.quizExists
                    if let quiz = existingQuiz {
                        self.existingQuizId = quiz.id
                        self.updateViewModelWithExistingQuiz(quiz)
                        print("Existing quiz found with ID: \(quiz.id) for title: \(quizTitle)")
                    } else {
                        print("No existing quiz found for title: \(quizTitle)")
                    }
                }
            } catch {
                print("Error checking if quiz exists: \(error)")
            }
        }
    }
    
}
