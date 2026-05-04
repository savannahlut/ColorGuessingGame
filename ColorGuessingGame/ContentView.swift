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

//Main Menu View

struct MainMenuView: View {
    @EnvironmentObject var scoreModel: ScoreModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to the Color Guessing Game")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Score: \(scoreModel.score)")
                    .font(.title2)

                NavigationLink {
                    ContentView()
                        .environmentObject(scoreModel)
                } label: {
                    Text("Play")
                        .font(.title2)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
        }
    }
}

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

//Main View

struct ContentView: View {
    @EnvironmentObject private var scoreModel: ScoreModel
    @StateObject private var viewModel = ColorViewModel()
    @State private var selectedColor: Color = .orange
    @State private var hexValue: String = "#FFA500"
    
    @State private var customBaseColor: Color = .blue
    @State private var tolerance: Double = 20
    @State private var customText: String = ""
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    Text("Guess The Color")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    
                    ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                        .labelsHidden()
                        .scaleEffect(5)
                        .onChange(of: selectedColor) { newColor in
                            hexValue = newColor.toHex() ?? "#000000"
                        }
                    
                    Spacer()

                    Text("HEX: \(hexValue)")
                        .font(.headline)
                    
                    Divider()
                        .overlay(selectedColor)
                    
                    TextField("Enter a guess...", text: $customText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
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
    MainMenuView()
        .environmentObject(ScoreModel())
}

