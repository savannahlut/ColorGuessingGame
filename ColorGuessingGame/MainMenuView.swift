//
//  MainMenuView.swift
//  ColorGuessingGame
//
//  Created by Student on 5/4/26.
//

import SwiftUI
import UIKit
import Combine

struct MainMenuView: View {
    @EnvironmentObject var scoreModel: ScoreModel
    @State private var selectedDifficulty: String = "Easy"
    @State private var shouldNavigate = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to the Color Guessing Game")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Score: \(scoreModel.score)")
                    .font(.title2)
                
                Menu {
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        Text("Easy").tag("Easy")
                        Text("Medium").tag("Medium")
                        Text("Hard").tag("Hard")
                    }
                } label: {
                    Label(
                        title: { Text(selectedDifficulty) },
                        icon: { Image(systemName: "chevron.down") }
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }

                NavigationLink {
                    ContentView(difficulty: selectedDifficulty)
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

#Preview{
    MainMenuView()
        .environmentObject(ScoreModel())
}
