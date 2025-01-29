//
//  Category.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
//struct Category: Identifiable,Hashable, Codable {
//    var id = UUID().uuidString
//    let categoryTitle: String
//}



struct Category: Identifiable, Hashable, Codable {
    var id = UUID().uuidString
    let categoryTitle: String
    let organizationId: String // Add organization ID
    
    init(id: String = UUID().uuidString, categoryTitle: String, organizationId: String) {
        self.id = id
        self.categoryTitle = categoryTitle
        self.organizationId = organizationId
    }
}

struct SOPCategory: Identifiable, Hashable, Codable {
    var id = UUID().uuidString
    var nameOfCategory: String
    var SOPForStaffTittle: String
    var sopPages: String?
    var organizationId: String // Add organization ID
    
    init(id: String = UUID().uuidString, nameOfCategory: String, SOPForStaffTittle: String, sopPages: String? = nil, organizationId: String) {
        self.id = id
        self.nameOfCategory = nameOfCategory
        self.SOPForStaffTittle = SOPForStaffTittle
        self.sopPages = sopPages
        self.organizationId = organizationId
    }
    
    enum CodingKeys:String,  CodingKey{
        case id
        case nameOfCategory
        case SOPForStaffTittle
        case sopPages
        case organizationId
    }
}

struct PDFCategory: Identifiable, Hashable, Codable {
    var id = UUID().uuidString
    var nameOfCategory: String
    var SOPForStaffTittle: String
    var pdfName: String
    var pdfURL: String?
    var organizationId: String // Add organization ID

    init(id: String = UUID().uuidString,
         nameOfCategory: String,
         SOPForStaffTittle: String,
         pdfName: String,
         pdfURL: String? = nil,
         organizationId: String) {
        self.id = id
        self.nameOfCategory = nameOfCategory
        self.SOPForStaffTittle = SOPForStaffTittle
        self.pdfName = pdfName
        self.pdfURL = pdfURL
        self.organizationId = organizationId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case nameOfCategory
        case SOPForStaffTittle
        case pdfName
        case pdfURL
        case organizationId
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.nameOfCategory = try container.decode(String.self, forKey: .nameOfCategory)
        self.SOPForStaffTittle = try container.decode(String.self, forKey: .SOPForStaffTittle)
        self.pdfName = try container.decode(String.self, forKey: .pdfName)
        self.pdfURL = try container.decodeIfPresent(String.self, forKey: .pdfURL)
        self.organizationId = try container.decode(String.self, forKey: .organizationId)
    }
}
