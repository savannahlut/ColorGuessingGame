//
//  ContentView.swift
//  ColorGuessingGame
//
//  Created by Student on 4/29/26.
//

import SwiftUI
import UIKit
import Combine

final class ScoreModel: ObservableObject {
    @Published var score: Int = 0
}

struct StoredColor: Identifiable, Codable {
    let id = UUID()
    let red: Double
    let green: Double
    let blue: Double
    let hex: String
}

//Main View

struct ContentView: View {
    @EnvironmentObject private var scoreModel: ScoreModel
    @StateObject private var viewModel = ColorViewModel()
    @State private var selectedColor: Color = .orange
    @State private var hexValue: String = "#FFA500"
    @State private var storedColors: [StoredColor] = []
    
    @State private var customBaseColor: Color = .blue
    @State private var tolerance: Double = 20
    @State private var customText: String = ""
    
    let difficulty: String
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    Text("Guess The Color")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 8)

                    Spacer()
                    
                    ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                        .labelsHidden()
                        .scaleEffect(5)
                        .padding(.vertical, 12)
                        .onChange(of: selectedColor) { newColor in
                            hexValue = newColor.toHex() ?? "#000000"
                        }
                    
                    Spacer()

                    Text("HEX: \(hexValue)")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    Button("Guess") {
                        let ui = UIColor(selectedColor)
                        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
                        let entry = StoredColor(
                            red: Double(r),
                            green: Double(g),
                            blue: Double(b),
                            hex: hexValue
                        )
                        storedColors.append(entry)
                    }
                    .buttonStyle(.borderedProminent)

                    Divider()

                    if storedColors.isEmpty {
                        Text("No guesses yet. Tap Guess to store the current color.")
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Guesses")
                                .font(.headline)

                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(storedColors) { item in
                                        HStack(spacing: 12) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(red: item.red, green: item.green, blue: item.blue))
                                                .frame(width: 44, height: 44)
                                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.4)))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.hex)
                                                    .font(.headline)
                                                Text(String(format: "R: %.0f  G: %.0f  B: %.0f",
                                                            item.red * 255, item.green * 255, item.blue * 255))
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                        }
                                        .padding(8)
                                        .background(.thinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 100)
                        }
                    }
                }
                .padding()
            }
        }
    }
}


struct AssociationRow: View {
    
    let association: ColorAssociation
    let selectedHue: Double
    
    var body: some View {
        
        let m = abs(angleDifference(selectedHue, association.baseHue)) <= association.tolerance
        
        return HStack {
            Text(association.text)
                .foregroundStyle(Color.primary)
            Spacer()
            Text("±\(Int(association.tolerance))°")
                .font(.caption)
                .foregroundStyle(Color.primary)
        }
        .padding()
        .background(m ? Color.white.opacity(0.3) : Color.clear)
        .cornerRadius(12)
        .animation(.easeInOut, value: m)
    }
    
    func angleDifference(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return min(diff, 360 - diff)
    }
}


extension Color {
    func toHex() -> String? {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components.count >= 3 ? components[1] : components[0])
        let b = Float(components.count >= 3 ? components[2] : components[0])
        
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }
    
    func hueDegrees() -> Double {
        let uiColor = UIColor(self)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Double(h * 360)
    }
    
    func brightnessValue() -> Double {
        let uiColor = UIColor(self)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Double(b)
    }
}

#Preview{
    ContentView(difficulty: "Medium")
        .environmentObject(ScoreModel())
}

