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

struct Quiz: Identifiable, Codable, Hashable {
    var id: String // Firestore document ID
    var info: Info
    var quizCategory: String
    var quizCategoryID: String
    var accountTypes: [String] // Array of account types
    var dateCreated: Date? // Optional date created
    var dueDate: Date? // Optional date due
    var renewalFrequency: RenewalFrequency?
    var nextRenewalDates: Date? // New property for next renewal date
    var customRenewalDate: Date? // Custom renewal date

    enum RenewalFrequency: String, Codable, CaseIterable {
        case quarterly
        case yearly
        case custom
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

    // Updated initializer
    init(id: String, info: Info, quizCategory: String, quizCategoryID: String, accountTypes: [String] = [], dateCreated: Date? = nil, dueDate: Date? = nil, renewalFrequency: RenewalFrequency? = nil, nextRenewalDates: Date? = nil, customRenewalDate: Date? = nil) {
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
    }

    // Updated coding keys
    enum CodingKeys: String, CodingKey {
        case id, info, quizCategory, quizCategoryID, accountTypes, dateCreated, dueDate, renewalFrequency, nextRenewalDates, customRenewalDate
    }

    // You may need to update these methods if they're not automatically synthesized
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        info = try container.decode(Info.self, forKey: .info)
        quizCategory = try container.decode(String.self, forKey: .quizCategory)
        quizCategoryID = try container.decode(String.self, forKey: .quizCategoryID)
        accountTypes = try container.decode([String].self, forKey: .accountTypes)
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        renewalFrequency = try container.decodeIfPresent(RenewalFrequency.self, forKey: .renewalFrequency)
        nextRenewalDates = try container.decodeIfPresent(Date.self, forKey: .nextRenewalDates)
        customRenewalDate = try container.decodeIfPresent(Date.self, forKey: .customRenewalDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(info, forKey: .info)
        try container.encode(quizCategory, forKey: .quizCategory)
        try container.encode(quizCategoryID, forKey: .quizCategoryID)
        try container.encode(accountTypes, forKey: .accountTypes)
        try container.encodeIfPresent(dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encodeIfPresent(renewalFrequency, forKey: .renewalFrequency)
        try container.encodeIfPresent(nextRenewalDates, forKey: .nextRenewalDates)
        try container.encodeIfPresent(customRenewalDate, forKey: .customRenewalDate)
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
