//
//  Category.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
struct Category: Identifiable,Hashable, Codable {
    var id = UUID().uuidString
    let categoryTitle: String
}

struct SOPCategory: Identifiable, Hashable, Codable {
    var id = UUID().uuidString
    var nameOfCategory: String
    var SOPForStaffTittle: String
    var sopPages: String?
    
    init(id: String = UUID().uuidString, nameOfCategory: String, SOPForStaffTittle: String, sopPages: String? = nil) {
        self.id = id
        self.nameOfCategory = nameOfCategory
        self.SOPForStaffTittle = SOPForStaffTittle
        self.sopPages = sopPages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.nameOfCategory = try container.decode(String.self, forKey: .nameOfCategory)
        self.SOPForStaffTittle = try container.decode(String.self, forKey: .SOPForStaffTittle)
        self.sopPages = try container.decodeIfPresent(String.self, forKey: .sopPages) ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case nameOfCategory
        case SOPForStaffTittle
        case sopPages
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.nameOfCategory, forKey: .nameOfCategory)
        try container.encode(self.SOPForStaffTittle, forKey: .SOPForStaffTittle)
        try container.encode(self.sopPages, forKey: .sopPages)
    }
}

//struct PDFCategory: Identifiable,Hashable, Codable {
//    var id = UUID().uuidString
//    var nameOfCategory: String
//    var SOPForStaffTittle: String
//    var pdfName: String
//    
//    init(id: String = UUID().uuidString, nameOfCategory: String, SOPForStaffTittle: String, pdfName: String) {
//        self.id = id
//        self.nameOfCategory = nameOfCategory
//        self.SOPForStaffTittle = SOPForStaffTittle
//        self.pdfName = pdfName
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(String.self, forKey: .id)
//        self.nameOfCategory = try container.decode(String.self, forKey: .nameOfCategory)
//        self.SOPForStaffTittle = try container.decode(String.self, forKey: .SOPForStaffTittle)
//        self.pdfName = try container.decode(String.self, forKey: .pdfName)
//    }
//    enum CodingKeys:String, CodingKey {
//        case id
//        case nameOfCategory
//        case SOPForStaffTittle
//        case pdfName
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.id, forKey: .id)
//        try container.encode(self.nameOfCategory, forKey: .nameOfCategory)
//        try container.encode(self.SOPForStaffTittle, forKey: .SOPForStaffTittle)
//        try container.encode(self.pdfName, forKey: .pdfName)
//    }
//}
struct PDFCategory: Identifiable, Hashable, Codable {
    var id = UUID().uuidString
    var nameOfCategory: String
    var SOPForStaffTittle: String
    var pdfName: String
    var pdfURL: String? // Optional pdfURL

    init(id: String = UUID().uuidString, nameOfCategory: String, SOPForStaffTittle: String, pdfName: String, pdfURL: String? = nil) {
        self.id = id
        self.nameOfCategory = nameOfCategory
        self.SOPForStaffTittle = SOPForStaffTittle
        self.pdfName = pdfName
        self.pdfURL = pdfURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.nameOfCategory = try container.decode(String.self, forKey: .nameOfCategory)
        self.SOPForStaffTittle = try container.decode(String.self, forKey: .SOPForStaffTittle)
        self.pdfName = try container.decode(String.self, forKey: .pdfName)
        self.pdfURL = try container.decodeIfPresent(String.self, forKey: .pdfURL) // Decode optional pdfURL
    }

    enum CodingKeys: String, CodingKey {
        case id
        case nameOfCategory
        case SOPForStaffTittle
        case pdfName
        case pdfURL // Add pdfURL to coding keys
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.nameOfCategory, forKey: .nameOfCategory)
        try container.encode(self.SOPForStaffTittle, forKey: .SOPForStaffTittle)
        try container.encode(self.pdfName, forKey: .pdfName)
        try container.encodeIfPresent(self.pdfURL, forKey: .pdfURL) // Encode optional pdfURL
    }
}
