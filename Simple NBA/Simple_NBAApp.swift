//
//  Simple_NBAApp.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 02/11/2022.
//


import SwiftUI

@main
struct Simple_NBAApp: App {
    var body: some Scene {
        WindowGroup {
            ScoreboardV2View(dayGames: DayGames(preview: false))
        }
    }
}
