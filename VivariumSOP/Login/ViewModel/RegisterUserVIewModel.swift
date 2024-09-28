//
//  RegisterUserVIewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore


@MainActor
final class RegisterUserViewModel: ObservableObject {
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("account_Type") var userAccountType: String = ""

    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var accountType: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var facilityName: String = ""
    
    @Published var selectedCategoryIDs = Set<String>()
    @Published var availableCategories = [Categorys]()
    
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    
  
        func validateForm() -> Bool {
            if email.isEmpty {
                setError("Email cannot be empty")
                return false
            }
            
            if !isValidEmail(email) {
                setError("Please enter a valid email address")
                return false
            }
            
            if password.isEmpty {
                setError("Password cannot be empty")
                return false
            }
            
            if password.count < 8 {
                setError("Password must be at least 8 characters long")
                return false
            }
            
            if password != confirmPassword {
                setError("Passwords do not match")
                return false
            }
            
            if username.isEmpty {
                setError("Username cannot be empty")
                return false
            }
            
            if accountType.isEmpty {
                setError("Please select an account type")
                return false
            }
            
            if firstName.isEmpty {
                setError("First name cannot be empty")
                return false
            }
            
            if lastName.isEmpty {
                setError("Last name cannot be empty")
                return false
            }
            
            if facilityName.isEmpty {
                setError("Facility name cannot be empty")
                return false
            }
            
            return true
        }
        
        private func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
    func validateEmail(_ email: String) -> (Bool, String?) {
          let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
          let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
          let isValid = emailPred.evaluate(with: email)
          return (isValid, isValid ? nil : "Please enter a valid email address")
      }

