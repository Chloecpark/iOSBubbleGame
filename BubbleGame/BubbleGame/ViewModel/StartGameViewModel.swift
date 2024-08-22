//
//  StartGameViewModel.swift
//  BubbleGame
//
//  Created by Chohwi Park on 13/4/2024.
//

import Foundation
import SwiftUI

class StartGameViewModel: ObservableObject {
    @Published var bubbles: [Bubble] = []
    @Published var score: Int = 0
    @Published var countdownInSeconds: Int
    @Published var isGameActive = false
    @Published var isGameFinished = false
    @Published var highestScore: Int = 0
    private var screenSize: CGSize
    private var numberOfBubbles: Int
    private var lastPoppedColor: UIColor?
    private var consecutivePops: Int = 0
    private var gameTimer: Timer?
    
    //initialiser
    init(screenSize: CGSize, numberOfBubbles: Int, countdownValue: Int) {
        self.screenSize = screenSize
        self.numberOfBubbles = numberOfBubbles
        self.countdownInSeconds = countdownValue
        loadInitialBubbles()
    }
    
    //starts the game
    func startGame() {
        loadPlayerScores()
        isGameActive = true
        startTimer()
    }
    
    //load initial bubbles with random number of bubbles
    func loadInitialBubbles() {
        bubbles.removeAll()
        if numberOfBubbles == 0 {
            clearScreen()
        } else {
            let initialCount = Int.random(in: 1...numberOfBubbles)
            for _ in 0..<initialCount {
                addBubble()
            }
        }
    }
    
    //add new bubbles
    func addBubble() {
        if bubbles.count < numberOfBubbles { // only add a new bubble if below max count
            let colorAndScore = BubbleColors.randomColorAndScore()
            let size: CGFloat = 50
            var position: CGPoint
            var attempts = 0
            repeat {
                position = CGPoint( //prevents bubbles generated out of screen
                    x: CGFloat.random(in: size..<screenSize.width - size),
                    y: CGFloat.random(in: size..<screenSize.width - size)
                )
                let newBubble = Bubble(position: position, size: size, color: colorAndScore.color, score: colorAndScore.score)
                if !isOverlapping(newBubble: newBubble) { //prevent bubbles are overlapping
                    bubbles.append(newBubble)
                    break
                }
                attempts += 1
            } while attempts < 100
        }
    }

    //check if the bubble overlaps with others
    func isOverlapping(newBubble: Bubble) -> Bool {
        for bubble in bubbles {
            let distance = sqrt(pow(bubble.position.x - newBubble.position.x, 2) + pow(bubble.position.y - newBubble.position.y, 2))
            if distance < (bubble.size + newBubble.size) / 2 {
                return true
            }
        }
        return false
    }
    
    //pop bubble and scoring
    func popBubble(bubbleID: UUID) {
        guard let index = bubbles.firstIndex(where: { $0.id == bubbleID }), isGameActive else { return }
        let poppedBubble = bubbles[index]
        score += calculateScore(bubble: poppedBubble) //scoring function
        bubbles.remove(at: index)
        if Int.random(in: 1...100) <= 80 || bubbles.isEmpty { // 80% chance to add a new bubble or add when isEmpty
            addBubble()
        }
    }

    //calculate score with bonuses
    func calculateScore(bubble: Bubble) -> Int {
        let bonusScore = (lastPoppedColor == bubble.color) ? 1.5 : 1.0
        lastPoppedColor = bubble.color
        consecutivePops = bonusScore > 1.0 ? consecutivePops + 1 : 1
        return Int(round(Double(bubble.score) * bonusScore)) //get bonus score if the same colour is popped consecutively
    }

    //ends the game and clears the screen
    func endGame() {
        isGameActive = false
        isGameFinished = true
        stopCountdown()
        clearScreen()
    }
    
    //starts the timer
    func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.onCountDown()
        }
    }
    
    //countdown every second
    func onCountDown() {
        if countdownInSeconds > 0 && isGameActive {
            countdownInSeconds -= 1
        } else if isGameActive {
            endGame()
        }
    }
    
    //stopts the timer
    func stopCountdown() {
        gameTimer?.invalidate()
        gameTimer = nil
        countdownInSeconds = 0
    }
    
    //resets the game
    func resetGame(screenSize: CGSize, numberOfBubbles: Int, countdownValue: Int) {
        self.screenSize = screenSize
        self.numberOfBubbles = numberOfBubbles
        self.countdownInSeconds = countdownValue
        score = 0
        lastPoppedColor = nil
        consecutivePops = 0
        isGameActive = true
        isGameFinished = false
        loadInitialBubbles()
    }
    
    //clears all bubbles
    func clearScreen() {
        bubbles.removeAll()
    }
    
    //loads the highest score
    func loadPlayerScores(){
        if let data = UserDefaults.standard.data(forKey: "PlayerScores") {
            let decoder = JSONDecoder()
            if let playerScores = try? decoder.decode([PlayerScore].self, from: data) {
                highestScore = playerScores.map { $0.score }.max() ?? 0
            }
        }
    }
}

//define bubbles' colours and possibilities, and corresponding scores
enum BubbleColors {
    static func randomColorAndScore() -> (color: UIColor, score: Int) {
        let colorProbabilities: [(UIColor, Int, Double)] = [
            (.red, 1, 0.40),
            (.systemPink, 2, 0.30),
            (.green, 5, 0.15),
            (.blue, 8, 0.10),
            (.black, 10, 0.05)
        ]
        let totalProbability = colorProbabilities.map { $0.2 }.reduce(0, +)
        var random = Double.random(in: 0..<totalProbability)
        for (color, score, probability) in colorProbabilities {
            random -= probability
            if random <= 0 {
                return (color, score)
            }
        }
        return (.red, 1)
    }
}
