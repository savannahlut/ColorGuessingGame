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
    
    @State private var currentTask: Task<Void, Never>?
    
    @State private var currentInput: String = ""
    @State private var submittedText: String = ""
    
    @State private var testHex = "#FFFFFF"
    
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
                    
                    Divider()
                        .overlay(selectedColor)
                    
                    TextField("Enter a guess...", text: $currentInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            submittedText = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    
                    Text(submittedText)
                    
                    Text(testHex)
                    
                    Divider()
                        .overlay(selectedColor)
                }
                .padding()
            }
        }
        .onChange(of: submittedText) { newValue in
                    guard !newValue.isEmpty else { return }
                    
                    currentTask?.cancel()
                    
                    currentTask = Task {
                        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        do {
                            let color = try await ColorNameCheck.color(for: trimmed)
                            
                            await MainActor.run {
                                testHex = color.toHex() ?? "No hex"
                            }
                        } catch {
                            await MainActor.run {
                                testHex = "Error: \(error.localizedDescription)"
                            }
                        }
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

