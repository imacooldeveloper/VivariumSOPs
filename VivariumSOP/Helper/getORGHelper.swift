//
//  getORGHelper.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/21/25.
//

import SwiftUI

extension View {
    func getOrganizationId() -> String? {
        return UserDefaults.standard.string(forKey: "organizationId")
    }
}
