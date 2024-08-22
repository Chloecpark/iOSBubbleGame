//
//  HighScoreView.swift
//  BubbleGame
//
//  Created by Chohwi Park on 5/4/2024.
//

import SwiftUI

struct HighScoreView: View {
    @State private var playerScores: [PlayerScore] = []
    var playerName: String
    var score: Int
    
    var body: some View {
        VStack {
            Label("High Score", systemImage: "list.number")
                .foregroundColor(.mint)
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            
            // List top 10 player scores
            List(playerScores.sorted(by: {$0.score > $1.score}).prefix(10)) { playerScore in
                HStack {
                    Text(playerScore.playerName)
                        .font(.title3)
                        .foregroundColor(.mint)
                    Spacer()
                    Text("\(playerScore.score)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding(5)
            }
        }
        .onAppear{
            loadPlayerScores() // Load scores when view appears
            savePlayerScore() // Save the current player's score
        }
    }
    
    // Load scores
    private func loadPlayerScores() {
        if let data = UserDefaults.standard.data(forKey: "PlayerScores") {
            let decoder = JSONDecoder()
            if let decodedPlayerScores = try? decoder.decode([PlayerScore].self, from: data) {
                playerScores = decodedPlayerScores
            }
        }
    }
    
    // Save current player's score
    private func savePlayerScore() {
        let newPlayerScore = PlayerScore(playerName: playerName, score: score)
        playerScores.append(newPlayerScore)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(playerScores) {
            UserDefaults.standard.set(encoded, forKey: "PlayerScores")
        }
    }
}

#Preview {
    HighScoreView(playerName: "", score: 0)
}