      func validatePassword(_ password: String) -> (Bool, String?) {
          let isValid = password.count >= 8
          return (isValid, isValid ? nil : "Password must be at least 8 characters long")
      }
//    func registerUser() {
//        guard validateForm() else { return }
//        
//        isLoading = true
//        Task {
//            do {
//                // Step 1: Create Authentication User
//                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
//                let userUID = authResult.user.uid
//                
//                print("Authentication user created with UID: \(userUID)")
//                
//                // Step 2: Fetch relevant quizzes based on account type
//                let relevantQuizzes = try await fetchQuizzesForAccountType(accountType)
//                
//                // Step 3: Create initial quiz scores for the user
//                let initialQuizScores = relevantQuizzes.map { quiz in
//                    UserQuizScore(quizID: quiz.id,
//                                  scores: [],
//                                  completionDates: [],
//                                  dueDates: [quiz.id: quiz.dueDate])
//                }
//                
//                // Step 4: Create Firestore User Document
//                let user = User(id: userUID,
//                                firstName: firstName,
//                                lastName: lastName,
//                                facilityName: facilityName,
//                                username: username,
//                                userUID: userUID,
//                                userEmail: email,
//                                accountType: accountType,
//                                userPDFProgress: UserPDFProgress(userID: userUID, completedPDFs: []),
//                                NHPAvalible: true,
//                                assignedCategoryIDs: Array(selectedCategoryIDs),
//                                quizScores: initialQuizScores,
//                                floor: "1st")
//                
//                do {
//                    try await Firestore.firestore().collection("Users").document(userUID).setData(from: user)
//                    print("Firestore user document created successfully with \(initialQuizScores.count) assigned quizzes")
//                } catch {
//                    print("Error creating Firestore user document: \(error.localizedDescription)")
//                    // Optionally, delete the authentication user if Firestore document creation fails
//                    // try await Auth.auth().currentUser?.delete()
//                    throw error
//                }
//                
//                // Step 5: Update ViewModel State
//                await MainActor.run {
//                    self.userUID = userUID
//                    self.userNameStored = username
//                    self.userAccountType = accountType
//                    self.logStatus = true
//                    self.isLoading = false
//                }
//                
//                print("User registration completed successfully")
//            } catch {
//                print("Error during user registration: \(error.localizedDescription)")
//                if let error = error as NSError? {
//                    print("Error domain: \(error.domain)")
//                    print("Error code: \(error.code)")
//                }
//                await setError(error.localizedDescription)
//            }
//        }
//    }

  
    /// working form
//    func registerUser() {
//        guard validateForm() else { return }
//        
//        isLoading = true
//        Task {
//            do {
//                // Step 1: Create Authentication User
//                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
//                let userUID = authResult.user.uid
//                
//                print("Authentication user created with UID: \(userUID)")
//                
//                // Step 2: Fetch relevant quizzes based on account type
//                let relevantQuizzes = try await fetchQuizzesForAccountType(accountType)
//                
//                // Step 3: Create initial quiz scores for the user
//                let initialQuizScores = relevantQuizzes.map { quiz in
//                    UserQuizScore(
//                        quizID: quiz.id,
//                        scores: [],
//                        completionDates: [],
//                        dueDate: [quiz.id: quiz.dueDate ?? Date().addingTimeInterval(7 * 24 * 60 * 60)] // Default to 1 week from now if no due date
//                    )
//                }
//                
//                // Step 4: Create Firestore User Document
//                let user = User(
//                    id: userUID,
//                    firstName: firstName,
//                    lastName: lastName,
//                    facilityName: facilityName,
//                    username: username,
//                    userUID: userUID,
//                    userEmail: email,
//                    accountType: accountType,
//                    userPDFProgress: UserPDFProgress(userID: userUID, completedPDFs: []),
//                    NHPAvalible: true,
//                    assignedCategoryIDs: Array(selectedCategoryIDs),
//                    quizScores: initialQuizScores,
//                    floor: "1st"
//                )
//                
//                // Step 5: Save user to Firestore
//                let db = Firestore.firestore()
//                do {
//                    try await db.collection("Users").document(userUID).setData(from: user)
//                    print("Firestore user document created successfully with \(initialQuizScores.count) assigned quizzes")
//                    
//                    // Print assigned quizzes for verification
//                    for quizScore in initialQuizScores {
//                        print("Assigned quiz: \(quizScore.quizID), Due date: \(quizScore.dueDates?[quizScore.quizID] ?? Date())")
//                    }
//                } catch {
//                    print("Error creating Firestore user document: \(error.localizedDescription)")
//                    throw error
//                }
//                
//                // Step 6: Update ViewModel State
//                await MainActor.run {
//                    self.userUID = userUID
//                    self.userNameStored = username
//                    self.userAccountType = accountType
//                    self.logStatus = true
//                    self.isLoading = false
//                }
//                
//                print("User registration completed successfully")
//            } catch {
//                print("Error during user registration: \(error.localizedDescription)")
//                if let error = error as NSError? {
//                    print("Error domain: \(error.domain)")
//                    print("Error code: \(error.code)")
//                }
//                await setError(error.localizedDescription)
//            }
//        }
//    }
//
//    
    func registerUser() {
        guard validateForm() else { return }
        
        isLoading = true
        Task {
            do {
                // Step 1: Create Authentication User
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                let userUID = authResult.user.uid
                
                print("Authentication user created with UID: \(userUID)")
                
                // Step 2: Fetch relevant quizzes based on account type
                let relevantQuizzes = try await fetchQuizzesForAccountType(accountType)
                
                // Step 3: Create initial quiz scores for the user
                let initialQuizScores = relevantQuizzes.map { quiz in
                    UserQuizScore(
                        quizID: quiz.id,
                        scores: [],
                        completionDates: [],
                        dueDates: [quiz.id: quiz.dueDate ?? Date().addingTimeInterval(7 * 24 * 60 * 60)], // Default to 1 week from now if no due date
                        nextRenewalDates: nil
                    )
                }
                
                // Step 4: Create Firestore User Document
                let user = User(
                    id: userUID,
                    firstName: firstName,
                    lastName: lastName,
                    facilityName: facilityName,
                    username: username,
                    userUID: userUID,
                    userEmail: email,
                    accountType: accountType,
                    userPDFProgress: UserPDFProgress(userID: userUID, completedPDFs: []),
                    NHPAvalible: true,
                    assignedCategoryIDs: Array(selectedCategoryIDs),
                    quizScores: initialQuizScores,
                    floor: "1st"
                )
                
                // Step 5: Save user to Firestore
                let db = Firestore.firestore()
                do {
                    try await db.collection("Users").document(userUID).setData(from: user)
                    print("Firestore user document created successfully with \(initialQuizScores.count) assigned quizzes")
                    
                    // Print assigned quizzes for verification
                    for quizScore in initialQuizScores {
                        if let dueDate = quizScore.dueDates?[quizScore.quizID] {
                            print("Assigned quiz: \(quizScore.quizID), Due date: \(dueDate)")
                        } else {
                            print("Assigned quiz: \(quizScore.quizID), Due date: Not set")
                        }
                    }
                } catch {
                    print("Error creating Firestore user document: \(error.localizedDescription)")
                    throw error
                }
                
                // Step 6: Update ViewModel State
                await MainActor.run {
                    self.userUID = userUID
                    self.userNameStored = username
                    self.userAccountType = accountType
                    self.logStatus = true
                    self.isLoading = false
                }
                
                print("User registration completed successfully")
            } catch {
                print("Error during user registration: \(error.localizedDescription)")
                if let error = error as NSError? {
                    print("Error domain: \(error.domain)")
                    print("Error code: \(error.code)")
                }
                await setError(error.localizedDescription)
            }
        }
    }
    
//    func fetchQuizzesForAccountType(_ accountType: String) async throws -> [Quiz] {
//        let db = Firestore.firestore()
//        print("Fetching quizzes for account type: \(accountType)")
//        
//        let quizSnapshot = try await db.collection("Quiz")
//            .whereField("accountTypes", arrayContains: accountType)
//            .getDocuments()
//        
//        print("Query returned \(quizSnapshot.documents.count) documents")
//        
//        let quizzes = quizSnapshot.documents.compactMap { document -> Quiz? in
//            do {
//                let quiz = try document.data(as: Quiz.self)
//                print("Successfully decoded quiz: \(quiz.id), title: \(quiz.info.title), accountTypes: \(quiz.accountTypes)")
//                return quiz
//            } catch {
//                print("Error decoding quiz document \(document.id): \(error)")
//                print("Document data: \(document.data() ?? [:])")
//                return nil
//            }
//        }
//        
//        print("Successfully decoded \(quizzes.count) quizzes for account type: \(accountType)")
//       
    
    func fetchQuizzesForAccountType(_ accountType: String) async throws -> [Quiz] {
        let db = Firestore.firestore()
        let quizSnapshot = try await db.collection("Quiz")
            .whereField("accountTypes", arrayContains: accountType)
            .getDocuments()
        
        return quizSnapshot.documents.compactMap { document in
            try? document.data(as: Quiz.self)
        }
    }
        private func setError(_ message: String) {
            self.errorMessage = message
            self.showError = true
            self.isLoading = false
        }

        // ... (keep all other methods as they are)
    }


