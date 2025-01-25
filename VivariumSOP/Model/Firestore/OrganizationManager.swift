//
//  OrganizationManager.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/20/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class OrganizationManager {
    static let shared = OrganizationManager()
    private let db = Firestore.firestore()
    private let organizationCollection = Firestore.firestore().collection("Organizations")
    
    private func organizationDocument(id: String) -> DocumentReference {
        organizationCollection.document(id)
    }
    
    // CRUD Operations
    @MainActor
    func createOrganization(_ organization: Organization) async throws {
        try organizationDocument(id: organization.id).setData(from: organization)
    }
    
    @MainActor
    func getOrganization(id: String) async throws -> Organization {
        let snapshot = try await organizationDocument(id: id).getDocument()
        guard let organization = try? snapshot.data(as: Organization.self) else {
            throw NSError(domain: "OrganizationManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Organization not found"])
        }
        return organization
    }
    
    @MainActor
    func updateOrganization(_ organization: Organization) async throws {
        try await organizationDocument(id: organization.id).setData(from: organization, merge: true)
    }
    
    @MainActor
    func deleteOrganization(id: String) async throws {
        try await organizationDocument(id: id).delete()
    }
    
    @MainActor
    func getAllOrganizations() async throws -> [Organization] {
        let snapshot = try await organizationCollection.getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Organization.self)
        }
    }
    
    // Organization Settings Management
    @MainActor
    func updateOrganizationSettings(orgId: String, settings: OrganizationSettings) async throws {
        try await organizationDocument(id: orgId).updateData([
            "settings": settings
        ])
    }
    
    // Organization Users Management
    @MainActor
    func getUsersInOrganization(orgId: String) async throws -> [User] {
        let snapshot = try await db.collection("Users")
            .whereField("organizationId", isEqualTo: orgId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: User.self)
        }
    }
    
    // Organization Quizzes Management
    @MainActor
    func getQuizzesForOrganization(orgId: String) async throws -> [Quiz] {
        let snapshot = try await db.collection("Quiz")
            .whereField("organizationId", isEqualTo: orgId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Quiz.self)
        }
    }
    
    // Helper Functions
    @MainActor
    func isUserInOrganization(_ userId: String, orgId: String) async throws -> Bool {
        let snapshot = try await db.collection("Users")
            .whereField("id", isEqualTo: userId)
            .whereField("organizationId", isEqualTo: orgId)
            .getDocuments()
        
        return !snapshot.documents.isEmpty
    }
    
    @MainActor
    func validateSettings(_ settings: OrganizationSettings) -> Bool {
        // Add validation rules for organization settings
        guard settings.quizPassingThreshold >= 0 && settings.quizPassingThreshold <= 100 else {
            return false
        }
        
        guard settings.minimumPDFViewTime >= 0 else {
            return false
        }
        
        guard !settings.allowedAccountTypes.isEmpty else {
            return false
        }
        
        return true
    }
}

// Extension for common queries
extension OrganizationManager {
    @MainActor
    func getOrganizationStats(orgId: String) async throws -> OrganizationStats {
        let users = try await getUsersInOrganization(orgId: orgId)
        let quizzes = try await getQuizzesForOrganization(orgId: orgId)
        
        let activeUserCount = users.filter { user -> Bool in
            if let lastActivity = user.lastActivityDate {
                return Calendar.current.isDateInToday(lastActivity)
            }
            return false
        }.count
        
        return OrganizationStats(
            totalUsers: users.count,
            totalQuizzes: quizzes.count,
            activeUsers: activeUserCount
        )
    }
}
// Supporting Types
struct OrganizationStats {
    let totalUsers: Int
    let totalQuizzes: Int
    let activeUsers: Int
}
