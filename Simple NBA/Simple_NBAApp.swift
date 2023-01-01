//
//  Simple_NBAApp.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 02/11/2022.
//


import SwiftUI

@main
struct Simple_NBAApp: App {
    @StateObject private var scoreData = DayGames(preview: false)
    
    var body: some Scene {
        WindowGroup {
            AppMainView()
                .environmentObject(scoreData)
        }
    }
}
