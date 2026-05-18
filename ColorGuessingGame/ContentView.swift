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
    
    @State private var rInput: String = ""
    @State private var gInput: String = ""
    @State private var bInput: String = ""

    @State private var rGuess: Int? = nil
    @State private var gGuess: Int? = nil
    @State private var bGuess: Int? = nil
    
    @State private var rTarget: Int = Int.random(in: 0...255)
    @State private var gTarget: Int = Int.random(in: 0...255)
    @State private var bTarget: Int = Int.random(in: 0...255)

    @State private var guessAccuracy: Int? = nil

    @State private var guessesRemaining: Int = 3
    @State private var guessCorrect: Bool = false
    
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

                    // Target color square
                    Rectangle()
                        .fill(Color(red: Double(rTarget)/255.0,
                                    green: Double(gTarget)/255.0,
                                    blue: Double(bTarget)/255.0))
                        .frame(width: 180, height: 180)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                    
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
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("R")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("0-255", text: $rInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 100)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("G")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("0-255", text: $gInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 100)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("B")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("0-255", text: $bInput)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 100)
                        }
                    }

                    Button("Enter a guess") {
                        let r = Int(rInput.trimmingCharacters(in: .whitespacesAndNewlines))
                        let g = Int(gInput.trimmingCharacters(in: .whitespacesAndNewlines))
                        let b = Int(bInput.trimmingCharacters(in: .whitespacesAndNewlines))

                        func clamped(_ value: Int?) -> Int? {
                            guard let v = value else { return nil }
                            return max(0, min(255, v))
                        }

                        rGuess = clamped(r)
                        gGuess = clamped(g)
                        bGuess = clamped(b)

                        // Compute accuracy if we have a full guess
                        if let rGuess, let gGuess, let bGuess {
                            let rAcc = max(0, 100 - abs(rGuess - rTarget))
                            let gAcc = max(0, 100 - abs(gGuess - gTarget))
                            let bAcc = max(0, 100 - abs(bGuess - bTarget))
                            // Average the three channel accuracies
                            let avg = (rAcc + gAcc + bAcc) / 3
                            guessAccuracy = avg
                        } else {
                            guessAccuracy = nil
                        }

                        if guessesRemaining > 0 {
                            guessesRemaining -= 1
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    if let rGuess, let gGuess, let bGuess {
                        Text("Stored guess: R=\(rGuess) G=\(gGuess) B=\(bGuess)")
                            .font(.subheadline)
                    }

                    Text("Number of guesses: \(guessesRemaining)")
                        .font(.headline)
                        .padding(.top, 4)

                    if let guessAccuracy {
                        Text("Accuracy: \(guessAccuracy)%")
                            .font(.title3)
                            .bold()
                    }
                    
                    if guessesRemaining == 0 {
                        Button("New Color") {
                            rTarget = Int.random(in: 0...255)
                            gTarget = Int.random(in: 0...255)
                            bTarget = Int.random(in: 0...255)
                            guessesRemaining = 3
                            guessAccuracy = nil
                            rInput = ""
                            gInput = ""
                            bInput = ""
                        }
                    }
                    
                    Divider()
                        .overlay(selectedColor)
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

