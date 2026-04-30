//
//  ContentView.swift
//  ColorGuessingGame
//
//  Created by Student on 4/29/26.
//

import SwiftUI
import UIKit
internal import Combine

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
    
    @StateObject private var viewModel = ColorViewModel()
    
    @State private var selectedColor: Color = .orange
    @State private var hexValue: String = "#FFA500"
    
    @State private var customBaseColor: Color = .blue
    @State private var tolerance: Double = 20
    @State private var customText: String = ""
    
    var body: some View {
        
        ZStack {
            dynamicBackground(for: selectedColor)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: selectedColor)
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    Text("Pick a Color")
                        .font(.largeTitle)
                        .bold()
                    
                    ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                        .labelsHidden()
                        .scaleEffect(1.6)
                        .onChange(of: selectedColor) { newColor in
                            hexValue = newColor.toHex() ?? "#000000"
                        }
                    
                    Text("HEX: \(hexValue)")
                        .font(.headline)
                    
                    Text(displayText())
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(selectedColor)
                        .padding()
                        .id(displayText())
                        .contentTransition(.opacity)
                        .animation(.easeInOut, value: displayText())
                    
                    Divider()
                        .overlay(selectedColor)
                    
                    Text("Create New Association")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.primary)
                    
                    ColorPicker("Base Color", selection: $customBaseColor)
                    
                    VStack {
                        Text("Hue Range ±\(Int(tolerance))°")
                            .foregroundStyle(Color.primary)
                        Slider(value: $tolerance, in: 5...60, step: 1)
                    }
                    
                    TextField("Enter a meaning...", text: $customText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Save Association") {
                        withAnimation {
                            viewModel.addAssociation(
                                baseHue: customBaseColor.hueDegrees(),
                                tolerance: tolerance,
                                text: customText
                            )
                            customText = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(Color.primary)
                    .tint(selectedColor)
                    
                    Divider()
                        .overlay(selectedColor)
                    
                    Text("Saved Associations")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    
                    ForEach(viewModel.associations) { association in
                        AssociationRow(
                            association: association,
                            selectedHue: selectedColor.hueDegrees()
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .onDelete(perform: viewModel.delete)
                    
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

extension ContentView {
    func displayText() -> String {
        
        let selectedHue = selectedColor.hueDegrees()
        
        for association in viewModel.associations {
            if abs(angleDifference(selectedHue, association.baseHue)) <= association.tolerance {
                return "★ \(association.text) ★"
            }
        }
        return defaultDescription(for: selectedHue)
    }
    
    func defaultDescription(for degrees: Double) -> String {
        //surprisingly difficult to switch colors with if else --> used switch case
        switch degrees {
        case 0..<15, 345...360:
            return "Red, Passion"
        case 15..<45:
            return "Orange, Warmth"
        case 45..<70:
            return "Yellow, Happiness"
        case 70..<160:
            return "Green, Growth, Plants"
        case 160..<250:
            return "Blue, Calm, Water"
        case 250..<290:
            return "Purple, Mystery, Royalty"
        case 290..<345:
            return "Pink, Love"
        default:
            return "?"
        }
    }
    
    func angleDifference(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return min(diff, 360 - diff)
    }
}

//separated background logic
extension ContentView {
    
    func dynamicBackground(for color: Color) -> Color {
        let brightness = color.brightnessValue()
        
        if brightness < 0.3 {
            return color.opacity(0.85)
        } else if brightness > 0.75 {
            return color.opacity(0.25)
        } else {
            return color.opacity(0.6)
        }
    }
}

//credits to my uncle for this part >>>
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
    ContentView()
}
