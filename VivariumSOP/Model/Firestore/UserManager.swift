//
//  UserManager.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserManager {
    static let shared = UserManager()
    private let userCollection = Firestore.firestore().collection("Users")
    
    private func userDocuments(id: String) -> DocumentReference {
        userCollection.document(id)
    }

    func uploadUser(user: User) async throws {
        try userDocuments(id: user.id ?? "").setData(from: user)
    }
    
    func getAllUsers() async throws -> [User] {
        let snapshot = try await userCollection.getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: User.self) }
    }
    func getAllUser() async throws -> [User] {
        let snapshot = try await userCollection.getDocuments()
        var room: [User] = []
        
        for doc in snapshot.documents {
            let rooms = try doc.data(as: User.self)
            room.append(rooms)
        }
        return room
    }
    private func getUserQuery() -> Query {
        userCollection
    }
    
    private func getUserList(title: UserPDFProgress) -> Query {
        userCollection
            .whereField(User.CodingKeys.userPDFProgress.rawValue, isEqualTo: title)
    }
    
    func getUserList(title: UserPDFProgress?) async throws -> [User] {
        var query = getUserQuery()
        
        if let title {
            query = getUserList(title: title)
        }
        
        return try await query.getDocumentsWithSnapshot(as: User.self)
    }
    
    @MainActor
    func updateUserQuizScore(userID: String, quizID: String, newScore: CGFloat) async throws {
        let userRef = userDocuments(id: userID)
        let snapshot = try await userRef.getDocument()
        
        do {
            var user = try snapshot.data(as: User.self)
            var updatedScores = user.quizScores ?? []

            if let index = updatedScores.firstIndex(where: { $0.quizID == quizID }) {
                updatedScores[index].scores.append(newScore)
                updatedScores[index].completionDates.append(Date())
            } else {
                updatedScores.append(UserQuizScore(quizID: quizID, scores: [newScore], completionDates: [Date()]))
            }

            user.quizScores = updatedScores
            try await uploadUser(user: user)
        } catch {
            throw NSError(domain: "UserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found or could not be decoded."])
        }
    }

    func getUsersWithCompletedQuizzes(quizId: String? = nil) async throws -> [User] {
        let snapshot = try await userCollection.getDocuments()
        return snapshot.documents.compactMap { document in
            guard let user = try? document.data(as: User.self),
                  let quizScores = user.quizScores,
                  !quizScores.isEmpty else { return nil }
            
            if let quizId = quizId {
                return quizScores.contains(where: { $0.quizID == quizId }) ? user : nil
            } else {
                return user
            }
        }
    }
    
    func fetchUser(by userId: String) async throws -> User {
        let documentReference = userCollection.document(userId)
        let documentSnapshot = try await documentReference.getDocument()

        guard let user = try? documentSnapshot.data(as: User.self) else {
            throw NSError(domain: "UserManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found."])
        }

        return user
    }
    
    func fetchUsers(by userId: String) async throws -> User? {
        let userRef = userDocuments(id: userId)
        let snapshot = try await userRef.getDocument()
        return try? snapshot.data(as: User.self)
    }
    
    func updateUserCategories(userID: String, categories: [String]) async throws {
        let userRef = userDocuments(id: userID)
        try await userRef.updateData([User.CodingKeys.assignedCategoryIDs.rawValue: categories])
    }
    
    func updateUserProfile(userID: String, firstName: String, lastName: String, facilityName: String) async throws {
        let userRef = userDocuments(id: userID)
        try await userRef.updateData([
            User.CodingKeys.firstName.rawValue: firstName,
            User.CodingKeys.lastName.rawValue: lastName,
            User.CodingKeys.facilityName.rawValue: facilityName
        ])
    }
    
    /// assign quiz to user
    ///

    ///WOrking MEthod
    
    //    func assignQuizToUser(userID: String, quizID: String, dueDate: Date) async throws {
