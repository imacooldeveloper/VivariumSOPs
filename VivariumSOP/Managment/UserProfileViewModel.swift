//
//  UserProfileViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/25/24.
//

import Foundation
import Foundation
import Firebase
import FirebaseAuth
import Combine
import SwiftUI
@MainActor
final class UserProfileViewModel: ObservableObject {
    
    @Published var completedQuizzes: [Quiz] = []
    @Published var quizzesWithScores: [QuizWithScore] = []
    @Published var uncompletedQuizzes: [Quiz] = [] // New array to hold uncompleted quizzes
    @Published var users: User?
    @Published var userSelected: User?
    @Published var userss: [User] = []
    @Published private(set) var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    func fetchCompletedQuizzes() async {
        guard let userUID = Auth.auth().currentUser?.uid else {return} // make sure we have a user ID
        
        
        do {
            let user = try await UserManager.shared.fetchUser(by: userUID)
            let completedQuizIds = user.quizScores?.map { $0.quizID } ?? []
            print(user.username)
            let quizzes = try await QuizManager.shared.fetchQuizzesByIds(completedQuizIds)
            self.completedQuizzes = quizzes
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
//    @MainActor
//    func setDueDateForFailedQuiz(user: User, quizID: String, newDueDate: Date) async {
//           guard var updatedUser = self.user else { return }
//           
//           if var quizScore = updatedUser.quizScores?.first(where: { $0.quizID == quizID }) {
//               quizScore.dueDates = [quizID: newDueDate]
//               if let index = updatedUser.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
//                   updatedUser.quizScores?[index] = quizScore
//               }
//           } else {
//               let newQuizScore = UserQuizScore(quizID: quizID, scores: [], completionDates: [], dueDates: [quizID: newDueDate])
//               
//               
//               //QuizScore(quizID: quizID, scores: [], dueDates: [quizID: newDueDate])
//               
//               
//               updatedUser.quizScores?.append(newQuizScore)
//           }
//           
//           do {
//               try await Firestore.firestore().collection("users").document(updatedUser.userUID).updateData([
//                   "quizScores": updatedUser.quizScores?.map { $0.toDictionary() } ?? []
//               ])
//               await MainActor.run {
//                   self.user = updatedUser
//               }
//           } catch {
//               print("Error updating due date: \(error.localizedDescription)")
//           }
//       }
    
    /// updating
    @MainActor
    func fetchHighScoreQuizzes(minScore: CGFloat = 80.0) async {
        guard let userUID = Auth.auth().currentUser?.uid else { return } // Ensure we have a user ID
        
        do {
            let user = try await UserManager.shared.fetchUser(by: userUID)
            
            // Filter quizScores to only include those with scores above the threshold
            let highScoreQuizIDs = user.quizScores?
                .filter { $0.scores.max() ?? 0 >= minScore }
                .map { $0.quizID } ?? []
            
            print("User: \(user.username), Quizzes with scores above \(minScore)%: \(highScoreQuizIDs)")
            
            // Fetch the quizzes with IDs that match the high scores
            let highScoreQuizzes = try await QuizManager.shared.fetchQuizzesByIds(highScoreQuizIDs)
            
            self.completedQuizzes = highScoreQuizzes
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    @MainActor
    func fetchCompletedQuizzesAndScores() async {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("No user UID found")
            return
        }
        do {
            let user = try await UserManager.shared.fetchUser(by: userUID)
            print("User fetched: \(user.username)")
            users = user
            
            var tempQuizzesWithScores: [QuizWithScore] = []
            var completedQuizIds: Set<String> = []
            
            let allQuizzes = try await QuizManager.shared.getAllQuiz()
            print("Total quizzes fetched: \(allQuizzes.count)")
            
            for quizScore in user.quizScores ?? [] {
                let highestScore = quizScore.scores.max() ?? 0
                print("Processing quiz ID: \(quizScore.quizID), highest score: \(highestScore)")
                if let quiz = allQuizzes.first(where: { $0.id == quizScore.quizID }) {
                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                    tempQuizzesWithScores.append(quizWithScore)
                    if highestScore >= 80.0 {
                        completedQuizIds.insert(quiz.id)
                    }
                }
            }
            self.quizzesWithScores = tempQuizzesWithScores
            print("Quizzes with scores: \(quizzesWithScores.count)")
            
            print("Completed quiz IDs: \(completedQuizIds)")
            self.uncompletedQuizzes = allQuizzes.filter { quiz in
                if completedQuizIds.contains(quiz.id) {
                    return false // Quiz is completed with score >= 80
                }
                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
                    if quizScore.scores.isEmpty {
                        return true // Quiz is uncompleted if scores array is empty
                    }
                    if let highestScore = quizScore.scores.max() {
                        return highestScore < 80.0 // Quiz is uncompleted if highest score is less than 80%
                    }
                }
                return true // Quiz is uncompleted if there's no score entry
            }
            print("Uncompleted quizzes: \(uncompletedQuizzes.count)")
            
            // Print details of uncompleted quizzes
            for quiz in uncompletedQuizzes {
                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
                    print("Uncompleted Quiz: \(quiz.id), Highest Score: \(quizScore.scores.max() ?? 0)")
                } else {
                    print("Uncompleted Quiz: \(quiz.id), Not Attempted")
                }
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    @MainActor
    func fecthAllUser() async throws {
        userss = try await UserManager.shared.getAllUser().sorted{$0.username < $1.username}
        print(userss.first)
    }
    @MainActor
    func fecthAllUserReturn() async throws -> [User] {
        try await UserManager.shared.getAllUser().sorted{$0.username < $1.username}
        
    }
    @MainActor
    func fetchCompletedQuizzesAndScoresForAllUsers() async {
        do {
            let allUsers = try await UserManager.shared.getAllUser().sorted{$0.username < $1.username} // Ensure this method exists and fetches all users
            
            // users = allUsers
            for user in userss {
                print("User: \(user.username) with \(user.quizScores?.count ?? 0) scores")
                
                var tempQuizzesWithScores: [QuizWithScore] = []
                for quizScore in user.quizScores ?? [] {
                    let highestScore = quizScore.scores.max() ?? 0
                    print("Processing quiz ID: \(quizScore.quizID), highest score: \(highestScore)")
                    let quizzes = try await QuizManager.shared.fetchQuizzesByIds([quizScore.quizID])
                    for quiz in quizzes {
                        let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                        tempQuizzesWithScores.append(quizWithScore)
                    }
                }
                self.quizzesWithScores = tempQuizzesWithScores
                
                let allQuizzes = try await QuizManager.shared.getAllQuiz()
                let completedQuizIds = Set(user.quizScores?.map { $0.quizID } ?? [])
                self.uncompletedQuizzes = allQuizzes.filter { !completedQuizIds.contains($0.id) }
                
                print("Completed quiz IDs for user \(user.username): \(completedQuizIds)")
                print("Uncompleted quizzes for user \(user.username): \(uncompletedQuizzes.count)")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchNonCompletedQuizzesAndScores() async {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        do {
            let user = try await UserManager.shared.fetchUser(by: userUID)
            users = user
            
            var tempQuizzesWithScores: [QuizWithScore] = []
            for quizScore in user.quizScores ?? [] {
                let highestScore = quizScore.scores.max() ?? 0
                let quizzes = try await QuizManager.shared.fetchQuizzesByIds([quizScore.quizID])
                for quiz in quizzes {
                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                    tempQuizzesWithScores.append(quizWithScore)
                }
            }
            self.quizzesWithScores = tempQuizzesWithScores
            
            // Fetch all quizzes to determine uncompleted ones
            let allQuizzes = try await QuizManager.shared.getAllQuiz()
            let completedQuizIds = Set(user.quizScores?.map { $0.quizID } ?? [])
            self.uncompletedQuizzes = allQuizzes.filter { !completedQuizIds.contains($0.id) }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
  
    @MainActor
    func fetchCompletedQuizzesAndScoresof(user: User) async {
        do {
            let user = try await UserManager.shared.fetchUser(by: user.userUID)
            users = user
            
            var tempQuizzesWithScores: [QuizWithScore] = []
            for quizScore in user.quizScores ?? [] {
                let highestScore = quizScore.scores.max() ?? 0
                let quizzes = try await QuizManager.shared.fetchQuizzesByIds([quizScore.quizID])
                for quiz in quizzes {
                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                    tempQuizzesWithScores.append(quizWithScore)
                }
            }
            self.quizzesWithScores = tempQuizzesWithScores
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
  
 
    @MainActor
    func updateUserQuizDueDate(for user: User?, quizID: String, newDate: Date) {
        guard var user = user else {
            print("User not found.")
            return
        }

        if user.quizScores == nil {
            user.quizScores = []
        }

        if let index = user.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
            if user.quizScores?[index].dueDates == nil {
                user.quizScores?[index].dueDates = [:]
            }
            user.quizScores?[index].dueDates?[quizID] = newDate
        } else {
            let newScore = UserQuizScore(quizID: quizID, scores: [], completionDates: [], dueDates: [quizID: newDate])
            user.quizScores?.append(newScore)
        }

        // Update Firebase with the new user data
        do {
            let db = Firestore.firestore()
            let userRef = db.collection("Users").document(user.userUID)
            try userRef.setData(from: user, merge: true) { [weak self] error in
                if let error = error {
                    print("Failed to update due date: \(error.localizedDescription)")
                } else {
                    print("Due date updated successfully for quizID: \(quizID) with new date: \(newDate).")
                    self?.fetchUserData(userUID: user.userUID, quizID: quizID)
                }
            }
        } catch {
            print("Failed to encode user: \(error.localizedDescription)")
        }
    }

    // Fetch user data to verify if the due date was updated
    @MainActor
    func fetchUserData(userUID: String, quizID: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userUID)
        
        userRef.getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let data = document.data()
                print("Updated user data fetched: \(String(describing: data))")
                if let quizScores = data?["quizScores"] as? [[String: Any]],
                   let quizScore = quizScores.first(where: { $0["quizID"] as? String == quizID }),
                   let dueDates = quizScore["dueDates"] as? [String: Timestamp],
                   let updatedDueDate = dueDates[quizID] {
                    print("Verified due date in Firestore for quizID \(quizID): \(updatedDueDate.dateValue())")
                } else {
                    print("Due date not found in updated user data for quizID: \(quizID).")
                }
            } else if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            }
        }
    }

    // Update quiz lists based on user data
    func updateQuizLists() {
        guard let user = users else {
            print("User data is not available.")
            return
        }
        
        // Extract completed quiz IDs from user.quizScores
        let completedQuizIds = user.quizScores?
            .flatMap { quizScore in quizScore.completionDates.map { _ in quizScore.quizID } } ?? []
        
        // Update completedQuizzes by filtering quizzesWithScores and extracting the quiz part
        completedQuizzes = quizzesWithScores
            .filter { completedQuizIds.contains($0.quiz.id) }
            .map { $0.quiz }
        
        // Update uncompletedQuizzes by filtering quizzesWithScores and extracting the quiz part
        uncompletedQuizzes = quizzesWithScores
            .filter { !completedQuizIds.contains($0.quiz.id) }
            .map { $0.quiz }
    }
    
    @MainActor
    func fetchUserQuizScores(userId: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("users").document(userId)
        
        documentRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let quizScores = data?["quizScores"] as? [[String: Any]] ?? []
                print("Fetched quizScores for user \(userId): \(quizScores)")
            } else if let error = error {
                print("Error fetching quiz scores: \(error.localizedDescription)")
            } else {
                print("No document found for user \(userId).")
            }
        }
    }
    func createUserDocument(userId: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("users").document(userId)
        
        let newQuizScore: [String: Any] = [
            "quizID": "",
            "scores": [],
            "completionDates": [],
            "dueDates": [:]
        ]
        let userData: [String: Any] = [
            "quizScores": [newQuizScore]
        ]
        
        documentRef.setData(userData) { error in
            if let error = error {
                print("Failed to create user document: \(error.localizedDescription)")
            } else {
                print("User document created successfully.")
            }
        }
    }
    func fetchUserData() {
        guard let userId = users?.userUID else {
            print("User ID is not available.")
            return
        }
        
        let db = Firestore.firestore()
        let documentRef = db.collection("users").document(userId)
        
        documentRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("Document does not exist or data is missing.")
                return
            }
            
            // Print raw data for debugging
            print("Fetched raw data: \(data)")
            
            // Decode the user data
            do {
                let user = try document.data(as: User.self)
                self?.users = user
                self?.updateQuizLists()
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
            }
        }
    }
   
    
    
//    func setDueDateForFailedQuiz(user: User, quizID: String, newDueDate: Date) async {
//        do {
//            // Fetch the user's data
//            var updatedUser = try await UserManager.shared.fetchUser(by: user.userUID)
//            
//            // Find the quiz score entry
//            if let index = updatedUser.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
//                let highestScore = updatedUser.quizScores?[index].scores.max() ?? 0
//                
//                // Check if the score is below the passing threshold
//                if highestScore < 80 {
//                    // Set the new due date
//                    updatedUser.quizScores?[index].dueDates?[quizID] = newDueDate
//                    
//                    // Save the updated user data back to Firestore
//                    let db = Firestore.firestore()
//                    let userRef = db.collection("Users").document(user.userUID)
//                    try userRef.setData(from: updatedUser, merge: true) { error in
//                        if let error = error {
//                            print("Failed to update due date: \(error.localizedDescription)")
//                        } else {
//                            print("Due date updated successfully.")
//                        }
//                    }
//                }
//            }
//        } catch {
//            print("Error: \(error.localizedDescription)")
//        }
//    }
    @MainActor
    func setDueDateForFailedQuiz(user: User, quizID: String, newDueDate: Date, newRenewalDate: Date) async {
        guard var updatedUser = self.user else { return }
        
        if var quizScore = updatedUser.quizScores?.first(where: { $0.quizID == quizID }) {
            quizScore.dueDates = [quizID: newDueDate]
            quizScore.nextRenewalDates = [quizID: newRenewalDate]
            if let index = updatedUser.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
                updatedUser.quizScores?[index] = quizScore
            }
        } else {
            let newQuizScore = UserQuizScore(quizID: quizID, scores: [], completionDates: [], dueDates: [quizID: newDueDate], nextRenewalDates: [quizID: newRenewalDate])
            updatedUser.quizScores?.append(newQuizScore)
        }
        
        do {
            try await Firestore.firestore().collection("Users").document(updatedUser.userUID).updateData([
                "quizScores": updatedUser.quizScores?.map { $0.toDictionary() } ?? []
            ])
            await MainActor.run {
                self.user = updatedUser
            }
        } catch {
            print("Error updating due date and renewal date: \(error.localizedDescription)")
        }
    }
    @MainActor

//    func fetchCompletedQuizzesAndScoresofUser(user: User) async {
//        do {
//            // Fetch all quizzes
//            let allQuizzes = try await QuizManager.shared.getAllQuiz()
//            
//            // Filter quizzes based on direct assignment, user's account type, assigned categories, and quizScores
//            let assignedQuizzes = allQuizzes.filter { quiz in
//                // Check if the quiz is directly assigned to the user
//                let isDirectlyAssigned = user.assignedCategoryIDs?.contains(quiz.id) == true
//                
//                // Check if the quiz is assigned to the user's account type
//                let isAccountTypeAssigned = quiz.accountTypes.contains(user.accountType)
//                
//                // Check if the quiz category matches any of the user's assigned category IDs
//                let isCategoryAssigned = user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
//                
//                // Check if the quiz is in the user's quizScores
//                let isInQuizScores = user.quizScores?.contains(where: { $0.quizID == quiz.id }) == true
//                
//                // The quiz is considered assigned if any of these conditions are true
//                return isDirectlyAssigned || isAccountTypeAssigned || isCategoryAssigned || isInQuizScores
//            }
//            
//            var tempQuizzesWithScores: [QuizWithScore] = []
//            var tempUncompletedQuizzes: [Quiz] = []
//            
//            for quiz in assignedQuizzes {
//                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
//                    let highestScore = quizScore.scores.max() ?? 0
//                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
//                    
//                    if highestScore >= 80.0 {
//                        tempQuizzesWithScores.append(quizWithScore)
//                    } else {
//                        tempUncompletedQuizzes.append(quiz)
//                    }
//                } else {
//                    tempUncompletedQuizzes.append(quiz)
//                }
//            }
//            
//            self.quizzesWithScores = tempQuizzesWithScores
//            self.uncompletedQuizzes = tempUncompletedQuizzes
//            
//            print("User: \(user.username)")
//            print("User ID: \(user.id ?? "No ID")")
//            print("Account Type: \(user.accountType)")
//            print("Assigned Categories/Quizzes: \(user.assignedCategoryIDs ?? [])")
//            print("Quiz Scores Count: \(user.quizScores?.count ?? 0)")
//            print("Total Quizzes: \(allQuizzes.count)")
//            print("Assigned Quizzes: \(assignedQuizzes.count)")
//            print("Completed Quizzes: \(quizzesWithScores.count)")
//            print("Uncompleted Quizzes: \(uncompletedQuizzes.count)")
//            
//            // Print more details for debugging
//            for quiz in assignedQuizzes {
//                let isDirectlyAssigned = user.assignedCategoryIDs?.contains(quiz.id) == true
//                let isAccountTypeAssigned = quiz.accountTypes.contains(user.accountType)
//                let isCategoryAssigned = user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
//                let isInQuizScores = user.quizScores?.contains(where: { $0.quizID == quiz.id }) == true
//                
//                if let score = user.quizScores?.first(where: { $0.quizID == quiz.id })?.scores.max() {
//                    print("Quiz: \(quiz.info.title), Category: \(quiz.quizCategory), ID: \(quiz.id), Highest Score: \(score)")
//                } else {
//                    print("Quiz: \(quiz.info.title), Category: \(quiz.quizCategory), ID: \(quiz.id), Not attempted")
//                }
//                print("  Directly Assigned: \(isDirectlyAssigned), Account Type Assigned: \(isAccountTypeAssigned), Category Assigned: \(isCategoryAssigned), In Quiz Scores: \(isInQuizScores)")
//            }
//            
//        } catch {
//            print("Error fetching quizzes: \(error.localizedDescription)")
//        }
//    }
//    
//    
    func fetchCompletedQuizzesAndScoresofUser(user: User) async {
            do {
                // Fetch all quizzes
                let allQuizzes = try await QuizManager.shared.getAllQuiz()
                
                // Filter quizzes based on direct assignment, user's account type, assigned categories, and quizScores
                let assignedQuizzes = allQuizzes.filter { quiz in
                    // Check if the quiz is directly assigned to the user
                    let isDirectlyAssigned = user.assignedCategoryIDs?.contains(quiz.id) == true
                    
                    // Check if the quiz is assigned to the user's account type
                    let isAccountTypeAssigned = quiz.accountTypes.contains(user.accountType)
                    
                    // Check if the quiz category matches any of the user's assigned category IDs
                    let isCategoryAssigned = user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
                    
                    // Check if the quiz is in the user's quizScores
                    let isInQuizScores = user.quizScores?.contains(where: { $0.quizID == quiz.id }) == true
                    
                    // The quiz is considered assigned if any of these conditions are true
                    return isDirectlyAssigned || isAccountTypeAssigned || isCategoryAssigned || isInQuizScores
                }
                
                var tempQuizzesWithScores: [QuizWithScore] = []
                var tempUncompletedQuizzes: [Quiz] = []
                
                for quiz in assignedQuizzes {
                    if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
                        let highestScore = quizScore.scores.max() ?? 0
                        let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                        
                        if highestScore >= 80.0 {
                            tempQuizzesWithScores.append(quizWithScore)
                        } else {
                            tempUncompletedQuizzes.append(quiz)
                        }
                    } else {
                        tempUncompletedQuizzes.append(quiz)
                    }
                }
                
                // Update the @Published properties
                self.user = user
                self.quizzesWithScores = tempQuizzesWithScores
                self.uncompletedQuizzes = tempUncompletedQuizzes
                
                // Print debug information
                print("User: \(user.username)")
                print("User ID: \(user.id ?? "No ID")")
                print("Account Type: \(user.accountType)")
                print("Assigned Categories/Quizzes: \(user.assignedCategoryIDs ?? [])")
                print("Quiz Scores Count: \(user.quizScores?.count ?? 0)")
                print("Total Quizzes: \(allQuizzes.count)")
                print("Assigned Quizzes: \(assignedQuizzes.count)")
                print("Completed Quizzes: \(quizzesWithScores.count)")
                print("Uncompleted Quizzes: \(uncompletedQuizzes.count)")
                
                // Print more details for debugging
                for quiz in assignedQuizzes {
                    let isDirectlyAssigned = user.assignedCategoryIDs?.contains(quiz.id) == true
                    let isAccountTypeAssigned = quiz.accountTypes.contains(user.accountType)
                    let isCategoryAssigned = user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
                    let isInQuizScores = user.quizScores?.contains(where: { $0.quizID == quiz.id }) == true
                    
                    if let score = user.quizScores?.first(where: { $0.quizID == quiz.id })?.scores.max() {
                        print("Quiz: \(quiz.info.title), Category: \(quiz.quizCategory), ID: \(quiz.id), Highest Score: \(score)")
                    } else {
                        print("Quiz: \(quiz.info.title), Category: \(quiz.quizCategory), ID: \(quiz.id), Not attempted")
                    }
                    print("  Directly Assigned: \(isDirectlyAssigned), Account Type Assigned: \(isAccountTypeAssigned), Category Assigned: \(isCategoryAssigned), In Quiz Scores: \(isInQuizScores)")
                }
                
            } catch {
                print("Error fetching quizzes: \(error.localizedDescription)")
            }
        }
    @MainActor
     func fetchAssignedQuizzesForUser(_ user: User) async {
         do {
             let allQuizzes = try await QuizManager.shared.getAllQuiz()
             let assignedQuizzes = allQuizzes.filter { quiz in
                 user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
             }

             self.quizzesWithScores = assignedQuizzes.compactMap { quiz in
                 if let score = user.quizScores?.first(where: { $0.quizID == quiz.id })?.scores.max() {
                     return QuizWithScore(quiz: quiz, score: score)
                 }
                 return nil
             }

             self.uncompletedQuizzes = assignedQuizzes.filter { quiz in
                 !self.quizzesWithScores.contains(where: { $0.quiz.id == quiz.id })
             }

             print("Assigned Quizzes: \(assignedQuizzes.count)")
             print("Completed Quizzes: \(self.quizzesWithScores.count)")
             print("Uncompleted Quizzes: \(self.uncompletedQuizzes.count)")
         } catch {
             print("Error fetching assigned quizzes: \(error.localizedDescription)")
         }
     }
    @MainActor
    func setDueDateForFailedQuiz(user: User, quizID: String, newDueDate: Date) async {
        do {
            // Fetch the user's data
            var updatedUser = try await UserManager.shared.fetchUser(by: user.userUID)
            
            // Find the quiz score entry
            if let index = updatedUser.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
                let highestScore = updatedUser.quizScores?[index].scores.max() ?? 0
                
                // Check if the score is below the passing threshold
                if highestScore < 80 {
                    // Set the new due date
                    updatedUser.quizScores?[index].dueDates?[quizID] = newDueDate
                    
                    // Save the updated user data back to Firestore
                    let db = Firestore.firestore()
                    let userRef = db.collection("Users").document(user.userUID)
                    try userRef.setData(from: updatedUser, merge: true) { error in
                        if let error = error {
                            print("Failed to update due date: \(error.localizedDescription)")
                        } else {
                            print("Due date updated successfully.")
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
   
    
    @Published var currentUser: User?
//    @MainActor
//        func fetchCurrentUser() async {
//            guard !isLoading else { return }
//            isLoading = true
//            defer { isLoading = false }
//
//            guard let userUID = Auth.auth().currentUser?.uid else {
//                print("No user UID found")
//                return
//            }
//
//            do {
//                let user = try await UserManager.shared.fetchUser(by: userUID)
//                self.currentUser = user
//                print("Current user fetched: \(user.username)")
//            } catch {
//                print("Error fetching current user: \(error.localizedDescription)")
//            }
//        }

       // @MainActor
//    func fetchUserQuizzes() async {
//        guard !isLoading else { return }
//        isLoading = true
//        defer { isLoading = false }
//
//        // Fetch current user if not already fetched
//        if currentUser == nil {
//            await fetchCurrentUser()
//        }
//
//        guard let user = currentUser else {
//            print("Current user not available")
//            return
//        }
//
//        do {
//            let allQuizzes = try await QuizManager.shared.getAllQuiz()
//
//            // Filter quizzes based on user's assigned categories or admin status
//            let relevantQuizzes = user.accountType == "Admin"
//                ? allQuizzes
//                : allQuizzes.filter { quiz in
//                    user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
//                }
//
//            var tempQuizzesWithScores: [QuizWithScore] = []
//            var tempUncompletedQuizzes: [Quiz] = []
//
//            for quiz in relevantQuizzes {
//                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
//                    let highestScore = quizScore.scores.max() ?? 0
//                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
//                    if highestScore >= 80.0 {
//                        tempQuizzesWithScores.append(quizWithScore)
//                    } else {
//                        tempUncompletedQuizzes.append(quiz)
//                    }
//                } else {
//                    tempUncompletedQuizzes.append(quiz)
//                }
//            }
//
//            self.quizzesWithScores = tempQuizzesWithScores
//            self.uncompletedQuizzes = tempUncompletedQuizzes
//
//            print("User: \(user.username)")
//            print("Account Type: \(user.accountType)")
//            print("Assigned Category IDs: \(user.assignedCategoryIDs ?? [])")
//            print("Relevant Quizzes: \(relevantQuizzes.count)")
//            print("Completed Quizzes: \(quizzesWithScores.count)")
//            print("Uncompleted Quizzes: \(uncompletedQuizzes.count)")
//
//            // Print details of completed quizzes
//            for quizWithScore in quizzesWithScores {
//                print("Completed Quiz: \(quizWithScore.quiz.id), Category: \(quizWithScore.quiz.quizCategoryID), Score: \(quizWithScore.score)")
//            }
//
//            // Print details of uncompleted quizzes
//            for quiz in uncompletedQuizzes {
//                print("Uncompleted Quiz: \(quiz.id), Category: \(quiz.quizCategoryID)")
//            }
//        } catch {
//            print("Error fetching quizzes: \(error.localizedDescription)")
//        }
//    }

        @MainActor
    func updateUserQuizDueDate(quizID: String, newDate: Date) async {
        guard let user = currentUser else {
            print("Current user not found.")
            return
        }

        do {
            var updatedUser = user
            if updatedUser.quizScores == nil {
                updatedUser.quizScores = []
            }

            if let index = updatedUser.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
                if updatedUser.quizScores?[index].dueDates == nil {
                    updatedUser.quizScores?[index].dueDates = [:]
                }
                updatedUser.quizScores?[index].dueDates?[quizID] = newDate
            } else {
                let newScore = UserQuizScore(quizID: quizID, scores: [], completionDates: [], dueDates: [quizID: newDate])
                updatedUser.quizScores?.append(newScore)
            }

            try await UserManager.shared.uploadUser(user: updatedUser)
            self.currentUser = updatedUser
            print("Due date updated successfully for quizID: \(quizID) with new date: \(newDate).")
            await fetchUserQuizzes() // Refresh the quiz data
        } catch {
            print("Failed to update due date: \(error.localizedDescription)")
        }
    }
//    func fetchUserQuizzes() async {
//            guard !isLoading else { return }
//            isLoading = true
//            defer { isLoading = false }
//
//            guard let user = currentUser else {
//                print("User not available")
//                return
//            }
//
//            do {
//                await fetchCompletedQuizzesAndScoresofUser(user: user)
//            } catch {
//                print("Error fetching quizzes: \(error.localizedDescription)")
//            }
//        }
    @Published var user: User?
    func loadUser(_ user: User?) {
           self.user = user
       }

       @MainActor
       func fetchCurrentUser() async {
           guard !isLoading else { return }
           isLoading = true
           defer { isLoading = false }

           guard let userUID = Auth.auth().currentUser?.uid else {
               print("No user UID found")
               return
           }

           do {
               let user = try await UserManager.shared.fetchUser(by: userUID)
               self.user = user
               print("Current user fetched: \(user.username)")
           } catch {
               print("Error fetching current user: \(error.localizedDescription)")
           }
       }

       @MainActor
       func fetchUserQuizzes() async {
           guard !isLoading else { return }
           isLoading = true
           defer { isLoading = false }

           guard let user = user else {
               print("User not available")
               return
           }

           await fetchCompletedQuizzesAndScoresofUser(user: user)
       }
}
final class HusbandryUserProfileViewModel: ObservableObject {
    
    @Published var completedQuizzes: [Quiz] = []
    @Published var quizzesWithScores: [QuizWithScore] = []
    @Published var uncompletedQuizzes: [Quiz] = [] // New array to hold uncompleted quizzes
    @Published var users: User?
    @Published var userSelected: User?
    @Published var userss: [User] = []
    @Published private(set) var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    func fetchCompletedQuizzes() async {
        guard let userUID = Auth.auth().currentUser?.uid else {return} // make sure we have a user ID
        
        
        do {
            let user = try await UserManager.shared.fetchUser(by: userUID)
            let completedQuizIds = user.quizScores?.map { $0.quizID } ?? []
            print(user.username)
            let quizzes = try await QuizManager.shared.fetchQuizzesByIds(completedQuizIds)
            self.completedQuizzes = quizzes
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    /// updating
    @MainActor
    func fetchHighScoreQuizzes(minScore: CGFloat = 80.0) async {
        guard let userUID = Auth.auth().currentUser?.uid else { return } // Ensure we have a user ID
        
        do {
            let user = try await UserManager.shared.fetchUser(by: userUID)
            
            // Filter quizScores to only include those with scores above the threshold
            let highScoreQuizIDs = user.quizScores?
                .filter { $0.scores.max() ?? 0 >= minScore }
                .map { $0.quizID } ?? []
            
            print("User: \(user.username), Quizzes with scores above \(minScore)%: \(highScoreQuizIDs)")
            
            // Fetch the quizzes with IDs that match the high scores
            let highScoreQuizzes = try await QuizManager.shared.fetchQuizzesByIds(highScoreQuizIDs)
            
            self.completedQuizzes = highScoreQuizzes
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    @MainActor
    func fetchCompletedQuizzesAndScores() async {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("No user UID found")
            return
        }
        do {
            let user = try await UserManager.shared.fetchUser(by: userUID)
            print("User fetched: \(user.username)")
            users = user
            
            var tempQuizzesWithScores: [QuizWithScore] = []
            var completedQuizIds: Set<String> = []
            
            let allQuizzes = try await QuizManager.shared.getAllQuiz()
            print("Total quizzes fetched: \(allQuizzes.count)")
            
            for quizScore in user.quizScores ?? [] {
                let highestScore = quizScore.scores.max() ?? 0
                print("Processing quiz ID: \(quizScore.quizID), highest score: \(highestScore)")
                if let quiz = allQuizzes.first(where: { $0.id == quizScore.quizID }) {
                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                    tempQuizzesWithScores.append(quizWithScore)
                    if highestScore >= 80.0 {
                        completedQuizIds.insert(quiz.id)
                    }
                }
            }
            self.quizzesWithScores = tempQuizzesWithScores
            print("Quizzes with scores: \(quizzesWithScores.count)")
            
            print("Completed quiz IDs: \(completedQuizIds)")
            self.uncompletedQuizzes = allQuizzes.filter { quiz in
                if completedQuizIds.contains(quiz.id) {
                    return false // Quiz is completed with score >= 80
                }
                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
                    if quizScore.scores.isEmpty {
                        return true // Quiz is uncompleted if scores array is empty
                    }
                    if let highestScore = quizScore.scores.max() {
                        return highestScore < 80.0 // Quiz is uncompleted if highest score is less than 80%
                    }
                }
                return true // Quiz is uncompleted if there's no score entry
            }
            print("Uncompleted quizzes: \(uncompletedQuizzes.count)")
            
            // Print details of uncompleted quizzes
            for quiz in uncompletedQuizzes {
                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
                    print("Uncompleted Quiz: \(quiz.id), Highest Score: \(quizScore.scores.max() ?? 0)")
                } else {
                    print("Uncompleted Quiz: \(quiz.id), Not Attempted")
                }
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
//  @MainActor
//    func fetchCompletedQuizzesAndScores() async {
//        guard let userUID = Auth.auth().currentUser?.uid else {
//            print("No user UID found")
//            return
//        }
//        do {
//            let user = try await UserManager.shared.fetchUser(by: userUID)
//            print("User fetched: \(user.username)")
//            users = user
//
//            var tempQuizzesWithScores: [QuizWithScore] = []
//            for quizScore in user.quizScores ?? [] {
//                let highestScore = quizScore.scores.max() ?? 0
//                print("Processing quiz ID: \(quizScore.quizID), highest score: \(highestScore)")
//                let quizzes = try await QuizManager.shared.fetchQuizzesByIds([quizScore.quizID])
//                for quiz in quizzes {
//                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
//                    tempQuizzesWithScores.append(quizWithScore)
//                }
//            }
//            self.quizzesWithScores = tempQuizzesWithScores
//            print("Quizzes with scores: \(quizzesWithScores.count)")
//
//            // Fetch all quizzes to determine uncompleted ones
//            let allQuizzes = try await QuizManager.shared.getAllQuiz()
//            print("Total quizzes fetched: \(allQuizzes.count)")
//            let completedQuizIds = Set(user.quizScores?.map { $0.quizID } ?? [])
//            print("Completed quiz IDs: \(completedQuizIds)")
//            self.uncompletedQuizzes = allQuizzes.filter { !completedQuizIds.contains($0.id) }
//            print("Uncompleted quizzes: \(uncompletedQuizzes.count)")
//
//        } catch {
//            print("Error: \(error.localizedDescription)")
//        }
//    }
    
    @MainActor
    func fecthAllUser() async throws {
        userss = try await UserManager.shared.getAllUser().sorted{$0.username < $1.username}
        print(userss.first)
    }
    @MainActor
    func fecthAllUserReturn() async throws -> [User] {
        try await UserManager.shared.getAllUser().sorted{$0.username < $1.username}
        
    }
    @MainActor
    func fetchCompletedQuizzesAndScoresForAllUsers() async {
        do {
            let allUsers = try await UserManager.shared.getAllUser().sorted{$0.username < $1.username} // Ensure this method exists and fetches all users
            
            // users = allUsers
            for user in userss {
                print("User: \(user.username) with \(user.quizScores?.count ?? 0) scores")
                
                var tempQuizzesWithScores: [QuizWithScore] = []
                for quizScore in user.quizScores ?? [] {
                    let highestScore = quizScore.scores.max() ?? 0
                    print("Processing quiz ID: \(quizScore.quizID), highest score: \(highestScore)")
                    let quizzes = try await QuizManager.shared.fetchQuizzesByIds([quizScore.quizID])
                    for quiz in quizzes {
                        let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                        tempQuizzesWithScores.append(quizWithScore)
                    }
                }
                self.quizzesWithScores = tempQuizzesWithScores
                
                let allQuizzes = try await QuizManager.shared.getAllQuiz()
                let completedQuizIds = Set(user.quizScores?.map { $0.quizID } ?? [])
                self.uncompletedQuizzes = allQuizzes.filter { !completedQuizIds.contains($0.id) }
                
                print("Completed quiz IDs for user \(user.username): \(completedQuizIds)")
                print("Uncompleted quizzes for user \(user.username): \(uncompletedQuizzes.count)")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchNonCompletedQuizzesAndScores() async {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        do {
            let user = try await UserManager.shared.fetchUser(by: userUID)
            users = user
            
            var tempQuizzesWithScores: [QuizWithScore] = []
            for quizScore in user.quizScores ?? [] {
                let highestScore = quizScore.scores.max() ?? 0
                let quizzes = try await QuizManager.shared.fetchQuizzesByIds([quizScore.quizID])
                for quiz in quizzes {
                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                    tempQuizzesWithScores.append(quizWithScore)
                }
            }
            self.quizzesWithScores = tempQuizzesWithScores
            
            // Fetch all quizzes to determine uncompleted ones
            let allQuizzes = try await QuizManager.shared.getAllQuiz()
            let completedQuizIds = Set(user.quizScores?.map { $0.quizID } ?? [])
            self.uncompletedQuizzes = allQuizzes.filter { !completedQuizIds.contains($0.id) }
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
  
    @MainActor
    func fetchCompletedQuizzesAndScoresof(user: User) async {
        do {
            let user = try await UserManager.shared.fetchUser(by: user.userUID)
            users = user
            
            var tempQuizzesWithScores: [QuizWithScore] = []
            for quizScore in user.quizScores ?? [] {
                let highestScore = quizScore.scores.max() ?? 0
                let quizzes = try await QuizManager.shared.fetchQuizzesByIds([quizScore.quizID])
                for quiz in quizzes {
                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                    tempQuizzesWithScores.append(quizWithScore)
                }
            }
            self.quizzesWithScores = tempQuizzesWithScores
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
  
   // @MainActor
//    func fetchCompletedQuizzesAndScoresofUser(user: User) async {
//        do {
//            let user = try await UserManager.shared.fetchUser(by: user.userUID)
//            users = user
//
//            var tempQuizzesWithScores: [QuizWithScore] = []
//            var completedQuizIds: Set<String> = []
//
//            // Filter for quizzes with a score of 80% or higher
//            for quizScore in user.quizScores ?? [] {
//                if let highestScore = quizScore.scores.max(), highestScore >= 80.0 {
//                    let quizzes = try await QuizManager.shared.fetchQuizzesByIds([quizScore.quizID])
//                    for quiz in quizzes {
//                        let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
//                        tempQuizzesWithScores.append(quizWithScore)
//                        completedQuizIds.insert(quiz.id)
//                    }
//                }
//            }
//            self.quizzesWithScores = tempQuizzesWithScores
//
//            // Fetch all quizzes to determine uncompleted ones
//            let allQuizzes = try await QuizManager.shared.getAllQuiz()
//            self.uncompletedQuizzes = allQuizzes.filter { !completedQuizIds.contains($0.id) }
//
//        } catch {
//            print("Error: \(error.localizedDescription)")
//        }
//    }
    // update duedate
    
//    func fetchCompletedQuizzesAndScoresofUser(user: User) async {
//
//        guard !isLoading else { return }
//            isLoading = true
//            defer { isLoading = false }
//
//        do {
//            let user = try await UserManager.shared.fetchUser(by: user.userUID)
//            users = user
//
//            var tempQuizzesWithScores: [QuizWithScore] = []
//            var completedQuizIds: Set<String> = []
//
//            // Fetch all quizzes
//            let allQuizzes = try await QuizManager.shared.getAllQuiz()
//
//            // Process user's quiz scores
//            for quizScore in user.quizScores ?? [] {
//                if let highestScore = quizScore.scores.max() {
//                    if let quiz = allQuizzes.first(where: { $0.id == quizScore.quizID }) {
//                        let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
//                        tempQuizzesWithScores.append(quizWithScore)
//                        if highestScore >= 80.0 {
//                            completedQuizIds.insert(quiz.id)
//                        }
//                    }
//                }
//            }
//            self.quizzesWithScores = tempQuizzesWithScores
//
//            // Determine uncompleted quizzes
//            self.uncompletedQuizzes = allQuizzes.filter { quiz in
//                if completedQuizIds.contains(quiz.id) {
//                    return false // Quiz is completed with score >= 80
//                }
//                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
//                    if quizScore.scores.isEmpty {
//                        return true // Quiz is uncompleted if scores array is empty
//                    }
//                    if let highestScore = quizScore.scores.max() {
//                        return highestScore < 80.0 // Quiz is uncompleted if highest score is less than 80%
//                    }
//                }
//                return true // Quiz is uncompleted if there's no score entry
//            }
//
//            print("Completed Quizzes: \(completedQuizIds.count)")
//            print("Uncompleted Quizzes: \(self.uncompletedQuizzes.count)")
//
//        } catch {
//            print("Error: \(error.localizedDescription)")
//        }
//    }
    @MainActor
    func updateUserQuizDueDate(for user: User?, quizID: String, newDate: Date) {
        guard var user = user else {
            print("User not found.")
            return
        }
        

        // Ensure `quizScores` exists
        if user.quizScores == nil {
            user.quizScores = []
        }

        // Find or create the quiz score entry
        if let index = user.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
            // Ensure `dueDates` exists
            if user.quizScores?[index].dueDates == nil {
                user.quizScores?[index].dueDates = [:]
            }

            // Update the due date for the specific quiz
            user.quizScores?[index].dueDates?[quizID] = newDate
        } else {
            // If quizScore doesn't exist, create a new one with the due date
            let newScore = UserQuizScore(quizID: quizID, scores: [], completionDates: [], dueDates: [quizID: newDate])
            user.quizScores?.append(newScore)
        }

        // Update Firebase with the new user data
        do {
            let db = Firestore.firestore()
            let userRef = db.collection("Users").document(user.userUID)
            try userRef.setData(from: user, merge: true) { [weak self] error in
                if let error = error {
                    print("Failed to update due date: \(error.localizedDescription)")
                } else {
                    print("Due date updated successfully for quizID: \(quizID) with new date: \(newDate).")
                    self?.fetchUserData(userUID: user.userUID, quizID: quizID) // Fetch the updated user data to verify the update
                }
            }
        } catch {
            print("Failed to encode user: \(error.localizedDescription)")
        }
    }


    // Fetch user data to verify if the due date was updated
    @MainActor
    func fetchUserData(userUID: String, quizID: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userUID)
        
        userRef.getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let data = document.data()
                print("Updated user data fetched: \(String(describing: data))")
                if let quizScores = data?["quizScores"] as? [[String: Any]],
                   let quizScore = quizScores.first(where: { $0["quizID"] as? String == quizID }),
                   let dueDates = quizScore["dueDates"] as? [String: Timestamp],
                   let updatedDueDate = dueDates[quizID] {
                    print("Verified due date in Firestore for quizID \(quizID): \(updatedDueDate.dateValue())")
                } else {
                    print("Due date not found in updated user data for quizID: \(quizID).")
                }
            } else if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            }
        }
    }

    // Update quiz lists based on user data
    func updateQuizLists() {
        guard let user = users else {
            print("User data is not available.")
            return
        }
        
        // Extract completed quiz IDs from user.quizScores
        let completedQuizIds = user.quizScores?
            .flatMap { quizScore in quizScore.completionDates.map { _ in quizScore.quizID } } ?? []
        
        // Update completedQuizzes by filtering quizzesWithScores and extracting the quiz part
        completedQuizzes = quizzesWithScores
            .filter { completedQuizIds.contains($0.quiz.id) }
            .map { $0.quiz }
        
        // Update uncompletedQuizzes by filtering quizzesWithScores and extracting the quiz part
        uncompletedQuizzes = quizzesWithScores
            .filter { !completedQuizIds.contains($0.quiz.id) }
            .map { $0.quiz }
    }
    
    @MainActor
    func fetchUserQuizScores(userId: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("users").document(userId)
        
        documentRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let quizScores = data?["quizScores"] as? [[String: Any]] ?? []
                print("Fetched quizScores for user \(userId): \(quizScores)")
            } else if let error = error {
                print("Error fetching quiz scores: \(error.localizedDescription)")
            } else {
                print("No document found for user \(userId).")
            }
        }
    }
    func createUserDocument(userId: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("users").document(userId)
        
        let newQuizScore: [String: Any] = [
            "quizID": "",
            "scores": [],
            "completionDates": [],
            "dueDates": [:]
        ]
        let userData: [String: Any] = [
            "quizScores": [newQuizScore]
        ]
        
        documentRef.setData(userData) { error in
            if let error = error {
                print("Failed to create user document: \(error.localizedDescription)")
            } else {
                print("User document created successfully.")
            }
        }
    }
    func fetchUserData() {
        guard let userId = users?.userUID else {
            print("User ID is not available.")
            return
        }
        
        let db = Firestore.firestore()
        let documentRef = db.collection("users").document(userId)
        
        documentRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("Document does not exist or data is missing.")
                return
            }
            
            // Print raw data for debugging
            print("Fetched raw data: \(data)")
            
            // Decode the user data
            do {
                let user = try document.data(as: User.self)
                self?.users = user
                self?.updateQuizLists()
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
            }
        }
    }
   
    
    
    @MainActor
    func setDueDateForFailedQuiz(user: User, quizID: String, newDueDate: Date) async {
        do {
            // Fetch the user's data
            var updatedUser = try await UserManager.shared.fetchUser(by: user.userUID)
            
            // Find the quiz score entry
            if let index = updatedUser.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
                let highestScore = updatedUser.quizScores?[index].scores.max() ?? 0
                
                // Check if the score is below the passing threshold
                if highestScore < 80 {
                    // Set the new due date
                    updatedUser.quizScores?[index].dueDates?[quizID] = newDueDate
                    
                    // Save the updated user data back to Firestore
                    let db = Firestore.firestore()
                    let userRef = db.collection("Users").document(user.userUID)
                    try userRef.setData(from: updatedUser, merge: true) { error in
                        if let error = error {
                            print("Failed to update due date: \(error.localizedDescription)")
                        } else {
                            print("Due date updated successfully.")
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
   

//    @MainActor
//
//    //@MainActor
//    func fetchCompletedQuizzesAndScoresofUser(user: User) async {
//        do {
//            // Fetch all quizzes
//            let allQuizzes = try await QuizManager.shared.getAllQuiz()
//
//            // Filter quizzes based on user's assigned categories and account type
//            let assignedQuizzes = allQuizzes.filter { quiz in
//                (user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true || quiz.accountTypes.contains(user.accountType))
//            }
//
//            var tempQuizzesWithScores: [QuizWithScore] = []
//            var tempUncompletedQuizzes: [Quiz] = []
//
//            for quiz in assignedQuizzes {
//                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
//                    let highestScore = quizScore.scores.max() ?? 0
//                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
//
//                    if highestScore >= 80.0 {
//                        tempQuizzesWithScores.append(quizWithScore)
//                    } else {
//                        tempUncompletedQuizzes.append(quiz)
//                    }
//                } else {
//                    tempUncompletedQuizzes.append(quiz)
//                }
//            }
//
//            self.quizzesWithScores = tempQuizzesWithScores
//            self.uncompletedQuizzes = tempUncompletedQuizzes
//
//            print("User: \(user.username)")
//            print("Account Type: \(user.accountType)")
//            print("Assigned Categories: \(user.assignedCategoryIDs ?? [])")
//            print("Total Quizzes: \(allQuizzes.count)")
//            print("Assigned Quizzes: \(assignedQuizzes.count)")
//            print("Completed Quizzes: \(quizzesWithScores.count)")
//            print("Uncompleted Quizzes: \(uncompletedQuizzes.count)")
//
//            // Print more details for debugging
//            for quiz in assignedQuizzes {
//                if let score = user.quizScores?.first(where: { $0.quizID == quiz.id })?.scores.max() {
//                    print("Quiz: \(quiz.info.title), Category: \(quiz.quizCategory), ID: \(quiz.quizCategoryID), Highest Score: \(score)")
//                } else {
//                    print("Quiz: \(quiz.info.title), Category: \(quiz.quizCategory), ID: \(quiz.quizCategoryID), Not attempted")
//                }
//            }
//
//        } catch {
//            print("Error fetching quizzes: \(error.localizedDescription)")
//        }
//    }
//
   
    @MainActor
  
//    @MainActor
 
   // @MainActor
    func fetchCompletedQuizzesAndScoresofUser(user: User) async {
        do {
            // Fetch all quizzes
            let allQuizzes = try await QuizManager.shared.getAllQuiz()
            
            // Filter quizzes based on direct assignment, user's account type, assigned categories, and quizScores
//            let assignedQuizzes = allQuizzes.filter { quiz in
//                // Check if the quiz is directly assigned to the user
//                let isDirectlyAssigned = user.assignedCategoryIDs?.contains(quiz.id) == true
//                
//                // Check if the quiz is assigned to the user's account type
//                let isAccountTypeAssigned = quiz.accountTypes.contains(user.accountType)
//                
//                // Check if the quiz category matches any of the user's assigned category IDs
//                let isCategoryAssigned = user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
//                
//                // Check if the quiz is in the user's quizScores
//                let isInQuizScores = user.quizScores?.contains(where: { $0.quizID == quiz.id }) == true
//                
//                // The quiz is considered assigned if any of these conditions are true
//                return isDirectlyAssigned || isAccountTypeAssigned || isCategoryAssigned || isInQuizScores
//            }
            let assignedQuizzes = allQuizzes.filter { quiz in
                let isDirectlyAssigned = user.assignedCategoryIDs?.contains(quiz.id) == true
                let isAccountTypeAssigned = quiz.accountTypes.contains(user.accountType)
                let isCategoryAssigned = user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
                let isInQuizScores = user.quizScores?.contains(where: { $0.quizID == quiz.id }) == true
                
                // Prioritize direct assignments
                if isDirectlyAssigned {
                    return true
                } else if isInQuizScores {
                    // Keep quizzes that have been started or completed
                    return true
                } else {
                    // For account type or category assignments, check if there's a due date
                    return (isAccountTypeAssigned || isCategoryAssigned) && user.quizScores?.contains(where: { $0.quizID == quiz.id && $0.dueDates?[quiz.id] != nil }) == true
                }
            }
            var tempQuizzesWithScores: [QuizWithScore] = []
            var tempUncompletedQuizzes: [Quiz] = []
            
            for quiz in assignedQuizzes {
                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
                    let highestScore = quizScore.scores.max() ?? 0
                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
                    
                    if highestScore >= 80.0 {
                        tempQuizzesWithScores.append(quizWithScore)
                    } else {
                        tempUncompletedQuizzes.append(quiz)
                    }
                } else {
                    tempUncompletedQuizzes.append(quiz)
                }
            }
            
            self.quizzesWithScores = tempQuizzesWithScores
            self.uncompletedQuizzes = tempUncompletedQuizzes
            
            print("User: \(user.username)")
            print("User ID: \(user.id ?? "No ID")")
            print("Account Type: \(user.accountType)")
            print("Assigned Categories/Quizzes: \(user.assignedCategoryIDs ?? [])")
            print("Quiz Scores Count: \(user.quizScores?.count ?? 0)")
            print("Total Quizzes: \(allQuizzes.count)")
            print("Assigned Quizzes: \(assignedQuizzes.count)")
            print("Completed Quizzes: \(quizzesWithScores.count)")
            print("Uncompleted Quizzes: \(uncompletedQuizzes.count)")
            
            // Print more details for debugging
            for quiz in assignedQuizzes {
                let isDirectlyAssigned = user.assignedCategoryIDs?.contains(quiz.id) == true
                let isAccountTypeAssigned = quiz.accountTypes.contains(user.accountType)
                let isCategoryAssigned = user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
                let isInQuizScores = user.quizScores?.contains(where: { $0.quizID == quiz.id }) == true
                
                if let score = user.quizScores?.first(where: { $0.quizID == quiz.id })?.scores.max() {
                    print("Quiz: \(quiz.info.title), Category: \(quiz.quizCategory), ID: \(quiz.id), Highest Score: \(score)")
                } else {
                    print("Quiz: \(quiz.info.title), Category: \(quiz.quizCategory), ID: \(quiz.id), Not attempted")
                }
                print("  Directly Assigned: \(isDirectlyAssigned), Account Type Assigned: \(isAccountTypeAssigned), Category Assigned: \(isCategoryAssigned), In Quiz Scores: \(isInQuizScores)")
            }
            
        } catch {
            print("Error fetching quizzes: \(error.localizedDescription)")
        }
    }
    @MainActor
     func fetchAssignedQuizzesForUser(_ user: User) async {
         do {
             let allQuizzes = try await QuizManager.shared.getAllQuiz()
             let assignedQuizzes = allQuizzes.filter { quiz in
                 user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
             }

             self.quizzesWithScores = assignedQuizzes.compactMap { quiz in
                 if let score = user.quizScores?.first(where: { $0.quizID == quiz.id })?.scores.max() {
                     return QuizWithScore(quiz: quiz, score: score)
                 }
                 return nil
             }

             self.uncompletedQuizzes = assignedQuizzes.filter { quiz in
                 !self.quizzesWithScores.contains(where: { $0.quiz.id == quiz.id })
             }

             print("Assigned Quizzes: \(assignedQuizzes.count)")
             print("Completed Quizzes: \(self.quizzesWithScores.count)")
             print("Uncompleted Quizzes: \(self.uncompletedQuizzes.count)")
         } catch {
             print("Error fetching assigned quizzes: \(error.localizedDescription)")
         }
     }
    
    
    @Published var currentUser: User?
//    @MainActor
//        func fetchCurrentUser() async {
//            guard !isLoading else { return }
//            isLoading = true
//            defer { isLoading = false }
//
//            guard let userUID = Auth.auth().currentUser?.uid else {
//                print("No user UID found")
//                return
//            }
//
//            do {
//                let user = try await UserManager.shared.fetchUser(by: userUID)
//                self.currentUser = user
//                print("Current user fetched: \(user.username)")
//            } catch {
//                print("Error fetching current user: \(error.localizedDescription)")
//            }
//        }

       // @MainActor
//    func fetchUserQuizzes() async {
//        guard !isLoading else { return }
//        isLoading = true
//        defer { isLoading = false }
//
//        // Fetch current user if not already fetched
//        if currentUser == nil {
//            await fetchCurrentUser()
//        }
//
//        guard let user = currentUser else {
//            print("Current user not available")
//            return
//        }
//
//        do {
//            let allQuizzes = try await QuizManager.shared.getAllQuiz()
//
//            // Filter quizzes based on user's assigned categories or admin status
//            let relevantQuizzes = user.accountType == "Admin"
//                ? allQuizzes
//                : allQuizzes.filter { quiz in
//                    user.assignedCategoryIDs?.contains(quiz.quizCategoryID) == true
//                }
//
//            var tempQuizzesWithScores: [QuizWithScore] = []
//            var tempUncompletedQuizzes: [Quiz] = []
//
//            for quiz in relevantQuizzes {
//                if let quizScore = user.quizScores?.first(where: { $0.quizID == quiz.id }) {
//                    let highestScore = quizScore.scores.max() ?? 0
//                    let quizWithScore = QuizWithScore(quiz: quiz, score: highestScore)
//                    if highestScore >= 80.0 {
//                        tempQuizzesWithScores.append(quizWithScore)
//                    } else {
//                        tempUncompletedQuizzes.append(quiz)
//                    }
//                } else {
//                    tempUncompletedQuizzes.append(quiz)
//                }
//            }
//
//            self.quizzesWithScores = tempQuizzesWithScores
//            self.uncompletedQuizzes = tempUncompletedQuizzes
//
//            print("User: \(user.username)")
//            print("Account Type: \(user.accountType)")
//            print("Assigned Category IDs: \(user.assignedCategoryIDs ?? [])")
//            print("Relevant Quizzes: \(relevantQuizzes.count)")
//            print("Completed Quizzes: \(quizzesWithScores.count)")
//            print("Uncompleted Quizzes: \(uncompletedQuizzes.count)")
//
//            // Print details of completed quizzes
//            for quizWithScore in quizzesWithScores {
//                print("Completed Quiz: \(quizWithScore.quiz.id), Category: \(quizWithScore.quiz.quizCategoryID), Score: \(quizWithScore.score)")
//            }
//
//            // Print details of uncompleted quizzes
//            for quiz in uncompletedQuizzes {
//                print("Uncompleted Quiz: \(quiz.id), Category: \(quiz.quizCategoryID)")
//            }
//        } catch {
//            print("Error fetching quizzes: \(error.localizedDescription)")
//        }
//    }

        @MainActor
        func updateUserQuizDueDate(quizID: String, newDate: Date) async {
            guard let user = currentUser else {
                print("Current user not found.")
                return
            }

            do {
                var updatedUser = user
                if updatedUser.quizScores == nil {
                    updatedUser.quizScores = []
                }

                if let index = updatedUser.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
                    if updatedUser.quizScores?[index].dueDates == nil {
                        updatedUser.quizScores?[index].dueDates = [:]
                    }
                    updatedUser.quizScores?[index].dueDates?[quizID] = newDate
                } else {
                    let newScore = UserQuizScore(quizID: quizID, scores: [], completionDates: [], dueDates: [quizID: newDate])
                    updatedUser.quizScores?.append(newScore)
                }

                try await UserManager.shared.uploadUser(user: updatedUser)
                self.currentUser = updatedUser
                print("Due date updated successfully for quizID: \(quizID) with new date: \(newDate).")
                await fetchUserQuizzes() // Refresh the quiz data
            } catch {
                print("Failed to update due date: \(error.localizedDescription)")
            }
        }
//    func fetchUserQuizzes() async {
//            guard !isLoading else { return }
//            isLoading = true
//            defer { isLoading = false }
//
//            guard let user = currentUser else {
//                print("User not available")
//                return
//            }
//
//            do {
//                await fetchCompletedQuizzesAndScoresofUser(user: user)
//            } catch {
//                print("Error fetching quizzes: \(error.localizedDescription)")
//            }
//        }
    @Published var user: User?
    func loadUser(_ user: User?) {
           self.user = user
       }

       @MainActor
       func fetchCurrentUser() async {
           guard !isLoading else { return }
           isLoading = true
           defer { isLoading = false }

           guard let userUID = Auth.auth().currentUser?.uid else {
               print("No user UID found")
               return
           }

           do {
               let user = try await UserManager.shared.fetchUser(by: userUID)
               self.user = user
               print("Current user fetched: \(user.username)")
           } catch {
               print("Error fetching current user: \(error.localizedDescription)")
           }
       }

       @MainActor
       func fetchUserQuizzes() async {
           guard !isLoading else { return }
           isLoading = true
           defer { isLoading = false }

           guard let user = user else {
               print("User not available")
               return
           }

           await fetchCompletedQuizzesAndScoresofUser(user: user)
       }
}
