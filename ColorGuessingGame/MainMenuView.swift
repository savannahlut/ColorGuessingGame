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