//        let userRef = userDocuments(id: userID)
//        
//        let userSnapshot = try await userRef.getDocument()
//        var user = try userSnapshot.data(as: User.self)
//        
//        if user.quizScores == nil {
//            user.quizScores = []
//        }
//        
//        if let index = user.quizScores?.firstIndex(where: { $0.quizID == quizID }) {
//            // Update existing quiz score
//            user.quizScores?[index].dueDates = [quizID: dueDate]
//        } else {
//            // Add new quiz score
//            let newQuizScore = UserQuizScore(quizID: quizID, scores: [], completionDates: [], dueDates: [quizID: dueDate])
//            user.quizScores?.append(newQuizScore)
//        }
//        
//        try await uploadUser(user: user)
//    }
//    
    func updateUser(_ user: User) async throws {
            guard let userId = user.id else {
                throw NSError(domain: "UserManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"])
            }
            let userRef = userDocuments(id: userId)
            try await userRef.setData(from: user, merge: true)
        }
    func assignQuizToUser(user: User, quiz: Quiz) async throws {
        var updatedUser = user
        let now = Date()
        let dueDate = quiz.dueDate ?? now
        let nextRenewalDate = calculateNextRenewalDate(for: quiz, from: dueDate)

        if updatedUser.quizScores == nil {
            updatedUser.quizScores = []
        }

        if let index = updatedUser.quizScores?.firstIndex(where: { $0.quizID == quiz.id }) {
            updatedUser.quizScores?[index].dueDates = [quiz.id: dueDate]
            updatedUser.quizScores?[index].nextRenewalDates = [quiz.id: nextRenewalDate]
        } else {
            let newQuizScore = UserQuizScore(
                quizID: quiz.id,
                scores: [],
                completionDates: [],
                dueDates: [quiz.id: dueDate],
                nextRenewalDates: [quiz.id: nextRenewalDate]
            )
            updatedUser.quizScores?.append(newQuizScore)
        }

        try await updateUser(updatedUser)
    }

    func calculateNextRenewalDate(for quiz: Quiz, from date: Date) -> Date? {
        guard let renewalFrequency = quiz.renewalFrequency else { return nil }
        
        let calendar = Calendar.current
        switch renewalFrequency {
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date)
        case .custom:
            return quiz.customRenewalDate
        }
    }
    func checkAndUpdateQuizRenewals(for user: User) async throws {
        var updatedUser = user
        let now = Date()

        for (index, quizScore) in updatedUser.quizScores?.enumerated() ?? [].enumerated() {
            if let nextRenewalDate = quizScore.nextRenewalDates?[quizScore.quizID],
               let unwrappedNextRenewalDate = nextRenewalDate, // Safely unwrap the optional Date
               unwrappedNextRenewalDate <= now {
                // Fetch the quiz to get the current renewal frequency
                guard let quiz = try await fetchQuiz(id: quizScore.quizID) else { continue }

                // Reset scores and update dates
                updatedUser.quizScores?[index].scores = []
                updatedUser.quizScores?[index].completionDates = []
                updatedUser.quizScores?[index].dueDates = [quizScore.quizID: now]
                
                let nextRenewalDate = quiz.calculateNextRenewalDate(from: now)
                updatedUser.quizScores?[index].nextRenewalDates = [quizScore.quizID: nextRenewalDate]
            }
        }

        // Update user in Firestore
        try await updateUser(updatedUser)
    }
    // You'll also need to implement this method:
       func fetchQuiz(id: String) async throws -> Quiz? {
           let quizRef = db.collection("Quizzes").document(id)
           let document = try await quizRef.getDocument()
           return try? document.data(as: Quiz.self)
       }
//    func getAllUserss() async throws -> [User] {
//        let snapshot = try await userCollection.getDocuments()
//        return snapshot.documents.compactMap { document -> User? in
//            do {
//                var user = try document.data(as: User.self)
//                user.id = document.documentID // Ensure the ID is set
//                return user
//            } catch {
//                print("Error decoding user document: \(error)")
//                return nil
//            }
//        }
//    }
//    
//    func getAllUserss() async throws -> [User] {
//            print("Fetching all users")
//            let snapshot = try await db.collection("Users").getDocuments()
//            let users = snapshot.documents.compactMap { document -> User? in
//                try? document.data(as: User.self)
//            }
//            print("Fetched \(users.count) users")
//            return users
//        }
    
//    func getAllUserss() async throws -> [User] {
//           print("Fetching all users")
//           // Implement your user fetching logic here
//           // For example, if using Firestore:
//           let snapshot = try await Firestore.firestore().collection("Users").getDocuments()
//           let users = snapshot.documents.compactMap { document -> User? in
//               try? document.data(as: User.self)
//           }
//           print("Fetched \(users.count) users")
//           return users
//       }
    
