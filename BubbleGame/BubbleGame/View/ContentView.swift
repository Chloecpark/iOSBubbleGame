//
//  ContentView.swift
//  BubbleGame
//
//  Created by Chohwi Park on 5/4/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                //game title
                Label("Bubble Pop", systemImage: "")
                    .foregroundColor(.mint)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Text("😆")
                    .font(.system(size: 100))
                Spacer()
                
                //NavigationLink to SettingView and HighScoreView
                NavigationLink(destination: SettingView(), label: {Text("New Game")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                })
                .padding(50)
                NavigationLink(destination: HighScoreView(playerName: "", score: 0), label: {Text("High Score")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                })
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
