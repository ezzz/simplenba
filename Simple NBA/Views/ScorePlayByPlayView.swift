//
//  ScorePlayByPlayView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 01/01/2023.
//

import Foundation

//
//  ScoreGapShape.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 29/12/2022.
//

import SwiftUI


struct ScorePlayByPlayView: View {
    var game: mGame
    @StateObject var playbyplay: PlayByPlay
    let graphLineHeight = 20.0
    @State private var mode = 0
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            ZStack {
                
                let widthTable = width

                if playbyplay.dataIsLoaded {
                    VStack {
                        Picker("What is your favorite color?", selection: $mode) {
                                        Text("Points").tag(0)
                                        Text("Plays").tag(1)
                                        Text("All").tag(2)
                                    }
                                    .pickerStyle(.segmented)

                        Grid(alignment: .topLeading,
                             horizontalSpacing: 5,
                             verticalSpacing: 5) {
                            ForEach(playbyplay.timePlayArray.reversed(), id: \.self) {
                                let action = playbyplay.playTable[$0]!
                                if action.isShotMade || (mode > 0 && action.isFieldGoal == 1) || mode == 2 {
                                        GridRow {
                                            Text("\(action.time)")
                                                .frame(minWidth: 60)
                                                .bold(action.isShotMade)
                                            Text("\(action.description)")
                                                .frame(minWidth: 40)
                                                .bold(action.isShotMade)
                                            ZStack {
                                                Circle()
                                                    .fill(game.colorAway!.opacity(action.isShotMade && !action.isHomeShot ? 0.7 : 0.0))
                                                    .frame(width: 30, height: 30)
                                                Text("\(action.scoreAway)")
                                                    .frame(minWidth: 30)
                                            }
                                            ZStack {
                                                Circle()
                                                    .fill(game.colorHome!.opacity(action.isShotMade && action.isHomeShot ? 0.7 : 0.0))
                                                    .frame(width: 30, height: 30)
                                                Text("\(action.scoreHome)")
                                                .frame(minWidth: 30)
                                            }
                                        }
                                }
                            }
                        }
                             .font(.subheadline)
                    
                    }
                }
                else {
                    Text("Loading...")
                }
                
            }
        }
    }
}

struct ScorePlayByPlayView_Previews: PreviewProvider {
    static var previews: some View {
        ScorePlayByPlayView(game: DayGames(preview: true).getPreviewGame(), playbyplay: PlayByPlay(gameId: "0022200161", homeTeamTricode: "SAS", preview: true))
            //.frame(width:400, height:300)
    }
}

