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
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            
            ZStack {
                
                let widthTable = width
                let minX = (width - widthTable) / 2
                let midX = (width) / 2
                let maxX = widthTable + (width - widthTable) / 2
/*
                // Background
                RectangleShape()
                    .fill(Color.gray).brightness(0.3)
                    .frame(width:widthTable, height: graphLineHeight)
                    .offset(x:0, y:-graphLineHeight*3/2)
                RectangleShape()
                    .fill(Color.gray).brightness(0.25)
                    .frame(width:widthTable, height: graphLineHeight)
                    .offset(x:0, y:-graphLineHeight*1/2)
                
                RectangleShape()
                    .fill(.gray).brightness(0.3)
                    .frame(width:widthTable, height: graphLineHeight)
                    .offset(x:0, y:+graphLineHeight*3/2)
                RectangleShape()
                    .fill(.gray).brightness(0.25)
                    .frame(width:widthTable, height: graphLineHeight)
                    .offset(x:0, y:+graphLineHeight*1/2)
                */
                VerticalQuarterShape()
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)

                if playbyplay.dataIsLoaded {
                    VStack {
                        Grid(alignment: .topLeading,
                             horizontalSpacing: 1,
                             verticalSpacing: 0) {
                            ForEach(playbyplay.timePlayArray.reversed(), id: \.self) {
                                let action = playbyplay.playTable[$0]!
                                GridRow {
                                    Text("\(action.time)")
                                        .frame(minWidth: 60)
                                    Text("\(action.description)")
                                        .frame(minWidth: 80)
                                    Text("\(action.scoreAway)")
                                        .frame(minWidth: 30)
                                    Text("\(action.scoreHome)")
                                        .frame(minWidth: 30)
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
        ScorePlayByPlayView(game: DayGames(preview: true).getPreviewGame(), playbyplay: PlayByPlay(gameId: "0022200161", preview: true))
            .frame(width:400, height:300)
    }
}

