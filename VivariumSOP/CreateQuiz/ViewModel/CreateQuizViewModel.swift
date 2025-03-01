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
    @Published var errorMessage: String?
    @Published var alert: (title: String, message: String)?
    
    @Published var verificationType: Quiz.VerificationType = .quiz
        @Published var acknowledgmentText: String = ""
   // @AppStorage("organizationId") private var organizationId: String = ""

   
//    init(category: String, quizTitle: String) {
//        self.quizCategory = category
//          self.quizTitle = quizTitle
//       // print("CreateQuizViewModel initialized with category: \(category), title: \(quizTitle)")
//      //  print("CreateQuizViewModel initialized with category: \(category), title: \(quizTitle)")
//        print("CreateQuizViewModel initialized with category: \(category), title: \(quizTitle)")
////        Task {
////                   await loadDatas()
////               }
//    }
//    
    init(category: String, quizTitle: String) {
          self.quizCategory = category
          self.quizTitle = quizTitle
          
          // Validate organization ID immediately
          let currentOrgId = UserDefaults.standard.string(forKey: "organizationId") ?? ""
          if currentOrgId.isEmpty {
              print("Error: Organization ID is missing during initialization")
              self.errorMessage = "Organization ID is missing. Please ensure you're properly logged in."
          } else {
              print("CreateQuizViewModel initialized with organizationId: \(currentOrgId)")
          }
      }
    func validateOrganization() -> Bool {
          let currentOrgId = organizationId
          if currentOrgId.isEmpty {
              errorMessage = "Organization ID is missing. Please ensure you're properly logged in."
              return false
          }
          return true
      }
    @AppStorage("organizationId") private var storedOrganizationId: String = ""
    private var organizationId: String {
           // Get the value directly from UserDefaults to ensure it's current
           UserDefaults.standard.string(forKey: "organizationId") ?? storedOrganizationId
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
//    func uploadQuiz() async throws {
//        var quizToUpload = Quiz(
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
//            dueDate: quizDueDate, organizationId: organizationId
//        )
//
//        if existingQuizId != nil {
//            // Update existing quiz
//            try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
//        } else {
//            // Create new quiz
//            let newQuizId = try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
//            quizToUpload.id = newQuizId
//        }
//
//        // Assign quiz to selected users
//        for userID in selectedUserIDs {
//            do {
//                let user = try await UserManager.shared.fetchUser(by: userID)
//                try await UserManager.shared.assignQuizToUser(user: user, quiz: quizToUpload)
//            } catch {
//                print("Error assigning quiz to user \(userID): \(error.localizedDescription)")
//                // Optionally, you can throw an error here if you want to stop the process when a user assignment fails
//                // throw error
//            }
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
//            dueDate: quizDueDate, organizationId: organizationId
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
//    
    
    
    
//    func toggleUserSelection(_ userId: String) {
//        if selectedUserIDs.contains(userId) {
//            selectedUserIDs.remove(userId)
//            // Update selectedAccountTypes if necessary
//            if let user = availableUsers.first(where: { $0.id == userId }),
//               !availableUsers.contains(where: { $0.id != userId && $0.accountType == user.accountType && selectedUserIDs.contains($0.id ?? "") }) {
//                selectedAccountTypes.remove(user.accountType)
//            }
//        } else {
//            selectedUserIDs.insert(userId)
//            if let user = availableUsers.first(where: { $0.id == userId }) {
//                selectedAccountTypes.insert(user.accountType)
//            }
//        }
//        objectWillChange.send()
//    }
    @Published var isDataLoaded = false
//    @MainActor
//       func loadDatas() async {
//           print("Loading data for quiz title: \(quizTitle)")
//           await checkQuizExists()
//           await fetchAvailableUsers()
//       }
//    @MainActor
//    func fetchAvailableUsers() async {
//        do {
//            self.availableUsers = try await UserManager.shared.getAllUserss()
//        } catch {
//            print("Error fetching users: \(error.localizedDescription)")
//        }
//    }
//    @MainActor
//    func checkQuizExists() async {
//        do {
//            let existingQuiz = try await quizManager.getQuizByTitle(quizTitle)
//            self.quizExists = existingQuiz != nil
//            self.showAlert = self.quizExists
//            if let quiz = existingQuiz {
//                self.existingQuizId = quiz.id
//                self.updateViewModelWithExistingQuiz(quiz)
//            }
//        } catch {
//            print("Error checking if quiz exists: \(error)")
//        }
//    }
//    
//    func checkQuizExists() {
//        Task {
//            do {
//                print("Checking if quiz exists with title: \(quizTitle)")
//                let existingQuiz = try await quizManager.getQuizByTitle(quizTitle)
//                await MainActor.run {
//                    self.quizExists = existingQuiz != nil
//                    self.showAlert = self.quizExists
//                    if let quiz = existingQuiz {
//                        self.existingQuizId = quiz.id
//                        self.updateViewModelWithExistingQuiz(quiz)
//                        print("Existing quiz found with ID: \(quiz.id) for title: \(quizTitle)")
//                    } else {
//                        print("No existing quiz found for title: \(quizTitle)")
//                    }
//                }
//            } catch {
//                print("Error checking if quiz exists: \(error)")
//            }
//        }
//    }
    
    ///NEW
    @MainActor
    func checkQuizExists() async {
          guard validateOrganization() else { return }
          
          do {
              print("Checking quiz existence for title: \(quizTitle) in organization: \(organizationId)")
              let existingQuiz = try await quizManager.getQuizByTitle(quizTitle, organizationId: organizationId)
              self.quizExists = existingQuiz != nil
              self.showAlert = self.quizExists
              
              if let quiz = existingQuiz {
                  self.existingQuizId = quiz.id
                  self.updateViewModelWithExistingQuiz(quiz)
                  print("Found existing quiz with ID: \(quiz.id)")
              } else {
                  print("No existing quiz found")
              }
          } catch {
              print("Error checking quiz existence: \(error)")
              self.errorMessage = error.localizedDescription
          }
      }
    
    func fetchAvailableUsers() async {
            do {
                // Fetch and filter users by organization
                let allUsers = try await UserManager.shared.getAllUserss()
                await MainActor.run {
                    self.availableUsers = allUsers.filter { $0.organizationId == self.organizationId }
                }
            } catch {
                print("Error fetching users: \(error.localizedDescription)")
            }
        }
        
        
    
//    func uploadQuiz() async throws {
//        guard validateOrganization() else {
//            throw NSError(domain: "CreateQuizViewModel", code: 400,
//                         userInfo: [NSLocalizedDescriptionKey: errorMessage ?? "Missing organization ID"])
//        }
//        
//        let currentOrgId = organizationId
//        print("Uploading quiz for organization: \(currentOrgId)")
//        
//        // Convert selectedAccountTypes to Array and print for debugging
//        let accountTypesArray = Array(selectedAccountTypes)
//        print("Selected Account Types: \(accountTypesArray)")
//        
//        // Create the quiz with verification type and account types
//        var quizToUpload = Quiz(
//            id: existingQuizId ?? UUID().uuidString,
//            info: Info(
//                title: quizTitle,
//                description: quizDescription,
//                peopleAttended: 0,
//                rules: [""]
//            ),
//            quizCategory: quizCategory,
//            quizCategoryID: quizCategoryID,
//            accountTypes: accountTypesArray,  // Make sure this is included
//            dateCreated: existingQuizId == nil ? Date() : nil,
//            dueDate: quizDueDate,
//            renewalFrequency: nil,
//            nextRenewalDates: nil,
//            customRenewalDate: nil,
//            organizationId: currentOrgId,
//            verificationType: verificationType,
//            acknowledgmentText: acknowledgmentText.isEmpty ? nil : acknowledgmentText,
//            questions: questions
//        )
//
//        print("DEBUG - Quiz being uploaded:")
//          print("ID: \(quizToUpload.id)")
//          print("Title: \(quizToUpload.info.title)")
//          print("VerificationType: \(quizToUpload.verificationType)")
//          print("Account Types: \(quizToUpload.accountTypes)")
//          print("Organization ID: \(quizToUpload.organizationId)")
//
//          if existingQuizId != nil {
//              print("DEBUG - Updating existing quiz")
//              try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
//          } else {
//              print("DEBUG - Creating new quiz")
//              let newQuizId = try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
//              print("DEBUG - New quiz ID: \(newQuizId)")
//          }
//
//        // Assign quiz to selected users within the same organization
//        for userID in selectedUserIDs {
//            do {
//                let user = try await UserManager.shared.fetchUser(by: userID)
//                if user.organizationId == organizationId {
//                    try await UserManager.shared.assignQuizToUser(user: user, quiz: quizToUpload)
//                } else {
//                    print("Warning: User \(userID) belongs to different organization (org: \(user.organizationId ?? "none"))")
//                }
//            } catch {
//                print("Error assigning quiz to user \(userID): \(error.localizedDescription)")
//            }
//        }
//    }
//   

    
//    
//        func uploadQuiz() async throws {
//        var quizToUpload = Quiz(
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
//            dueDate: quizDueDate,
//            organizationId: organizationId,
//            verificationType: verificationType,
//            acknowledgmentText: acknowledgmentText.isEmpty ? nil : acknowledgmentText,
//            questions: questions
//        )
//
//        if existingQuizId != nil {
//            try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
//        } else {
//            let newQuizId = try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
//            quizToUpload.id = newQuizId
//        }
//    }
//    
    
    func uploadQuiz() async throws {
        guard validateOrganization() else {
            throw NSError(domain: "CreateQuizViewModel", code: 400,
                         userInfo: [NSLocalizedDescriptionKey: errorMessage ?? "Missing organization ID"])
        }
        
        let currentOrgId = organizationId
        print("Uploading quiz for organization: \(currentOrgId)")
        
        // Convert selectedAccountTypes to Array and print for debugging
        let accountTypesArray = Array(selectedAccountTypes)
        print("Selected Account Types: \(accountTypesArray)")
        
        // Create the quiz with verification type and account types
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
            accountTypes: accountTypesArray,  // Make sure this is included
            dateCreated: existingQuizId == nil ? Date() : nil,
            dueDate: quizDueDate,
            renewalFrequency: nil,
            nextRenewalDates: nil,
            customRenewalDate: nil,
            organizationId: currentOrgId,
            verificationType: verificationType,
            acknowledgmentText: acknowledgmentText.isEmpty ? nil : acknowledgmentText,
            questions: questions
        )

     

        if existingQuizId != nil {
        
            try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
        } else {
          
            let newQuizId = try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
          
        }

        // Assign quiz to selected users within the same organization
        for userID in selectedUserIDs {
            do {
                let user = try await UserManager.shared.fetchUser(by: userID)
                if user.organizationId == organizationId {
                    try await UserManager.shared.assignQuizToUser(user: user, quiz: quizToUpload)
                } else {
                    print("Warning: User \(userID) belongs to different organization (org: \(user.organizationId ?? "none"))")
                }
            } catch {
                print("Error assigning quiz to user \(userID): \(error.localizedDescription)")
            }
        }
    }
    
    
