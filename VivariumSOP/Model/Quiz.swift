//
//  Quiz.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation

/// working method
//struct Quiz: Identifiable, Codable, Hashable {
//    var id: String // Firestore document ID
//    var info: Info
//    var quizCategory: String
//    var quizCategoryID: String
//    var accountTypes: [String] // Array of account types
//    var dateCreated: Date? // Optional date created
//    var dueDate: Date? // Optional date due
//
//    init(id: String, info: Info, quizCategory: String, quizCategoryID: String, accountTypes: [String] = [], dateCreated: Date? = nil, dueDate: Date? = nil) {
//        self.id = id
//        self.info = info
//        self.quizCategory = quizCategory
//        self.quizCategoryID = quizCategoryID
//        self.accountTypes = accountTypes
//        self.dateCreated = dateCreated
//        self.dueDate = dueDate
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(String.self, forKey: .id)
//        self.info = try container.decode(Info.self, forKey: .info)
//        self.quizCategory = try container.decode(String.self, forKey: .quizCategory)
//        self.quizCategoryID = try container.decode(String.self, forKey: .quizCategoryID)
//        self.accountTypes = try container.decodeIfPresent([String].self, forKey: .accountTypes) ?? []
//        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
//        self.dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case info
//        case quizCategory
//        case quizCategoryID
//        case accountTypes
//        case dateCreated
//        case dueDate
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.id, forKey: .id)
//        try container.encode(self.info, forKey: .info)
//        try container.encode(self.quizCategory, forKey: .quizCategory)
//        try container.encode(self.quizCategoryID, forKey: .quizCategoryID)
//        try container.encode(self.accountTypes, forKey: .accountTypes)
//        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
//        try container.encodeIfPresent(self.dueDate, forKey: .dueDate)
//    }
//}


import Foundation

//struct Quiz: Identifiable, Codable, Hashable {
//    var id: String // Firestore document ID
//    var info: Info
//    var quizCategory: String
//    var quizCategoryID: String
//    var accountTypes: [String] // Array of account types
//    var dateCreated: Date? // Optional date created
//    var dueDate: Date? // Optional date due
//    var renewalFrequency: RenewalFrequency?
//    var nextRenewalDates: Date? // New property for next renewal date
//    var customRenewalDate: Date? // Custom renewal date
//
//    enum RenewalFrequency: String, Codable, CaseIterable {
//        case quarterly
//        case yearly
//        case custom
//    }
//
//    func calculateNextRenewalDate(from date: Date) -> Date? {
//        guard let frequency = self.renewalFrequency else { return nil }
//        let calendar = Calendar.current
//        switch frequency {
//        case .quarterly:
//            return calendar.date(byAdding: .month, value: 3, to: date)
//        case .yearly:
//            return calendar.date(byAdding: .year, value: 1, to: date)
//        case .custom:
//            return self.customRenewalDate
//        }
//    }
//
//    // Updated initializer
//    init(id: String, info: Info, quizCategory: String, quizCategoryID: String, accountTypes: [String] = [], dateCreated: Date? = nil, dueDate: Date? = nil, renewalFrequency: RenewalFrequency? = nil, nextRenewalDates: Date? = nil, customRenewalDate: Date? = nil) {
//        self.id = id
//        self.info = info
//        self.quizCategory = quizCategory
//        self.quizCategoryID = quizCategoryID
//        self.accountTypes = accountTypes
//        self.dateCreated = dateCreated
//        self.dueDate = dueDate
//        self.renewalFrequency = renewalFrequency
//        self.nextRenewalDates = nextRenewalDates
//        self.customRenewalDate = customRenewalDate
//    }
//
//    // Updated coding keys
//    enum CodingKeys: String, CodingKey {
//        case id, info, quizCategory, quizCategoryID, accountTypes, dateCreated, dueDate, renewalFrequency, nextRenewalDates, customRenewalDate
//    }
//
//    // You may need to update these methods if they're not automatically synthesized
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
//        info = try container.decode(Info.self, forKey: .info)
//        quizCategory = try container.decode(String.self, forKey: .quizCategory)
//        quizCategoryID = try container.decode(String.self, forKey: .quizCategoryID)
//        accountTypes = try container.decode([String].self, forKey: .accountTypes)
//        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
//        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
//        renewalFrequency = try container.decodeIfPresent(RenewalFrequency.self, forKey: .renewalFrequency)
//        nextRenewalDates = try container.decodeIfPresent(Date.self, forKey: .nextRenewalDates)
//        customRenewalDate = try container.decodeIfPresent(Date.self, forKey: .customRenewalDate)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(info, forKey: .info)
//        try container.encode(quizCategory, forKey: .quizCategory)
//        try container.encode(quizCategoryID, forKey: .quizCategoryID)
//        try container.encode(accountTypes, forKey: .accountTypes)
//        try container.encodeIfPresent(dateCreated, forKey: .dateCreated)
//        try container.encodeIfPresent(dueDate, forKey: .dueDate)
//        try container.encodeIfPresent(renewalFrequency, forKey: .renewalFrequency)
//        try container.encodeIfPresent(nextRenewalDates, forKey: .nextRenewalDates)
//        try container.encodeIfPresent(customRenewalDate, forKey: .customRenewalDate)
//    }
//}

