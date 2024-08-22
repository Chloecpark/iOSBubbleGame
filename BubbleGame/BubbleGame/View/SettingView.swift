//
//  SettingView.swift
//  BubbleGame
//
//  Created by Chohwi Park on 5/4/2024.
//

import SwiftUI

struct SettingView: View {
    @StateObject var settingViewModel = SettingViewModel()
    @State private var countdownValue: Double = 60
    @State private var numberOfBubbles: Double = 15
    
    var body: some View {
            VStack {
                Spacer()
                Label("Settings", systemImage: "")
                    .foregroundColor(.blue)
                    .font(.largeTitle)
                Spacer()
                
                //user enters playerName
                Text("Enter Name")
                    .font(.title2)
                TextField("Enter Name", text: $settingViewModel.playerName)
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
                
                //user adjusts the game time
                Text("Game Time: \(Int(countdownValue))")
                    .font(.title2)
                Slider(value: $countdownValue, in: 0...60, step: 1)
                    .padding()
                
                //user adjusts the max number of bubbles
                Text("Max number of Bubbles: \(Int(numberOfBubbles))")
                    .font(.title2)
                Slider(value: $numberOfBubbles, in: 0...15, step: 1)
                    .padding()
                Spacer()
                
                //NavigationLink to StartGameView
                NavigationLink(destination: StartGameView(playerName: settingViewModel.playerName, countdownValue: Int(countdownValue), numberOfBubbles: Int(numberOfBubbles))) {
                    Text("Start Game")
                        .font(.title)
                        .padding()
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                Spacer()
            }
            .padding()
            .onDisappear {
                //save the settings
                UserDefaults.standard.set(settingViewModel.playerName, forKey: "Player Name")
                UserDefaults.standard.set(countdownValue, forKey: "Countdown Value")
                UserDefaults.standard.set(numberOfBubbles, forKey: "Number of Bubbles")
            }
        }
}

#Preview {
    SettingView()
}
