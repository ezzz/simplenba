//
//  AppMainView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 27/11/2022.
//

import SwiftUI

struct AppMainView: View {
    @EnvironmentObject var scoreData: DayGames

    var body: some View {
        TabView {
            ScoreboardV3View()
                .environmentObject(scoreData)
                .tabItem {
                    Label("Recent", systemImage: "clock.circle")
                }
            Text("TBD...")
                .tabItem {
                    Label("Schedule", systemImage: "calendar.circle")
                }
            Text("TBD...")
                .tabItem {
                    Label("Standings", systemImage: "list.bullet.circle")
                }
            Text("TBD...")
                .tabItem {
                    Label("Settings", systemImage: "gear.circle")
                }
        }
    }
}

struct AppMainView_Previews: PreviewProvider {
    static var previews: some View {
        AppMainView()
            .environmentObject(DayGames(preview: false))
    }
}