//struct Quiz: Identifiable, Codable, Hashable {
//    var id: String
//    var info: Info
//    var quizCategory: String
//    var quizCategoryID: String
//    var accountTypes: [String]
//    var dateCreated: Date?
//    var dueDate: Date?
//    var renewalFrequency: RenewalFrequency?
//    var nextRenewalDates: Date?
//    var customRenewalDate: Date?
//    var organizationId: String // New field
//    
//    enum RenewalFrequency: String, Codable, CaseIterable {
//        case quarterly
//        case yearly
//        case custom
//    }
//    
//    init(id: String,
//         info: Info,
//         quizCategory: String,
//         quizCategoryID: String,
//         accountTypes: [String] = [],
//         dateCreated: Date? = nil,
//         dueDate: Date? = nil,
//         renewalFrequency: RenewalFrequency? = nil,
//         nextRenewalDates: Date? = nil,
//         customRenewalDate: Date? = nil,
//         organizationId: String) {
//        self.id = id
//        self.info = info
//        self.quizCategory = quizCategory
//        self.quizCategoryID = quizCategoryID
//        self.accountTypes = accountTypes
//        self.dateCreated = dateCreated
//        self.dueDate = dueDate
//        self.renewalFrequency = renewalFrequency
//        self.nextRenewalDates = nextRenewalDates
//        self.customRenewalDate = customRenewalDate
//        self.organizationId = organizationId
//    }
//    func calculateNextRenewalDate(from date: Date) -> Date? {
//        guard let frequency = self.renewalFrequency else { return nil }
//        let calendar = Calendar.current
//        switch frequency {
//        case .quarterly:
//            return calendar.date(byAdding: .month, value: 3, to: date)
//        case .yearly:
//            return calendar.date(byAdding: .year, value: 1, to: date)
//        case .custom:
//            return self.customRenewalDate
//        }
//    }
//    enum CodingKeys: String, CodingKey {
//        case id, info, quizCategory, quizCategoryID, accountTypes, dateCreated, dueDate,
//             renewalFrequency, nextRenewalDates, customRenewalDate, organizationId
//    }
//    
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.id, forKey: .id)
//        try container.encode(self.info, forKey: .info)
//        try container.encode(self.quizCategory, forKey: .quizCategory)
//        try container.encode(self.quizCategoryID, forKey: .quizCategoryID)
//        try container.encode(self.accountTypes, forKey: .accountTypes)
//        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
//        try container.encodeIfPresent(self.dueDate, forKey: .dueDate)
//        try container.encodeIfPresent(self.renewalFrequency, forKey: .renewalFrequency)
//        try container.encodeIfPresent(self.nextRenewalDates, forKey: .nextRenewalDates)
//        try container.encodeIfPresent(self.customRenewalDate, forKey: .customRenewalDate)
//        try container.encode(self.organizationId, forKey: .organizationId)
//    }
//}


