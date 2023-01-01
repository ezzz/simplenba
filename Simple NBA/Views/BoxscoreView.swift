//
//  BoxscoreView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 10/11/2022.
//

import SwiftUI

struct BoxscoreView: View {
    @ObservedObject var boxscore: BoxscoreModel
    
    var body: some View {
        if boxscore.dataIsLoaded {
            ScrollView(.vertical) {
                HStack {
                    VStack {
                        BoxscorePlayersView(teamBoxscore: (boxscore.gameBoxscore?.game.awayTeam)!, hasPlayed: true)
                        BoxscorePlayersView(teamBoxscore: (boxscore.gameBoxscore?.game.homeTeam)!, hasPlayed: true)
                        BoxscorePlayersView(teamBoxscore: (boxscore.gameBoxscore?.game.awayTeam)!, hasPlayed: false)
                        BoxscorePlayersView(teamBoxscore: (boxscore.gameBoxscore?.game.homeTeam)!, hasPlayed: false)
                    }
                    // Grid will all data
                    ScrollView(.horizontal) {
                        BoxscoreDataView(teamBoxscore: (boxscore.gameBoxscore?.game.awayTeam)!, hasPlayed: true)
                        BoxscoreDataView(teamBoxscore: (boxscore.gameBoxscore?.game.homeTeam)!, hasPlayed: true)
                        BoxscoreDataView(teamBoxscore: (boxscore.gameBoxscore?.game.awayTeam)!, hasPlayed: false)
                        BoxscoreDataView(teamBoxscore: (boxscore.gameBoxscore?.game.homeTeam)!, hasPlayed: false)
                    }
                }
            }
        }
        else {
            Text("Loading...")
        }
    }
}
struct BoxscorePlayersView: View {
    @Environment(\.colorScheme) var dark
    
    var teamBoxscore: jTeamBoxScore
    var hasPlayed: Bool

    let headerTitles = [/*"Player",*/ "MIN", "PTS", "REB", "AST", "TO", "STL", "BLK", "FG", "3P", "FT", "OREB", "DREB", "+/-"]
    var body: some View {
        // First Column with player names
        Grid(alignment: .topLeading,
             horizontalSpacing: 1,
             verticalSpacing: 0) {
            GridRow {
                Text(teamBoxscore.teamName)
                    .bold()
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(minWidth: 30, maxWidth: 120, minHeight: 40)
                    .background(Color("boxHeader"))
            }
            ForEach(teamBoxscore.players.indices, id: \.self) { index in
                if hasPlayed && teamBoxscore.players[index].played == "1" || !hasPlayed && teamBoxscore.players[index].played == "0"
                {
                    GridRow() {
                        Text("\(teamBoxscore.players[index].nameI)")
                            .bold(index < 5 ? true : false)
                            .padding(.leading, 5)
                            .frame(minWidth: 30, maxWidth: 120, alignment: .leading)
                            .background(index % 2 == 0 ? Color("boxLine1") : Color("boxLine2"))
                            .lineLimit(1)
                        
                    }
                    .frame(minWidth: 30, maxWidth: 120)
                }
            }
        }
    }
}

struct BoxscoreDataView: View {
    var teamBoxscore: jTeamBoxScore
    var hasPlayed: Bool
    
    @Environment(\.colorScheme) var dark
    let headerTitles = ["MIN", "PTS", "REB", "AST", "TO", "STL", "BLK", "FG", "3P", "FT", "OREB", "DREB", "+/-"]

    var body: some View {
        Grid(alignment: .topLeading,
             horizontalSpacing: 1,
             verticalSpacing: 0) {
            if hasPlayed {
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
            }
            else {
                GridRow {
                    Text("")
                        .bold()
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(minWidth: 800, maxWidth: .infinity, minHeight: 40)
                        .background(Color("boxHeader"))
                }
            }
            
            ForEach(teamBoxscore.players.indices, id: \.self) { index in
                let stat = teamBoxscore.players[index].statistics
                if hasPlayed && teamBoxscore.players[index].played == "1" {
                    GridRow {
                        Group {
                            ScoreValue(row: index, value: "\(String(stat.minutes.dropLast(4).dropFirst(2)).replacingOccurrences(of: "M", with: ":"))", width: 60)
                            ScoreValue(row: index, value:"\(stat.points)", width: 30)
                            ScoreValue(row: index, value:"\(stat.reboundsTotal)", width: 40)
                            ScoreValue(row: index, value:"\(stat.assists)", width: 40)
                            ScoreValue(row: index, value:"\(stat.turnovers)", width: 40)
                            ScoreValue(row: index, value:"\(stat.steals)", width: 40)
                            ScoreValue(row: index, value:"\(stat.blocks)", width: 40)
                            
                            ScoreValue(row: index, value:"\(stat.fieldGoalsMade)-\(stat.fieldGoalsAttempted)", width: 55)
                            ScoreValue(row: index, value:"\(stat.threePointersMade)-\(stat.threePointersAttempted)", width: 55)
                            ScoreValue(row: index, value:"\(stat.freeThrowsMade)-\(stat.freeThrowsAttempted)", width: 55)
                        }
                        ScoreValue(row: index, value:"\(stat.reboundsDefensive)", width: 45)
                        ScoreValue(row: index, value:"\(stat.reboundsOffensive)", width: 45)
                        
                        Text(String(format: "%.0f%", stat.plusMinusPoints))
                            .frame(minWidth: 30, maxWidth: .infinity)
                            .background(index % 2 == 0 ? Color("boxLine1") : Color("boxLine2"))
                    }
                }
                else if !hasPlayed  && teamBoxscore.players[index].played == "0" {
                    Text("DNP")
                        .padding(.leading, 5)
                        .frame(minWidth: 550, maxWidth: 800, alignment: .leading)
                        .background(index % 2 == 0 ? Color("boxLine1") : Color("boxLine2"))
                }
            }
        }
    }
}


struct ScoreValue: View {
    var row: Int
    var value: String
    var width: CGFloat
    
    var body: some View {
        Text("\(value)")
            .lineLimit(1)
            .frame(minWidth: width, maxWidth: .infinity)
            .background(row % 2 == 0 ? Color("boxLine1") : Color("boxLine2"))
            //.overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.black), alignment: .top)
    }
}

struct BoxscoreView_Previews: PreviewProvider {
    static var previews: some View {
        BoxscoreView(boxscore: BoxscoreModel(gameId: "123", preview: true))
    }
}