//    func uploadQuiz() async throws {
//        guard validateOrganization() else {
//            throw NSError(domain: "CreateQuizViewModel", code: 400,
//                         userInfo: [NSLocalizedDescriptionKey: errorMessage ?? "Missing organization ID"])
//        }
//        
//        let currentOrgId = organizationId
//        print("Uploading quiz for organization: \(currentOrgId)")
//        
//        let accountTypesArray = Array(selectedAccountTypes)
//        print("Selected Account Types: \(accountTypesArray)")
//        
//        var quizToUpload = Quiz(
//            id: existingQuizId ?? UUID().uuidString,
//            info: Info(
//                title: quizTitle,
//                description: quizDescription,
//                peopleAttended: 0,
//                rules: [""]
//            ),
//            quizCategory: quizCategory,
//            quizCategoryID: quizCategoryID,
//            accountTypes: accountTypesArray,
//            dateCreated: existingQuizId == nil ? Date() : nil,
//            dueDate: quizDueDate,
//            renewalFrequency: nil,
//            nextRenewalDates: nil,
//            customRenewalDate: nil,
//            organizationId: currentOrgId,
//            verificationType: verificationType,
//            acknowledgmentText: acknowledgmentText.isEmpty ? nil : acknowledgmentText,
//            questions: questions
//        )
//
//        print("DEBUG - Quiz being uploaded:")
//        print("ID: \(quizToUpload.id)")
//        print("Title: \(quizToUpload.info.title)")
//        print("VerificationType: \(quizToUpload.verificationType)")
//        print("Account Types: \(quizToUpload.accountTypes)")
//        print("Organization ID: \(quizToUpload.organizationId)")
//        print("Selected User IDs: \(selectedUserIDs)")
//
//        // First upload or update the quiz
//        if existingQuizId != nil {
//            print("DEBUG - Updating existing quiz")
//            try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
//        } else {
//            print("DEBUG - Creating new quiz")
//            let newQuizId = try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
//            quizToUpload.id = newQuizId
//            print("DEBUG - New quiz ID: \(newQuizId)")
//        }
//
//        // Then assign to users - make sure this runs after quiz is created
//        print("Starting user assignments...")
//        for userID in selectedUserIDs {
//            do {
//                guard let user = try await UserManager.shared.fetchUser(by: userID) else {
//                    print("Warning: Could not find user with ID: \(userID)")
//                    continue
//                }
//                
//                if user.organizationId == organizationId {
//                    print("Assigning quiz to user: \(user.username)")
//                    try await UserManager.shared.assignQuizToUser(user: user, quiz: quizToUpload)
//                    print("Successfully assigned quiz to user: \(user.username)")
//                } else {
//                    print("Warning: User \(userID) belongs to different organization (org: \(user.organizationId ?? "none"))")
//                }
//            } catch {
//                print("Error assigning quiz to user \(userID): \(error.localizedDescription)")
//            }
//        }
//    }
//    func toggleAccountType(_ accountType: String) {
//        if selectedAccountTypes.contains(accountType) {
//            selectedAccountTypes.remove(accountType)
//            // Deselect users with this account type
//            selectedUserIDs = selectedUserIDs.filter { userID in
//                availableUsers.first(where: { $0.id == userID })?.accountType != accountType
//            }
//        } else {
//            selectedAccountTypes.insert(accountType)
//            // Select users with this account type
//            let usersToAdd = availableUsers.filter { $0.accountType == accountType }.compactMap { $0.id }
//            selectedUserIDs.formUnion(usersToAdd)
//        }
//        print("Current selectedAccountTypes after toggle: \(selectedAccountTypes)")
//        objectWillChange.send()
//    }
    func uploadQuizs() async throws -> String {
        guard !organizationId.isEmpty else {
            throw NSError(domain: "CreateQuizViewModel",
                         code: 400,
                         userInfo: [NSLocalizedDescriptionKey: "Organization ID is missing"])
        }
        
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
            dueDate: quizDueDate,
            renewalFrequency: nil,
            nextRenewalDates: nil,
            customRenewalDate: nil,
            organizationId: organizationId,
            verificationType: .quiz,  // Set default verification type to .quiz
            acknowledgmentText: nil,  // Add optional acknowledgment text
            questions: questions      // Include questions array
        )
        
        print("Quiz being uploaded with organizationId: \(quizToUpload.organizationId)")
        
        if let existingQuizId = existingQuizId {
            try await quizManager.updateQuizWithQuestions(quiz: quizToUpload, questions: questions)
            return existingQuizId
        } else {
            let newQuizId = try await quizManager.uploadQuizWithQuestions(quiz: quizToUpload, questions: questions)
            return newQuizId
        }
    }
    ///
