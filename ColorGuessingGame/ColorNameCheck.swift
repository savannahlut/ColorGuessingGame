//
//  ColorNameCheck.swift
//  ColorGuessingGame
//
//  Created by Student on 5/8/26.
//

import UIKit
import SwiftUI

enum ColorNameError: Error {
    case invalidURL
    case networkError(underlying: Error)
    case invalidResponse
    case noColorFound
}

struct ColorNameCheck {
    static func color(for name: String) async throws -> UIColor {
        guard let encoded = name.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.thecolorapi.com/name?name=\(encoded)") else {
            throw ColorNameError.invalidURL
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw ColorNameError.networkError(underlying: error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ColorNameError.invalidResponse
        }
        
        print("HTTP Status Code: \(httpResponse.statusCode)")
        
        struct NameResponse: Decodable {
            let hex: Hex
            struct Hex: Decodable {
                let value: String
            }
        }
        
        let nameResponse: NameResponse
        do {
            nameResponse = try JSONDecoder().decode(NameResponse.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
        
        guard let color = UIColor(hex: nameResponse.hex.value) else {
            throw ColorNameError.noColorFound
        }
        
        return color
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6 else { return nil }
        var rgb: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&rgb) else { return nil }
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    func toHex() -> String? {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            
            if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
                let rgb = (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
                return String(format: "#%06X", rgb)
            }
            
            var convertedColor = self
            if let rgbColor = self.cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!,
                                                      intent: .defaultIntent,
                                                      options: nil) {
                convertedColor = UIColor(cgColor: rgbColor)
                if convertedColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
                    let rgb = (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
                    return String(format: "#%06X", rgb)
                }
            }
            
            return nil
        }
}
