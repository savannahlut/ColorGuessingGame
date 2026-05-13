//
//  DataModels.swift
//  ColorGuessingGame
//
//  Created by Student on 4/29/26.
//

import SwiftUI
import Foundation

struct ColorResponse: Decodable {
    var images: [Images]
    let hex: Hex
    struct Hex: Decodable { let value: String }
}

struct Images: Codable {
    var bar: String
    var named: String
}
