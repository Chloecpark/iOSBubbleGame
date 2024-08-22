//
//  StartGameView.swift
//  BubbleGame
//
//  Created by Chohwi Park on 5/4/2024.
//

import SwiftUI

struct StartGameView: View {
    @ObservedObject var startGameViewModel: StartGameViewModel
    var playerName: String
    var countdownValue: Int
    var numberOfBubbles: Int
    @State private var preGameCountdown = 3 //countdown before game
    @State private var showPreCountdown = true
    @State private var shakeScore = 0 //for the shaking animation
    
    init(playerName: String, countdownValue: Int, numberOfBubbles: Int) {
        self.playerName = playerName
        self.countdownValue = countdownValue
        self.numberOfBubbles = numberOfBubbles
        self.startGameViewModel = StartGameViewModel(screenSize: UIScreen.main.bounds.size, numberOfBubbles: numberOfBubbles, countdownValue: countdownValue)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    gameHeader
                    gameStats
                    gameArea
                }
                .padding()
                .blur(radius: preGameCountdown > 0 ? 3 : 0) //blur before game starts
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    startGameViewModel.onCountDown() //timer during the game
                }
    
                // precountdown before game starts
                if preGameCountdown > 0 {
                    Text("\(preGameCountdown)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .opacity(showPreCountdown ? 1 : 0)
                        .animation(.easeIn(duration: 0.5), value: showPreCountdown)
                } else if preGameCountdown == 0 {
                    Text("GO!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .opacity(showPreCountdown ? 1 : 0)
                        .animation(.easeIn(duration: 0.5), value: showPreCountdown)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    self.showPreCountdown = false
                                }
                                startGameViewModel.startGame()
                            }
                        }
                }
            }
            //HighScoreView sheet after the game finished
            .sheet(isPresented: $startGameViewModel.isGameFinished) {
                HighScoreView(playerName: playerName, score: startGameViewModel.score)
                    //.environmentObject(HighScoreViewModel())
            }
            .onAppear {
                startGameViewModel.resetGame(screenSize: geometry.size, numberOfBubbles: numberOfBubbles, countdownValue: countdownValue)
                startPreGameCountdown()
            }
            .onDisappear {
                startGameViewModel.endGame()
            }
        }
    }

    //gameHeader view (the game title and a exit button)
    var gameHeader: some View {
        HStack {
            Spacer()
            Label("Bubble Game", systemImage: "gamecontroller.fill")
                .foregroundColor(.mint)
                .font(.title)
                .padding()
            Spacer()
            
            Button(action: {
                startGameViewModel.endGame()
                startGameViewModel.stopCountdown()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
            Spacer()
        }
    }

    //gameStats view (timer, score, and the highest score)
    var gameStats: some View {
        HStack {
            Spacer()
            Text("Timer \n\(startGameViewModel.countdownInSeconds)")
                .padding()
                .multilineTextAlignment(.center)
            
            Text("Score \n\(startGameViewModel.score)")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
                .multilineTextAlignment(.center)
                .modifier(ShakeEffect(shakes: shakeScore))
                .onChange(of: startGameViewModel.score) { newValue in //animation effect
                    withAnimation(.default) {
                        shakeScore = 6
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        shakeScore = 0 // Reset shakes to stop the effect
                    }
                }
            
            Text("High Score \n\(startGameViewModel.highestScore)")
                .padding()
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    //gameArea view (the bubble game)
    var gameArea: some View {
        ZStack {
            ForEach(startGameViewModel.bubbles, id: \.id) { bubble in
                Button(action: { //generate bubbles as buttons
                    startGameViewModel.popBubble(bubbleID: bubble.id)
                }) {
                    Circle()
                        .foregroundColor(Color(uiColor: bubble.color))
                        .frame(width: bubble.size, height: bubble.size)
                }
                .position(bubble.position)
                .disabled(preGameCountdown > 0)  // Disable the button during the countdown
            }
        }
    }
    
    //start pre-game countdown
    func startPreGameCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.preGameCountdown > 0 {
                withAnimation {
                    self.showPreCountdown.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.showPreCountdown.toggle()
                        self.preGameCountdown -= 1
                    }
                }
            } else {
                timer.invalidate()
            }
        }
    }

    //shake effect for the score
    struct ShakeEffect: GeometryEffect {
        var amount: CGFloat = 10
        var shakesPerUnit: Double = 3
        var shakes: Int
        var animatableData: CGFloat {
            get { CGFloat(shakes) }
            set { shakes = Int(newValue) }
        }
        
        func effectValue(size: CGSize) -> ProjectionTransform {
            let translationX = amount * sin(CGFloat(shakes) * .pi / shakesPerUnit)
            let translationY = amount * cos(CGFloat(shakes) * .pi / shakesPerUnit)
            return ProjectionTransform(CGAffineTransform(translationX: translationX, y: translationY))
        }
    }
    
    #Preview {
        StartGameView(playerName: "", countdownValue: 0, numberOfBubbles: 0)
    }
}