//        func toggleUserSelection(_ userId: String) {
//            // Only allow selection of users from the same organization
//            guard let user = availableUsers.first(where: { $0.id == userId }),
//                  user.organizationId == organizationId else {
//                return
//            }
//            
//            if selectedUserIDs.contains(userId) {
//                selectedUserIDs.remove(userId)
//                if !availableUsers.contains(where: { $0.id != userId &&
//                                                   $0.accountType == user.accountType &&
//                                                   selectedUserIDs.contains($0.id ?? "") }) {
//                    selectedAccountTypes.remove(user.accountType)
//                }
//            } else {
//                selectedUserIDs.insert(userId)
//                selectedAccountTypes.insert(user.accountType)
//            }
//            objectWillChange.send()
//        }
//        
    
    
    // Fixed toggleUserSelection method - only affects the user, not the account type
    func toggleUserSelection(_ userId: String) {
        // Find the user first
        guard let user = availableUsers.first(where: { $0.id == userId }) else {
            return
        }
        
        if selectedUserIDs.contains(userId) {
            // Remove user from selection
            selectedUserIDs.remove(userId)
            
            // We DON'T modify selectedAccountTypes here regardless of selection status
            // The account type stays selected even if we deselect the last user of that type
        } else {
            // Add user to selection
            selectedUserIDs.insert(userId)
            
            // We also DON'T add the account type automatically
            // Account types should only be toggled through the account type toggles
        }
        
        // Notify observers that the state has changed
        objectWillChange.send()
    }

    // The toggleAccountType method remains the same - it affects all users of that type
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
        print("Current selectedAccountTypes after toggle: \(selectedAccountTypes)")
        objectWillChange.send()
    }
    
        @MainActor
        func loadDatas() async {
            print("Loading data for quiz title: \(quizTitle) in organization: \(organizationId)")
            await checkQuizExists()
            await fetchAvailableUsers()
        }
}
