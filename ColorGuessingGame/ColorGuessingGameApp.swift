//
//  ColorGuessingGameApp.swift
//  ColorGuessingGame
//
//  Created by Student on 4/29/26.
//

import SwiftUI

@main
struct ColorGuessingGameApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
            Text("Welcome to the Color guessing game!")
        }
    }
}

#Preview{
    MainMenuView()
        .environmentObject(ScoreModel())
}

