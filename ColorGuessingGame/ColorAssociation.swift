//
//  ColorAssociation.swift
//  ColorGuessingGame
//
//  Created by Student on 4/30/26.
//
import SwiftUI
import UIKit

struct ColorAssociation: Identifiable, Codable {
    var id = UUID()
    //UUID!
    var baseHue: Double
    var tolerance: Double
    var text: String
}
