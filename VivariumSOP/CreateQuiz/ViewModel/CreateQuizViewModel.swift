//
//  CreateQuizViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
//class CreateQuizViewModel: ObservableObject {
//    @Published var quizTitle = ""
//    @Published var quizCategory = ""
//    @Published var quizDueDate = Date()
//    @Published var questions: [Question] = []
//    @Published var quizzes: [Quiz] = []
//    @Published var users: [User] = []
//    
//    private let quizManager = QuizManager.shared
//    private let userManager = UserManager.shared
//    
//    func uploadQuiz() async throws {
//        let newQuiz = Quiz(id: UUID().uuidString,
//                           info: Info(title: quizTitle, description: "", peopleAttended: 0, rules: [""]),
//                           quizCategory: quizCategory,
//                           quizCategoryID: UUID().uuidString,
//                           accountTypes: [],
//                           dateCreated: Date(),
//                           dueDate: quizDueDate)
//        
//        try await quizManager.uploadQuizWithQuestions(quiz: newQuiz, questions: questions)
//    }
//    
//    func fetchAllQuizzes() async {
//        do {
//            quizzes = try await quizManager.fetchAllQuizzes()
//        } catch {
//            print("Error fetching quizzes: \(error)")
//        }
//    }
//    
//    func fetchQuizzesByCategory(_ category: String) async {
//        do {
//            quizzes = try await quizManager.getQuizList(category: category)
//        } catch {
//            print("Error fetching quizzes by category: \(error)")
//        }
//    }
//    
//    func fetchQuizzesByIds(_ ids: [String]) async {
//        do {
//            quizzes = try await quizManager.fetchQuizzesByIds(ids)
//        } catch {
//            print("Error fetching quizzes by IDs: \(error)")
//        }
//    }
//    
//    func updateQuizDueDate(quizId: String, newDate: Date) async {
//        do {
//            try await quizManager.updateQuizDueDate(quizId: quizId, newDate: newDate)
//            // Optionally, refresh the quizzes after updating
//            await fetchAllQuizzes()
//        } catch {
//            print("Error updating quiz due date: \(error)")
//        }
//    }
//    
//    func fetchAllUsers() async {
//        do {
//            users = try await userManager.getAllUsers()
//        } catch {
//            print("Error fetching users: \(error)")
//        }
//    }
//    
//    func fetchUsersWithCompletedQuizzes(quizId: String? = nil) async {
//        do {
//            users = try await userManager.getUsersWithCompletedQuizzes(quizId: quizId)
//        } catch {
//            print("Error fetching users with completed quizzes: \(error)")
//        }
//    }
//    
//    func fetchUser(by userId: String) async {
//        do {
//            let user = try await userManager.fetchUser(by: userId)
//            users = [user] // Replace the users array with the single fetched user
//        } catch {
//            print("Error fetching user: \(error)")
//        }
//    }
//    
//    func updateUserQuizScore(userID: String, quizID: String, newScore: CGFloat) async {
//        do {
//            try await userManager.updateUserQuizScore(userID: userID, quizID: quizID, newScore: newScore)
//            // Optionally, refresh the user data after updating
//            await fetchUser(by: userID)
//        } catch {
//            print("Error updating user quiz score: \(error)")
//        }
//    }
//}

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
    let availableAccountTypes = ["Husbandry", "Supervisor"] // Add more account types as needed
    private var existingQuizId: String?
    private let quizManager = QuizManager.shared
    
    init(category: String, quizTitle: String) {
        self.quizCategory = category
        self.quizTitle = quizTitle
        print("CreateQuizViewModel initialized with category: \(category), title: \(quizTitle)")
        checkQuizExists()
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
    
    func checkQuizExists() {
           Task {
               do {
                   let existingQuiz = try await quizManager.getQuizByTitle(quizTitle)
                   await MainActor.run {
                       self.quizExists = existingQuiz != nil
                       self.showAlert = self.quizExists
                       if let quiz = existingQuiz {
                           self.existingQuizId = quiz.id // Store the existing quiz ID
                           self.updateViewModelWithExistingQuiz(quiz)
                       }
                   }
               } catch {
                   print("Error checking if quiz exists: \(error)")
               }
           }
       }
       
       func uploadQuiz() async throws {
           let quizToUpload = Quiz(
               id: existingQuizId ?? UUID().uuidString, // Use existing ID if available
               info: Info(
                   title: quizTitle,
                   description: quizDescription,
                   peopleAttended: 0,
                   rules: [""]
               ),
               quizCategory: quizCategory,
               quizCategoryID: quizCategoryID,
               accountTypes: Array(selectedAccountTypes),
               dateCreated: existingQuizId == nil ? Date() : nil, // Only set creation date for new quizzes
               dueDate: quizDueDate
           )
           
           if existingQuizId != nil {
               // Update existing quiz
               try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
           } else {
               // Create new quiz
               try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
           }
       }
    
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
}
