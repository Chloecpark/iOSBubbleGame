//
//  PlayerScoreModel.swift
//  BubbleGame
//
//  Created by Chohwi Park on 9/4/2024.
//

import Foundation

//define the playerscore model
struct PlayerScore: Identifiable, Codable, Hashable {
    var id = UUID()
    let playerName: String
    var score: Int
}
