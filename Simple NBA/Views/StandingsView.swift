//
//  StandingsView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 02/12/2022.
//

import SwiftUI

struct StandingsView: View {
    @EnvironmentObject var standings: Standings
    
    @Environment(\.colorScheme) var colorScheme
    @State var conference = 0 // 0 for Western
    @State private var simpleStandings = false
        
    var body: some View {
        LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
            Section(header: StandingsHeaderView()) {
                
                VStack {
                    
                    HStack {
                        Spacer()
                        Toggle("Advanced statistics", isOn: $simpleStandings)
                            .frame(width: 230, height:  45)
                            .padding(.trailing)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    
                    if standings.standings.isLoaded {
                        Picker("What is your favorite color?", selection: $conference) {
                            Text("West").tag(0)
                            Text("East").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        HStack {
                                StandingsTeamView(standings: standings, conference: $conference)
                            
                                    .frame(width: 150, height: 500)
                            
                            ScrollView(.horizontal) {
                                StandingsStatsView(standings: standings, conference: $conference)
                            }
                        }
                        
                    }
                    else {
                        Text("Loading standings...")
                    }
                }
            }
        }
    }
    
    func StandingsHeaderView() -> some View {
        
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 5) {
                Text("Standings")
                    .font(.largeTitle.bold())
                Spacer()
                /*
                Image("logo-nba")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height:  45)
                    .padding(.trailing)
                 */
                /*Toggle("Hide scores", isOn: $hideScores)
                    .frame(width: 150, height:  45)
                    .padding(.trailing)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))*/
            }
            .hLeading()
        }
    }

}

struct StandingsTeamView: View {
    var standings: Standings
    @Binding var conference : Int // 0 for Western

    @Environment(\.colorScheme) var colorScheme
    //let headerTitles = ["", "Team", "Win - Loss", "GB", "L10", "Streak"]
    let headerTitles = ["", "Team"]

    var body: some View {
        Grid(alignment: .topLeading,
             horizontalSpacing: 1,
             verticalSpacing: 0) {
            GridRow {
                ForEach(headerTitles, id:\.self) {
                    Text($0)
                        .bold()
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(minWidth: 10, maxWidth: .infinity, minHeight: 40)
                        .background(Color("boxHeader"))
                }
            }
            
            Grid(alignment: .topLeading,
                 horizontalSpacing: 5,
                 verticalSpacing: 5) {
                ForEach(conference == 0 ? standings.standings.westConferenceStandings : standings.standings.eastConferenceStandings) { team in
                    GridRow {
                        StandingCell(value: team.leagueRank, width: 30)
                        StandingCell(value: team.name, width: 70)
                    }
                }
            }
        }
        //.background(colorScheme == .light ? Color(hue: 1.0, saturation: 0.0, brightness: 0.95) : Color(hue: 1.0, saturation: 0.0, brightness: (0.0)))
    }
}

struct StandingsStatsView: View {
    var standings: Standings
    @Binding var conference : Int // 0 for Western

    @Environment(\.colorScheme) var colorScheme
    let headerTitles = ["Record", "GB", "L10", "Streak"]

    var body: some View {
        Grid(alignment: .topLeading,
             horizontalSpacing: 1,
             verticalSpacing: 0) {

            GridRow {
                ForEach(headerTitles, id:\.self) {
                    Text($0)
                        .bold()
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(minWidth: 30, maxWidth: .infinity, minHeight: 40)
                        .background(Color("boxHeader"))
                }
            }
            
            Grid(alignment: .topLeading,
                 horizontalSpacing: 5,
                 verticalSpacing: 5) {
                ForEach(conference == 0 ? standings.standings.westConferenceStandings : standings.standings.eastConferenceStandings) { team in
                    GridRow {
                        StandingCell(value: team.record, width: 100)
                        StandingCell(value: team.gb, width: 35)
                        StandingCell(value: team.last10, width: 50)
                        StandingCell(value: team.currenStreak, width: 40)
                    }
                }
            }
        }
        //.background(colorScheme == .light ? Color(hue: 1.0, saturation: 0.0, brightness: 0.95) : Color(hue: 1.0, saturation: 0.0, brightness: (0.0)))

    }
    
}

struct StandingCell: View {
    var value: String
    var width: CGFloat
    
    var body: some View {
        Text(value)
            .lineLimit(1)
            .frame(minWidth: width, maxWidth: .infinity)
            .background(.white)//row % 2 == 0 ? Color("boxLine1") : Color("boxLine2"))
            //.overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.black), alignment: .top)
    }
}


struct DetailView: View {
    
    var body: some View {
        
        Text("Hello, I'm a Detail View")
        
    }
}
       


struct StandingsView_Previews: PreviewProvider {
    static var previews: some View {
        StandingsView()
            .environmentObject(Standings())
    }
}
