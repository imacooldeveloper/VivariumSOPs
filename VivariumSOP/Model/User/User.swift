//
//  User.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
import FirebaseFirestore
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
     // Keep existing floor for backward compatibility during migration
     var floor: String?
     // New fields
     var assignedFloors: [String]?  // New array of floors
     var accreditations: [Accreditation]?
     var organizationId: String?
     var lastActivityDate: Date?

     // Helper enum for floor options
     static let availableFloors = ["1st", "2nd", "3rd", "4th", "5th"]

     // Helper method to migrate old floor to new format
    mutating func migrateFloor() {
        // Initialize assignedFloors if nil
        if assignedFloors == nil {
            assignedFloors = []
        }
        
        // Check if there's an old floor to migrate
        if let oldFloor = floor {
            // Force unwrap is safe here because we just initialized it if nil
            if !(assignedFloors!.contains(oldFloor)) {
                assignedFloors!.append(oldFloor)
                floor = nil  // Clear old floor after migration
            }
        }
    }
    // Helper method to get all floors (combines old and new format)
      var allFloors: [String] {
          var floors = assignedFloors ?? []
          if let oldFloor = floor, !floors.contains(oldFloor) {
              floors.append(oldFloor)
          }
          return floors
      }
    enum CodingKeys: String,CodingKey {
        case id
        case firstName
        case lastName
        case facilityName
        case username
        case userUID
        case userEmail
        case accountType
        case userPDFProgress
        case NHPAvalible
        case assignedCategoryIDs
        case quizScores
        case floor
        case assignedFloors
        case accreditations
        case organizationId
        case lastActivityDate
    }
    init(id: String? = nil, firstName: String, lastName: String, facilityName: String, username: String, userUID: String, userEmail: String, accountType: String, userPDFProgress: UserPDFProgress? = nil, NHPAvalible: Bool, assignedCategoryIDs: [String]? = nil, quizScores: [UserQuizScore]? = nil, floor: String? = nil, assignedFloors: [String]? = nil, accreditations: [Accreditation]? = nil, organizationId: String? = nil, lastActivityDate: Date? = nil) {
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
        self.assignedFloors = assignedFloors
        self.accreditations = accreditations
        self.organizationId = organizationId
        self.lastActivityDate = lastActivityDate
    }
}

// New struct to represent accreditations
struct Accreditation: Hashable, Codable {
    var name: String
    var dateReceived: Date
    var expirationDate: Date?
    var issuingAuthority: String
    var description: String?
    var documentURL: String? // Optional URL for certificate/documentation
}

// Enum for available floors
//enum Floor: String, CaseIterable, Codable {
//    case first = "1st Floor"
//    case second = "2nd Floor"
//    case third = "3rd Floor"
//    case fourth = "4th Floor"
//    case fifth = "5th Floor"
//}




//struct UserQuizScore: Hashable, Codable {
//    var quizID: String
//       var scores: [CGFloat]
//       var completionDates: [Date]
//       var dueDates: [String: Date?]?
//       var nextRenewalDates: [String: Date?]?
//
//       init(quizID: String, scores: [CGFloat], completionDates: [Date], dueDates: [String: Date?]? = nil, nextRenewalDates: [String: Date?]? = nil) {
//           self.quizID = quizID
//           self.scores = scores
//           self.completionDates = completionDates
//           self.dueDates = dueDates
//           self.nextRenewalDates = nextRenewalDates
//       }
//
//    func toDictionary() -> [String: Any] {
//        var dict: [String: Any] = [
//            "quizID": quizID,
//            "scores": scores,
//            "completionDates": completionDates.map { $0.timeIntervalSince1970 }
//        ]
//        if let dueDates = dueDates {
//            dict["dueDates"] = dueDates.mapValues { $0?.timeIntervalSince1970 }
//        }
//        if let nextRenewalDates = nextRenewalDates {
//            dict["nextRenewalDates"] = nextRenewalDates.mapValues { $0?.timeIntervalSince1970 }
//        }
//        return dict
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case quizID, scores, completionDates, dueDates, nextRenewalDates
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.quizID = try container.decode(String.self, forKey: .quizID)
//        self.scores = try container.decode([CGFloat].self, forKey: .scores)
//        self.completionDates = try container.decode([Date].self, forKey: .completionDates)
//        self.dueDates = try container.decodeIfPresent([String: Date?].self, forKey: .dueDates)
//        self.nextRenewalDates = try container.decodeIfPresent([String: Date?].self, forKey: .nextRenewalDates)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.quizID, forKey: .quizID)
//        try container.encode(self.scores, forKey: .scores)
//        try container.encode(self.completionDates, forKey: .completionDates)
//        try container.encodeIfPresent(self.dueDates, forKey: .dueDates)
//        try container.encodeIfPresent(self.nextRenewalDates, forKey: .nextRenewalDates)
//    }
//}
struct UserPDFProgress: Hashable, Codable {
    var userID: String
    var completedPDFs: [String]

    init(userID: String, completedPDFs: [String]) {
        self.userID = userID
        self.completedPDFs = completedPDFs
    }
}