struct Quiz: Identifiable, Codable, Hashable {
    var id: String
    var info: Info
    var quizCategory: String
    var quizCategoryID: String
    var accountTypes: [String]
    var dateCreated: Date?
    var dueDate: Date?
    var renewalFrequency: RenewalFrequency?
    var nextRenewalDates: Date?
    var customRenewalDate: Date?
    var organizationId: String
    var verificationType: VerificationType
    var acknowledgmentText: String?  // Text to be acknowledged
    var questions: [Question]?       // Optional now
    
    enum VerificationType: String, Codable, CaseIterable {
        case quiz
        case acknowledgment
        case both
    }
    
    // Additional metadata for acknowledgments
    struct AcknowledgmentMetadata: Codable, Hashable {
        var requiredReadingTime: Int?  // Minimum time in seconds required to read
        var acknowledgmentStatement: String  // e.g., "I have read and understood..."
        var additionalNotes: String?
        var requireSignature: Bool  // Whether electronic signature is required
    }
    func calculateNextRenewalDate(from date: Date) -> Date? {
        guard let frequency = self.renewalFrequency else { return nil }
        let calendar = Calendar.current
        switch frequency {
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date)
        case .custom:
            return self.customRenewalDate
        }
    }
    enum RenewalFrequency: String, Codable, CaseIterable {
        case quarterly
        case yearly
        case custom
    }
    
    var acknowledgmentMetadata: AcknowledgmentMetadata?
    init(id: String, info: Info, quizCategory: String, quizCategoryID: String, accountTypes: [String], dateCreated: Date? = nil, dueDate: Date? = nil, renewalFrequency: RenewalFrequency? = nil, nextRenewalDates: Date? = nil, customRenewalDate: Date? = nil, organizationId: String, verificationType: VerificationType, acknowledgmentText: String? = nil, questions: [Question]? = nil, acknowledgmentMetadata: AcknowledgmentMetadata? = nil) {
        self.id = id
        self.info = info
        self.quizCategory = quizCategory
        self.quizCategoryID = quizCategoryID
        self.accountTypes = accountTypes
        self.dateCreated = dateCreated
        self.dueDate = dueDate
        self.renewalFrequency = renewalFrequency
        self.nextRenewalDates = nextRenewalDates
        self.customRenewalDate = customRenewalDate
        self.organizationId = organizationId
        self.verificationType = verificationType
        self.acknowledgmentText = acknowledgmentText
        self.questions = questions
        self.acknowledgmentMetadata = acknowledgmentMetadata
    }
   
    enum CodingKeys: String, CodingKey {
        case id
        case info
        case quizCategory
        case quizCategoryID
        case accountTypes
        case dateCreated
        case dueDate
        case renewalFrequency
        case nextRenewalDates
        case customRenewalDate
        case organizationId
        case verificationType
        case acknowledgmentText
        case questions
        case acknowledgmentMetadata
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.info, forKey: .info)
        try container.encode(self.quizCategory, forKey: .quizCategory)
        try container.encode(self.quizCategoryID, forKey: .quizCategoryID)
        try container.encode(self.accountTypes, forKey: .accountTypes)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.dueDate, forKey: .dueDate)
        try container.encodeIfPresent(self.renewalFrequency, forKey: .renewalFrequency)
        try container.encodeIfPresent(self.nextRenewalDates, forKey: .nextRenewalDates)
        try container.encodeIfPresent(self.customRenewalDate, forKey: .customRenewalDate)
        try container.encode(self.organizationId, forKey: .organizationId)
        try container.encode(self.verificationType, forKey: .verificationType)
        try container.encodeIfPresent(self.acknowledgmentText, forKey: .acknowledgmentText)
        try container.encodeIfPresent(self.questions, forKey: .questions)
        try container.encodeIfPresent(self.acknowledgmentMetadata, forKey: .acknowledgmentMetadata)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.info = try container.decode(Info.self, forKey: .info)
        self.quizCategory = try container.decode(String.self, forKey: .quizCategory)
        self.quizCategoryID = try container.decode(String.self, forKey: .quizCategoryID)
        self.accountTypes = try container.decode([String].self, forKey: .accountTypes)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        self.renewalFrequency = try container.decodeIfPresent(Quiz.RenewalFrequency.self, forKey: .renewalFrequency)
        self.nextRenewalDates = try container.decodeIfPresent(Date.self, forKey: .nextRenewalDates)
        self.customRenewalDate = try container.decodeIfPresent(Date.self, forKey: .customRenewalDate)
        self.organizationId = try container.decode(String.self, forKey: .organizationId)
        
        // Handle verificationType with a default value for backward compatibility
        self.verificationType = try container.decodeIfPresent(Quiz.VerificationType.self, forKey: .verificationType) ?? .quiz
        
        // Handle optional fields
        self.acknowledgmentText = try container.decodeIfPresent(String.self, forKey: .acknowledgmentText)
        self.questions = try container.decodeIfPresent([Question].self, forKey: .questions)
        self.acknowledgmentMetadata = try container.decodeIfPresent(Quiz.AcknowledgmentMetadata.self, forKey: .acknowledgmentMetadata)
    }
}

