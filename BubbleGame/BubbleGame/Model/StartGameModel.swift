//
//  BubbleModel.swift
//  BubbleGame
//
//  Created by Chohwi Park on 13/4/2024.
//

import Foundation
import UIKit

//define a model for a bubble in the game
struct Bubble: Identifiable {
    var id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: UIColor
    var score: Int
    
}
