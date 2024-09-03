//
//  Info.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import Foundation
struct Info: Codable, Hashable {
    var title: String
     var description: String // Assuming there's a description or similar field
     var peopleAttended: Int?
     var rules: [String]?
    
    
    init(title: String, description: String, peopleAttended: Int, rules: [String]) {
        self.title = title
        self.description = description
        self.peopleAttended = peopleAttended
        self.rules = rules
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.peopleAttended = try container.decodeIfPresent(Int.self, forKey: .peopleAttended)
        self.rules = try container.decodeIfPresent([String].self, forKey: .rules)
    }
    

    enum CodingKeys:String, CodingKey {
        case title
        case description
        case peopleAttended
        case rules
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.description, forKey: .description)
        try container.encodeIfPresent(self.peopleAttended, forKey: .peopleAttended)
        try container.encodeIfPresent(self.rules, forKey: .rules)
    }
    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.title, forKey: .title)
//        try container.encode(self.description, forKey: .description)
//        try container.encode(self.peopleAttended, forKey: .peopleAttended)
//        try container.encode(self.rules, forKey: .rules)
//    }
  
}
