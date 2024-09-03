//
//  User.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase
struct User: Hashable, Codable, Identifiable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var facilityName: String
    var username: String
    var userUID: String
    var userEmail: String
    var accountType: String
    var userPDFProgress: UserPDFProgress?
    var NHPAvalible: Bool
    var assignedCategoryIDs: [String]?
    var quizScores: [UserQuizScore]?
    var floor: String?

    init(id: String? = nil, firstName: String, lastName: String, facilityName: String, username: String, userUID: String, userEmail: String, accountType: String, userPDFProgress: UserPDFProgress? = nil, NHPAvalible: Bool, assignedCategoryIDs: [String]? = nil, quizScores: [UserQuizScore]? = nil, floor: String? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.facilityName = facilityName
        self.username = username
        self.userUID = userUID
        self.userEmail = userEmail
        self.accountType = accountType
        self.userPDFProgress = userPDFProgress
        self.NHPAvalible = NHPAvalible
        self.assignedCategoryIDs = assignedCategoryIDs
        self.quizScores = quizScores
        self.floor = floor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.facilityName = try container.decode(String.self, forKey: .facilityName)
        self.username = try container.decode(String.self, forKey: .username)
        self.userUID = try container.decode(String.self, forKey: .userUID)
        self.userEmail = try container.decode(String.self, forKey: .userEmail)
        self.accountType = try container.decode(String.self, forKey: .accountType)
        self.userPDFProgress = try container.decodeIfPresent(UserPDFProgress.self, forKey: .userPDFProgress)
        self.NHPAvalible = try container.decode(Bool.self, forKey: .NHPAvalible)
        self.assignedCategoryIDs = try container.decodeIfPresent([String].self, forKey: .assignedCategoryIDs)
        self.quizScores = try container.decodeIfPresent([UserQuizScore].self, forKey: .quizScores)
        self.floor = try container.decodeIfPresent(String.self, forKey: .floor)
    }

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, facilityName, username, userUID, userEmail, accountType, userPDFProgress, NHPAvalible, assignedCategoryIDs, quizScores, floor
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encode(self.firstName, forKey: .firstName)
        try container.encode(self.lastName, forKey: .lastName)
        try container.encode(self.facilityName, forKey: .facilityName)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.userUID, forKey: .userUID)
        try container.encode(self.userEmail, forKey: .userEmail)
        try container.encode(self.accountType, forKey: .accountType)
        try container.encodeIfPresent(self.userPDFProgress, forKey: .userPDFProgress)
        try container.encode(self.NHPAvalible, forKey: .NHPAvalible)
        try container.encodeIfPresent(self.assignedCategoryIDs, forKey: .assignedCategoryIDs)
        try container.encodeIfPresent(self.quizScores, forKey: .quizScores)
        try container.encodeIfPresent(self.floor, forKey: .floor)
    }
}

struct UserQuizScore: Hashable, Codable {
    var quizID: String
    var scores: [CGFloat]
    var completionDates: [Date]
    var dueDates: [String: Date?]?

    init(quizID: String, scores: [CGFloat], completionDates: [Date], dueDates: [String: Date?]? = nil) {
        self.quizID = quizID
        self.scores = scores
        self.completionDates = completionDates
        self.dueDates = dueDates
    }
}

struct UserPDFProgress: Hashable, Codable {
    var userID: String
    var completedPDFs: [String]

    init(userID: String, completedPDFs: [String]) {
        self.userID = userID
        self.completedPDFs = completedPDFs
    }
}
