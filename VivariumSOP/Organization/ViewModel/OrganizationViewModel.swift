//
//  OrganizationViewModel.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/20/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
// Example usage
class OrganizationViewModel: ObservableObject {
    @Published var organization: Organization?
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func loadOrganization(id: String) {
        Task {
            isLoading = true
            do {
                let org = try await OrganizationManager.shared.getOrganization(id: id)
                await MainActor.run {
                    self.organization = org
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func updateOrganizationSettings(_ settings: OrganizationSettings) {
        guard let orgId = organization?.id else { return }
        
        Task {
            do {
                try await OrganizationManager.shared.updateOrganizationSettings(orgId: orgId, settings: settings)
                await loadOrganization(id: orgId)
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
}


let sampleOrganizations = [
    Organization(
        id: "org1",
        name: "Johns Hopkins Research Center",
        settings: OrganizationSettings(
            quizPassingThreshold: 80,
            defaultQuizExpiryDays: 365,
            allowQuizRetakes: true,
            maxQuizAttempts: 3,
            requirePDFReview: true,
            minimumPDFViewTime: 60,
            allowPDFDownload: false,
            allowedAccountTypes: ["Husbandry", "Supervisor", "Admin", "Vet Services"],
            defaultFloor: "1st",
            requireNHPCertification: true,
            organizationName: "Johns Hopkins Research Center"
        )
    ),
    Organization(
        id: "org2",
        name: "Stanford Vivarium",
        settings: OrganizationSettings(
            quizPassingThreshold: 75,
            defaultQuizExpiryDays: 180,
            allowQuizRetakes: true,
            maxQuizAttempts: nil, // Unlimited attempts
            requirePDFReview: true,
            minimumPDFViewTime: 120,
            allowPDFDownload: true,
            allowedAccountTypes: ["Husbandry", "Supervisor", "Admin", "Vet Services"],
            defaultFloor: "2nd",
            requireNHPCertification: true,
            organizationName: "Stanford Vivarium"
        )
    ),
    Organization(
        id: "org3",
        name: "UC Berkeley Animal Care",
        settings: OrganizationSettings(
            quizPassingThreshold: 85,
            defaultQuizExpiryDays: 90,
            allowQuizRetakes: true,
            maxQuizAttempts: 5,
            requirePDFReview: true,
            minimumPDFViewTime: 90,
            allowPDFDownload: false,
            allowedAccountTypes: ["Husbandry", "Supervisor", "Admin", "Vet Services"],
            defaultFloor: "3rd",
            requireNHPCertification: true,
            organizationName: "UC Berkeley Animal Care"
        )
    )
]

// Function to upload sample organizations to Firebase
func uploadSampleOrganizations() async {
    do {
        for organization in sampleOrganizations {
            try await OrganizationManager.shared.createOrganization(organization)
            print("Successfully uploaded organization: \(organization.name)")
        }
    } catch {
        print("Error uploading organizations: \(error)")
    }
}
