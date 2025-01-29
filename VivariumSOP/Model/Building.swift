//
//  Building.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/28/25.
//

import Foundation
struct Building: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var code: String
    var type: BuildingType
    var maxBioSafetyLevel: BioSafetyLevel
    var address: String
    var notes: String?
    var isActive: Bool
    var organizationId: String
    var floors: [Floor]
    
    enum BuildingType: String, Codable, CaseIterable {
        case research = "Research"
        case vivarium = "Vivarium"
        case clinical = "Clinical"
        case mixed = "Mixed Use"
    }
    
    enum BioSafetyLevel: Int, Codable, CaseIterable {
        case bsl1 = 1
        case bsl2 = 2
        case bsl3 = 3
        case bsl4 = 4
    }
}
enum AnimalType: String, Codable, CaseIterable {
    case mouse = "Mouse"
    case rat = "Rat"
    case guineaPig = "Guinea Pig"
    case hamster = "Hamster"
    case rabbit = "Rabbit"
    case nonHumanPrimate = "Non-Human Primate"
    // Add more as needed
    // Could also include custom cases if needed
}
