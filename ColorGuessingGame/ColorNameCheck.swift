//
//  ColorNameCheck.swift
//  ColorGuessingGame
//
//  Created by Student on 5/8/26.
//

import UIKit
import SwiftUI

func isWithinMargin(difficulty: String,
                    guessR: Int, guessG: Int, guessB: Int,
                    targetR: Int, targetG: Int, targetB: Int) -> Bool {
    
    let percentage: Double
    switch difficulty.lowercased() {
    case "easy":
        percentage = 0.20
    case "medium":
        percentage = 0.10
    case "hard":
        percentage = 0.05
    default:
        fatalError("Difficulty must be 'easy', 'medium', or 'hard'")
    }
    
    let tolerance = Int(percentage * 255.0)
    
    let rDiff = abs(guessR - targetR)
    let gDiff = abs(guessG - targetG)
    let bDiff = abs(guessB - targetB)
    
    return rDiff <= tolerance && gDiff <= tolerance && bDiff <= tolerance
}
