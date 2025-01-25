//
//  Organization.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/20/25.
//

import Foundation
struct Organization: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var settings: OrganizationSettings
    
    init(id: String = UUID().uuidString, name: String, settings: OrganizationSettings) {
        self.id = id
        self.name = name
        self.settings = settings
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case settings
    }
}

struct OrganizationSettings: Codable, Hashable {
    var quizPassingThreshold: Int
    var defaultQuizExpiryDays: Int
    var allowQuizRetakes: Bool
    var maxQuizAttempts: Int?  // Optional - nil means unlimited attempts
    var requirePDFReview: Bool
    var minimumPDFViewTime: Int
    var allowPDFDownload: Bool
    var allowedAccountTypes: [String]
    var defaultFloor: String
    var requireNHPCertification: Bool
    var organizationName: String
    var organizationLogo: String?
    var primaryColor: String
    
    init(quizPassingThreshold: Int = 80,
         defaultQuizExpiryDays: Int = 365,
         allowQuizRetakes: Bool = true,
         maxQuizAttempts: Int? = nil,  // nil means unlimited
         requirePDFReview: Bool = true,
         minimumPDFViewTime: Int = 60,
         allowPDFDownload: Bool = false,
         allowedAccountTypes: [String] = ["Husbandry", "Supervisor", "Admin", "Vet Services"],
         defaultFloor: String = "1st",
         requireNHPCertification: Bool = true,
         organizationName: String,
         organizationLogo: String? = nil,
         primaryColor: String = "#0047AB") {
        
        self.quizPassingThreshold = quizPassingThreshold
        self.defaultQuizExpiryDays = defaultQuizExpiryDays
        self.allowQuizRetakes = allowQuizRetakes
        self.maxQuizAttempts = maxQuizAttempts
        self.requirePDFReview = requirePDFReview
        self.minimumPDFViewTime = minimumPDFViewTime
        self.allowPDFDownload = allowPDFDownload
        self.allowedAccountTypes = allowedAccountTypes
        self.defaultFloor = defaultFloor
        self.requireNHPCertification = requireNHPCertification
        self.organizationName = organizationName
        self.organizationLogo = organizationLogo
        self.primaryColor = primaryColor
    }
    
    enum CodingKeys: String, CodingKey {
        case quizPassingThreshold
        case defaultQuizExpiryDays
        case allowQuizRetakes
        case maxQuizAttempts
        case requirePDFReview
        case minimumPDFViewTime
        case allowPDFDownload
        case allowedAccountTypes
        case defaultFloor
        case requireNHPCertification
        case organizationName
        case organizationLogo
        case primaryColor
    }
}

// Helper extension to check if attempts are unlimited
extension OrganizationSettings {
    var hasUnlimitedAttempts: Bool {
        return maxQuizAttempts == nil
    }
    
    func canAttemptQuiz(currentAttempts: Int) -> Bool {
        if hasUnlimitedAttempts {
            return true
        }
        guard let maxAttempts = maxQuizAttempts else { return false }
        return currentAttempts < maxAttempts
    }
}

///
///
///

//// Example of creating an organization with unlimited quiz attempts
//let unlimitedSettings = OrganizationSettings(
//    organizationName: "Vivarium Research Center",
//    maxQuizAttempts: nil  // This makes it unlimited
//)
//
//// Example of creating an organization with limited attempts
//let limitedSettings = OrganizationSettings(
//    organizationName: "Animal Care Facility",
//    maxQuizAttempts: 3    // This limits to 3 attempts
//)
//
//// Creating organizations
//let organization1 = Organization(
//    name: "Vivarium Research Center",
//    settings: unlimitedSettings
//)
//
//let organization2 = Organization(
//    name: "Animal Care Facility",
//    settings: limitedSettings
//)
