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
        if (boxscore.dataIsLoaded) {
            SingleBoxscoreView(boxscore: (boxscore.gameBoxscore?.game.homeTeam)!)
            SingleBoxscoreView(boxscore: (boxscore.gameBoxscore?.game.awayTeam)!)
        }
    }
}

struct SingleBoxscoreView: View {
    var boxscore: jBoxscore
    
    let layout = [GridItem(.fixed(100)),
                  GridItem(.fixed(100)),
                  GridItem(.fixed(55)),
                  GridItem(.fixed(55)),
                  GridItem(.fixed(55)),
                  GridItem(.fixed(55)),
                  GridItem(.fixed(55)),
                  GridItem(.fixed(45)),
                  GridItem(.fixed(45)),
                  GridItem(.fixed(45)),
                  GridItem(.fixed(55)),
                  GridItem(.fixed(55)),
                  GridItem(.fixed(55)),
                  GridItem(.fixed(45))]
    
    var body: some View {
        ScrollView(.vertical) {
            ScrollView(.horizontal) {
                LazyVGrid(columns: layout) {
                    Group {
                        Text("Player")
                            .padding(5)
                        Text("MIN")
                        Text("PTS")
                        Text("REB")
                        Text("AST")
                        Text("TO")
                        Text("STL")
                        Text("BLK")
                    }
                    Group {
                        Text("FG")
                        //Text("FG%")
                        Text("3P")
                        //Text("3P%")
                        Text("FT")
                        //Text("FT%")
                        Text("OREB")
                        Text("DREB")
                        Text("+/-")
                    }
                    ForEach((boxscore.gameBoxscore?.game.homeTeam.players)!) {  player in
                        Group {
                            /*AsyncImage(url: URL(string: "https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/\(player.personId).png"))
                                .frame(width: 10, height: 10)*/
                            Text("\(player.nameI)")
                            /*let sMin = player.statistics.minutes
                            let start = index(sMin.startIndex, offsetBy: 2)
                            let end = index(sMin.startIndex, offsetBy: -4)
                            let sMin2 = sMin.substring(with: start..<end)*/
                            Text("23m12s")
                            Text("\(player.statistics.points)")
                            Text("\(player.statistics.reboundsTotal)")
                            Text("\(player.statistics.assists)")
                            Text("\(player.statistics.turnovers)")
                            Text("\(player.statistics.steals)")
                            Text("\(player.statistics.blocks)")
                        }
                        Group {
                            Text("\(player.statistics.fieldGoalsMade)-\(player.statistics.fieldGoalsAttempted)")
                            //Text(String(format: "%.0f%%", player.statistics.fieldGoalsPercentage*100))
                            Text("\(player.statistics.threePointersMade)-\(player.statistics.threePointersAttempted)")
                            //Text(String(format: "%.0f%%", player.statistics.threePointersPercentage*100))
                            Text("\(player.statistics.freeThrowsMade)-\(player.statistics.freeThrowsAttempted)")
                            //Text(String(format: "%.0f%%", player.statistics.freeThrowsPercentage*100))
                            Text("\(player.statistics.reboundsDefensive)")
                            Text("\(player.statistics.reboundsOffensive)")
                            Text(String(format: "%.0f%", player.statistics.plusMinusPoints))
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct BoxscoreView_Previews: PreviewProvider {
    static var previews: some View {
        BoxscoreView(boxscore: BoxscoreModel(gameId: "123", preview: true))
    }
}
