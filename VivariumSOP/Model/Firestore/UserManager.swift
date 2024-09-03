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
}

struct QuizWithScore: Hashable {
    let quiz: Quiz
    let score: CGFloat
}
