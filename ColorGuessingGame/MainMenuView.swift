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
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to the Color Guessing Game")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                
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

                NavigationLink(isActive: $shouldNavigate) {
                    ContentView(difficulty: selectedDifficulty)
                        .environmentObject(scoreModel)
                } label: {
                    EmptyView()
                }
                .hidden()

                ZStack {
                    Capsule()
                        .fill(Color.blue)
                        .frame(height: 48)
                        .overlay(
                            Text("Swipe right to Play")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.85))
                        )

                    GeometryReader { geo in
                        let width = geo.size.width
                        let knobSize: CGFloat = 44
                        let maxRightTravel = width/2 - knobSize/2

                        Circle()
                            .fill(Color.white)
                            .frame(width: knobSize, height: knobSize)
                            .shadow(radius: 2)
                            .offset(x: dragOffset)
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.blue)
                            )
                            .gesture(
                                DragGesture(minimumDistance: 5)
                                    .onChanged { value in

                                        let x = max(0, value.translation.width)
                                        dragOffset = min(maxRightTravel, x)
                                    }
                                    .onEnded { value in

                                        if value.translation.width > 80 {
                                            shouldNavigate = true
                                            dragOffset = 0
                                        } else {

                                            withAnimation(.spring()) {
                                                dragOffset = 0
                                            }
                                        }
                                    }
                            )
                    }
                    .padding(.horizontal, 4)
                }
                .frame(height: 48)
                .clipShape(Capsule())
                .accessibilityLabel("Swipe right to start the game")
                .accessibilityHint("Drag the white circle to the right to play")
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.yellow)
        }
    }
}

#Preview{
    MainMenuView()
        .environmentObject(ScoreModel())
}