//    func getAllUserss() async throws -> [User] {
//          print("Fetching all users")
//        let snapshot = try await Firestore.firestore().collection("Users").getDocuments()
//          let users = snapshot.documents.compactMap { document -> User? in
//              do {
//                  let user = try document.data(as: User.self)
//                  print("Successfully decoded user: \(user.username)")
//                  return user
//              } catch {
//                  print("Error decoding user document \(document.documentID): \(error)")
//                  return nil
//              }
//          }
//          print("Fetched \(users.count) users")
//          return users
//      }
    
//    
//       func getAllUserss() async throws -> [User] {
//           print("Fetching all users")
//           let snapshot = try await Firestore.firestore().collection("Users").getDocuments()
//           let users = snapshot.documents.compactMap { document -> User? in
//               do {
//                   var user = try document.data(as: User.self)
//                   user.id = document.documentID // Ensure the id is set
//                   return user
//               } catch {
//                   print("Error decoding user document \(document.documentID): \(error)")
//                   return nil
//               }
//           }
//           print("Fetched \(users.count) users")
//           return users
//       }
    private let db = Firestore.firestore()
      
   // private let db = Firestore.firestore()
       
//       func getAllUserss() async throws -> [User] {
//           print("Fetching all users")
//           let snapshot = try await db.collection("Users").getDocuments()
//           var users: [User] = []
//           for document in snapshot.documents {
//               do {
//                   var user = try document.data(as: User.self)
//                   user.id = document.documentID
//                   users.append(user)
//                   print("Successfully decoded user: \(user.username)")
//               } catch {
//                   print("Error decoding user document \(document.documentID): \(error)")
//                   print("Document data: \(document.data())")
//               }
//           }
//           print("Fetched \(users.count) users")
//           return users
//       }
    func removeQuizFromUser(userID: String, quizID: String) async throws {
        let userRef = userDocuments(id: userID)
        let userSnapshot = try await userRef.getDocument()
        var user = try userSnapshot.data(as: User.self)
        
        user.quizScores?.removeAll { $0.quizID == quizID }
        
        try await uploadUser(user: user)
    }
    
    func createUser(firstName: String,
                       lastName: String,
                       facilityName: String,
                       username: String,
                       userUID: String,
                       userEmail: String,
                       accountType: String,
                       NHPAvalible: Bool,
                       floor: String) async throws -> User {
           
           let newUser = User(firstName: firstName,
                              lastName: lastName,
                              facilityName: facilityName,
                              username: username,
                              userUID: userUID,
                              userEmail: userEmail,
                              accountType: accountType,
                              NHPAvalible: NHPAvalible,
                              floor: floor)
           
           let userRef = db.collection("Users").document(userUID)
           try await userRef.setData(from: newUser)
           
           // Assign quizzes based on account type
           try await assignQuizzesForNewUser(user: newUser)
        return newUser
         }
           
       
    func assignQuizzesForNewUser(user: User) async throws {
        let quizzes = try await getQuizzesForAccountType(accountType: user.accountType)
        for quiz in quizzes {
            try await assignQuizToUser(user: user, quiz: quiz)
        }
    }
       
//       func getQuizzesForAccountType(accountType: String) async throws -> [Quiz] {
//           let snapshot = try await db.collection("Quizzes")
//               .whereField("accountTypes", arrayContains: accountType)
//               .getDocuments()
//           
//           return snapshot.documents.compactMap { document in
//               try? document.data(as: Quiz.self)
//           }
//       }
    func getQuizzesForAccountType(accountType: String) async throws -> [Quiz] {
        let snapshot = try await db.collection("Quizzes")
            .whereField("accountTypes", arrayContains: accountType)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Quiz.self)
        }
    }
       
       func getAllUserss() async throws -> [User] {
           print("Fetching all users")
           let snapshot = try await db.collection("Users").getDocuments()
           var users: [User] = []
           for document in snapshot.documents {
               do {
                   var user = try document.data(as: User.self)
                   user.id = document.documentID
                   users.append(user)
                   print("Successfully decoded user: \(user.username)")
               } catch {
                   print("Error decoding user document \(document.documentID): \(error)")
                   print("Document data: \(document.data() ?? [:])")
               }
           }
           print("Fetched \(users.count) users")
           return users
       }
    
}

struct QuizWithScore: Hashable {
    let quiz: Quiz
    let score: CGFloat
}
