//
//  ColorViewModel.swift
//  ColorGuessingGame
//
//  Created by Student on 5/4/26.
//

import SwiftUI
import UIKit
import Combine

class ColorViewModel: ObservableObject {
    @Published var associations: [ColorAssociation] = [] {
        didSet { saveAssociations() }
    }

    private let key = "savedColorAssociations"

    init() { loadAssociations() }

    func addAssociation(baseHue: Double, tolerance: Double, text: String) {
        let new = ColorAssociation(baseHue: baseHue,
                                   tolerance: tolerance,
                                   text: text)
        associations.append(new)
    }

    func delete(at offsets: IndexSet) {
        associations.remove(atOffsets: offsets)
    }

    private func saveAssociations() {
        if let encoded = try? JSONEncoder().encode(associations) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func loadAssociations() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ColorAssociation].self, from: data) {
            associations = decoded
        }
    }
}