//struct Quiz: Identifiable, Codable, Hashable {
//    var id: String
//    var info: Info
//    var quizCategory: String           // This is the subcategory/SOPForStaffTittle
//    var parentCategory: String         // Add this to store the main category name
//    var quizCategoryID: String
//    var accountTypes: [String]
//    var dateCreated: Date?
//    var dueDate: Date?
//    var renewalFrequency: RenewalFrequency?
//    var nextRenewalDates: Date?
//    var customRenewalDate: Date?
//    var organizationId: String
//    var verificationType: VerificationType
//    var acknowledgmentText: String?
//    var questions: [Question]?
//
//    enum VerificationType: String, Codable, CaseIterable {
//        case quiz
//        case acknowledgment
//        case both
//    }
//    
//    // Additional metadata for acknowledgments
//    struct AcknowledgmentMetadata: Codable, Hashable {
//        var requiredReadingTime: Int?  // Minimum time in seconds required to read
//        var acknowledgmentStatement: String  // e.g., "I have read and understood..."
//        var additionalNotes: String?
//        var requireSignature: Bool  // Whether electronic signature is required
//    }
//    func calculateNextRenewalDate(from date: Date) -> Date? {
//        guard let frequency = self.renewalFrequency else { return nil }
//        let calendar = Calendar.current
//        switch frequency {
//        case .quarterly:
//            return calendar.date(byAdding: .month, value: 3, to: date)
//        case .yearly:
//            return calendar.date(byAdding: .year, value: 1, to: date)
//        case .custom:
//            return self.customRenewalDate
//        }
//    }
//    enum RenewalFrequency: String, Codable, CaseIterable {
//        case quarterly
//        case yearly
//        case custom
//    }
//    
//    var acknowledgmentMetadata: AcknowledgmentMetadata?
//    
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.id, forKey: .id)
//        try container.encode(self.info, forKey: .info)
//        try container.encode(self.quizCategory, forKey: .quizCategory)
//        try container.encode(self.parentCategory, forKey: .parentCategory)
//        try container.encode(self.quizCategoryID, forKey: .quizCategoryID)
//        try container.encode(self.accountTypes, forKey: .accountTypes)
//        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
//        try container.encodeIfPresent(self.dueDate, forKey: .dueDate)
//        try container.encodeIfPresent(self.renewalFrequency, forKey: .renewalFrequency)
//        try container.encodeIfPresent(self.nextRenewalDates, forKey: .nextRenewalDates)
//        try container.encodeIfPresent(self.customRenewalDate, forKey: .customRenewalDate)
//        try container.encode(self.organizationId, forKey: .organizationId)
//        try container.encode(self.verificationType, forKey: .verificationType)
//        try container.encodeIfPresent(self.acknowledgmentText, forKey: .acknowledgmentText)
//        try container.encodeIfPresent(self.questions, forKey: .questions)
//        try container.encodeIfPresent(self.acknowledgmentMetadata, forKey: .acknowledgmentMetadata)
//    }
//    enum CodingKeys: String,CodingKey {
//        case id
//        case info
//        case quizCategory
//        case parentCategory
//        case quizCategoryID
//        case accountTypes
//        case dateCreated
//        case dueDate
//        case renewalFrequency
//        case nextRenewalDates
//        case customRenewalDate
//        case organizationId
//        case verificationType
//        case acknowledgmentText
//        case questions
//        case acknowledgmentMetadata
//    }
//    
////    init(from decoder: any Decoder) throws {
////        let container = try decoder.container(keyedBy: CodingKeys.self)
////        self.id = try container.decode(String.self, forKey: .id)
////        self.info = try container.decode(Info.self, forKey: .info)
////        self.quizCategory = try container.decode(String.self, forKey: .quizCategory)
////        self.parentCategory = try container.decode(String.self, forKey: .parentCategory)
////        self.quizCategoryID = try container.decode(String.self, forKey: .quizCategoryID)
////        self.accountTypes = try container.decode([String].self, forKey: .accountTypes)
////        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
////        self.dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
////        self.renewalFrequency = try container.decodeIfPresent(Quiz.RenewalFrequency.self, forKey: .renewalFrequency)
////        self.nextRenewalDates = try container.decodeIfPresent(Date.self, forKey: .nextRenewalDates)
////        self.customRenewalDate = try container.decodeIfPresent(Date.self, forKey: .customRenewalDate)
////        self.organizationId = try container.decode(String.self, forKey: .organizationId)
////        self.verificationType = try container.decode(Quiz.VerificationType.self, forKey: .verificationType)
////        self.acknowledgmentText = try container.decodeIfPresent(String.self, forKey: .acknowledgmentText)
////        self.questions = try container.decodeIfPresent([Question].self, forKey: .questions)
////        self.acknowledgmentMetadata = try container.decodeIfPresent(Quiz.AcknowledgmentMetadata.self, forKey: .acknowledgmentMetadata)
////    }
////
//    
//    init(id: String, info: Info, quizCategory: String, parentCategory: String, quizCategoryID: String, accountTypes: [String], dateCreated: Date? = nil, dueDate: Date? = nil, renewalFrequency: RenewalFrequency? = nil, nextRenewalDates: Date? = nil, customRenewalDate: Date? = nil, organizationId: String, verificationType: VerificationType, acknowledgmentText: String? = nil, questions: [Question]? = nil, acknowledgmentMetadata: AcknowledgmentMetadata? = nil) {
//        self.id = id
//        self.info = info
//        self.quizCategory = quizCategory
//        self.parentCategory = parentCategory
//        self.quizCategoryID = quizCategoryID
//        self.accountTypes = accountTypes
//        self.dateCreated = dateCreated
//        self.dueDate = dueDate
//        self.renewalFrequency = renewalFrequency
//        self.nextRenewalDates = nextRenewalDates
//        self.customRenewalDate = customRenewalDate
//        self.organizationId = organizationId
//        self.verificationType = verificationType
//        self.acknowledgmentText = acknowledgmentText
//        self.questions = questions
//        self.acknowledgmentMetadata = acknowledgmentMetadata
//    }
//    
//    
//
////    enum CodingKeys: String,CodingKey {
////        case id
////        case info
////        case quizCategory
////        case parentCategory
////        case quizCategoryID
////        case accountTypes
////        case dateCreated
////        case dueDate
////        case renewalFrequency
////        case nextRenewalDates
////        case customRenewalDate
////        case organizationId
////        case verificationType
////        case acknowledgmentText
////        case questions
////    }
////
//}
extension Quiz.VerificationType {
    var displayTitle: String {
        switch self {
        case .quiz: return "Quiz Only"
        case .acknowledgment: return "Acknowledgment Only"
        case .both: return "Quiz and Acknowledgment"
        }
    }
}
// Updated UserQuizScore to handle both types of verification
struct UserQuizScore: Hashable, Codable {
    var quizID: String
    var scores: [CGFloat]
    var completionDates: [Date]
    var dueDates: [String: Date?]?
    var nextRenewalDates: [String: Date?]?
    var acknowledgmentStatus: AcknowledgmentStatus?
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "quizID": quizID,
            "scores": scores,
            "completionDates": completionDates.map { $0.timeIntervalSince1970 }
        ]
        if let dueDates = dueDates {
            dict["dueDates"] = dueDates.mapValues { $0?.timeIntervalSince1970 }
        }
        if let nextRenewalDates = nextRenewalDates {
            dict["nextRenewalDates"] = nextRenewalDates.mapValues { $0?.timeIntervalSince1970 }
        }
        return dict
    }
    struct AcknowledgmentStatus: Codable, Hashable {
        var acknowledged: Bool
        var acknowledgedDate: Date
        var readingTime: TimeInterval?
        var signature: String?
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.quizID, forKey: .quizID)
        try container.encode(self.scores, forKey: .scores)
        try container.encode(self.completionDates, forKey: .completionDates)
        try container.encodeIfPresent(self.dueDates, forKey: .dueDates)
        try container.encodeIfPresent(self.nextRenewalDates, forKey: .nextRenewalDates)
        try container.encodeIfPresent(self.acknowledgmentStatus, forKey: .acknowledgmentStatus)
    }
    init(quizID: String, scores: [CGFloat], completionDates: [Date], dueDates: [String : Date?]? = nil, nextRenewalDates: [String : Date?]? = nil, acknowledgmentStatus: AcknowledgmentStatus? = nil) {
        self.quizID = quizID
        self.scores = scores
        self.completionDates = completionDates
        self.dueDates = dueDates
        self.nextRenewalDates = nextRenewalDates
        self.acknowledgmentStatus = acknowledgmentStatus
    }
    enum CodingKeys: String, CodingKey {
        case quizID
        case scores
        case completionDates
        case dueDates
        case nextRenewalDates
        case acknowledgmentStatus
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.quizID = try container.decode(String.self, forKey: .quizID)
        self.scores = try container.decode([CGFloat].self, forKey: .scores)
        self.completionDates = try container.decode([Date].self, forKey: .completionDates)
        self.dueDates = try container.decodeIfPresent([String : Date?].self, forKey: .dueDates)
        self.nextRenewalDates = try container.decodeIfPresent([String : Date?].self, forKey: .nextRenewalDates)
        self.acknowledgmentStatus = try container.decodeIfPresent(UserQuizScore.AcknowledgmentStatus.self, forKey: .acknowledgmentStatus)
    }
    
}


struct Question: Identifiable, Codable, Hashable {
    var id: String? // Now optional, or remove entirely if not used
    var questionText: String
    var options: [String]
    var answer: String
    var tappedAnswer: String = ""
    
    
    init(id: String? = nil, questionText: String, options: [String], answer: String, tappedAnswer: String = "") {
        self.id = id
        self.questionText = questionText
        self.options = options
        self.answer = answer
        self.tappedAnswer = tappedAnswer
    }
    

    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
       // try container.encodeIfPresent(self.id, forKey: .id)
        try container.encode(self.questionText, forKey: .questionText)
        try container.encode(self.options, forKey: .options)
        try container.encode(self.answer, forKey: .answer)
       // try container.encode(self.tappedAnswer, forKey: .tappedAnswer)
    }
    enum CodingKeys: String,CodingKey {
    
        case questionText
        case options
        case answer
      //  case tappedAnswer
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       // self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.questionText = try container.decode(String.self, forKey: .questionText)
        self.options = try container.decode([String].self, forKey: .options)
        self.answer = try container.decode(String.self, forKey: .answer)
       // self.tappedAnswer = try container.decode(String.self, forKey: .tappedAnswer)
    }

    
    
}
