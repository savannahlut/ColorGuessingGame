//
//  DataModels.swift
//  ColorGuessingGame
//
//  Created by Student on 4/29/26.
//

import SwiftUI
import Foundation

struct ColorResponse: Codable {
    var images: [Images]
}

struct Images: Codable {
    var bar: String
    var named: String
}
