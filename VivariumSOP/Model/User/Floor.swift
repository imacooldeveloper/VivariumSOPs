//
//  Floor.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/28/25.
//

import Foundation
struct Floor: Identifiable, Codable, Hashable {
    var id: String
    var buildingId: String
    var organizationId: String
    var level: Int
    var name: String
    var isRestricted: Bool
    var sections: [String]  // Just store section names as strings
    
    enum CodingKeys: String,CodingKey {
        case id
        case buildingId
        case organizationId
        case level
        case name
        case isRestricted
        case sections
    }
    init(id: String, buildingId: String, organizationId: String, level: Int, name: String, isRestricted: Bool, sections: [String]) {
        self.id = id
        self.buildingId = buildingId
        self.organizationId = organizationId
        self.level = level
        self.name = name
        self.isRestricted = isRestricted
        self.sections = sections
    }
}
// Floor Structure Model
struct FloorSection: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var mainFloor: String  // e.g. "3rd"
    var sections: [String] // e.g. ["Main", "Annex", "Satellites"]
    var organizationId: String
    
    enum CodingKeys: String,CodingKey {
        case id
        case mainFloor
        case sections
        case organizationId
    }
    init(id: String, mainFloor: String, sections: [String], organizationId: String) {
        self.id = id
        self.mainFloor = mainFloor
        self.sections = sections
        self.organizationId = organizationId
    }
}

// Update User model to handle detailed floor assignments
struct FloorAssignment: Codable, Hashable {
    var floorId: String
    var section: String
}

