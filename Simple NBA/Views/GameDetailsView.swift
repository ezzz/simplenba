//
//  GameView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 22/11/2022.
//

import SwiftUI
//import SwiftUICharts

struct GameDetailsView: View {
    var game: mGame
    let bPreview: Bool
    

    //private var selectedGameId = 1
    @State private var collapsed: Bool = true

    var body: some View {
        VStack {
            ScrollViewReader { value in
                VStack {
                    ScrollView(.vertical){
                        PanelGameScoreView(game: game)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.6))
                            ScoreGraphView(game: game, playbyplay: PlayByPlay(gameId: game.id, preview: bPreview))
                        }
                        .frame(width:400, height:125)

                        //PanelGameScorePerQuarterView(game: game)
                        PanelGameGlobalStatView(game: game)
                        PanelGameTopPlayers(game: game)
                            
                        //Text("Curve\nplaybypplay")
                        ScorePlayByPlayView(game: game, playbyplay: PlayByPlay(gameId: game.id, preview: bPreview))
                            .frame(width:400)


/*
                        VStack {
                            Button(
                                action: { self.collapsed.toggle() },
                                label: {
                                    HStack {
                                        Spacer()
                                        Text("Q4 play by play")
                                            .padding(8)
                                        Spacer()
                                        Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                                            .padding(8)
                                    }
                                    .padding(.bottom, 1)
                                    .background(Color.white.opacity(0.01))
                                }
                            )
                            .buttonStyle(PlainButtonStyle())
                            
                            ScorePlayByPlayView(game: game, playbyplay: PlayByPlay(gameId: game.id, preview: bPreview))
                            .frame(minWidth: 0, maxWidth: 400, minHeight: 0, maxHeight: collapsed ? 0 : .none)
                            .clipped()
                            .animation(.easeOut)
                            .transition(.slide)
                        }
                        .frame(minWidth: 0, maxWidth: 400)
                        .background(.gray.opacity(0.6))
 */

                    }
                }
            }
            Spacer()
            
        }
    }
    
    func HeaderView() -> some View {
        
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 5) {
                Spacer()
                Text("Games details")
                    .foregroundColor(.secondary)
                    .font(.headline)
                Spacer()
                Image("logo-nba")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height:  45)
            }
            .hLeading()
            Text("Septembre 13th")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black)
    }
}

struct PanelGameScoreView: View {
    var game: mGame
    let iIconSize: CGFloat = 60
    let iFrameIconWidth: CGFloat = 100

    var body: some View {
        HStack {
            VStack {
                Image("\(game.awayTeamResult.teamTricode)_logo")
                    .resizable()
                    .frame(width: iIconSize, height:  iIconSize)
                    .padding(.bottom, -5)
                Text("\(game.awayTeamResult.teamName)")
                    .bold()
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("\(game.awayTeamResult.teamWinsLoss)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 90)
            .padding()
            Spacer()
            VStack {
                if let ptsA = game.awayTeamResult.pts, let ptsH = game.homeTeamResult.pts {
                    VStack {
                        Spacer()
                        Text("\(game.arenaName)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Spacer()
                        HStack {
                            Text("\(ptsA)")
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold(ptsA > ptsH ? true : false)
                            Text(" - ")
                                .foregroundColor(.white)
                                .font(.title3)
                            Text("\(ptsH)")
                                .foregroundColor(.white)
                                .bold(ptsA > ptsH ? false : true)
                                .font(.title3)
                        }
                        Spacer()
                        Text("\(game.statusText)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            //.padding(3)
                        Spacer()
                    }
                }
                else {
                    Text("\(game.statusText) (\(game.status)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            Spacer()
            VStack {
                Image("\(game.homeTeamResult.teamTricode)_logo")
                    .resizable()
                    .frame(width: iIconSize, height:  iIconSize)
                    .padding(.bottom, -5)
                Text("\(game.homeTeamResult.teamName)")
                    .bold()
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("\(game.homeTeamResult.teamWinsLoss)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    //.padding(1)
            }
            .frame(maxWidth: 90)
            .padding()
            
            //.frame(maxWidth: .infinity, maxHeight: .infinity)//.frame(maxWidth: 100)
        }
        //.padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.clear),  lineWidth: 0)
        )
        .frame(width:400, height:110)
        .background(RoundedRectangle(cornerRadius: 8).fill(LinearGradient(gradient: Gradient(colors: [Color(red: 85/255, green: 37/255, blue: 131/255), Color(red: 0/255, green: 120/255, blue: 140/255)]), startPoint: UnitPoint(x:0.2, y:1), endPoint: UnitPoint(x:0.8, y:0))))
    }
}

struct PanelGameScorePerQuarterView: View {
    var game: mGame
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("PanelBackground"))
            VStack {
                Grid(alignment: .topLeading,
                     horizontalSpacing: 1,
                     verticalSpacing: 0) {
                    GridRow {
                        Text(" ")
                            .frame(minWidth: 100)
                        Text("Q1")
                            .bold()
                            .frame(minWidth: 50)
                        Text("Q2")
                            .bold()
                            .frame(minWidth: 50)
                        Text("Q3")
                            .bold()
                            .frame(minWidth: 50)
                        Text("Q4")
                            .bold()
                            .frame(minWidth: 50)
                    }
                    GridRow {
                        Text("\(game.awayTeamResult.teamName)")
                            .frame(minWidth: 100)
                        Text("\(game.awayTeamResult.pts_qtr1)")
                            .frame(minWidth: 50)
                        Text("\(game.awayTeamResult.pts_qtr2)")
                            .frame(minWidth: 50)
                        Text("\(game.awayTeamResult.pts_qtr3)")
                            .frame(minWidth: 50)
                        Text("\(game.awayTeamResult.pts_qtr4)")
                            .frame(minWidth: 50)
                        Text("\(game.awayTeamResult.pts)")
                            .frame(minWidth: 50)
                    }
                    GridRow {
                        Text("\(game.homeTeamResult.teamName)")
                            .frame(minWidth: 100)
                        Text("\(game.homeTeamResult.pts_qtr1)")
                            .frame(minWidth: 50)
                        Text("\(game.homeTeamResult.pts_qtr2)")
                            .frame(minWidth: 50)
                        Text("\(game.homeTeamResult.pts_qtr3)")
                            .frame(minWidth: 50)
                        Text("\(game.homeTeamResult.pts_qtr4)")
                            .frame(minWidth: 50)
                        Text("\(game.homeTeamResult.pts)")
                            .frame(minWidth: 50)
                    }
                    
                }
                     .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.clear),  lineWidth: 0)
                     )
            }
        }
        .frame(width:400, height:80)
    }
}

struct PanelGameGlobalStatView: View {
    var game: mGame

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("PanelBackground"))

            VStack {
                Grid(alignment: .topLeading,
                     horizontalSpacing: 1,
                     verticalSpacing: 0) {
                    GridRow {
                        Text(" ")
                            .frame(minWidth: 100)
                        Text("FG")
                            .bold()
                            .frame(minWidth: 50)
                        Text("FG3")
                            .bold()
                            .frame(minWidth: 50)
                        Text("FT")
                            .bold()
                            .frame(minWidth: 50)
                        Text("AST")
                            .bold()
                            .frame(minWidth: 40)
                        Text("RBD")
                            .bold()
                            .frame(minWidth: 40)
                        Text("TOV")
                            .bold()
                            .frame(minWidth: 40)
                    }
                    
                    GridRow {
                        Text("\(game.awayTeamResult.teamName)")
                            .frame(minWidth: 100)
                        Text("\(game.awayTeamResult.fg_pct*100, specifier: "%.0f")%")
                            .frame(minWidth: 50)
                        Text("\(game.awayTeamResult.fg3_pct*100, specifier: "%.0f")%")
                            .frame(minWidth: 50)
                        Text("\(game.awayTeamResult.ft_pct*100, specifier: "%.0f")%")
                            .frame(minWidth: 50)
                        Text("\(game.awayTeamResult.ast)")
                            .frame(minWidth: 40)
                        Text("\(game.awayTeamResult.reb)")
                            .frame(minWidth: 40)
                        Text("\(game.awayTeamResult.tov)")
                            .frame(minWidth: 40)
                    }
                    GridRow {
                        Text("\(game.homeTeamResult.teamName)")
                            .frame(minWidth: 100)
                        Text("\(game.homeTeamResult.fg_pct*100, specifier: "%.0f")%")
                            .frame(minWidth: 50)
                        Text("\(game.homeTeamResult.fg3_pct*100, specifier: "%.0f")%")
                            .frame(minWidth: 50)
                        Text("\(game.homeTeamResult.ft_pct*100, specifier: "%.0f")%")
                            .frame(minWidth: 50)
                        Text("\(game.homeTeamResult.ast)")
                            .frame(minWidth: 40)
                        Text("\(game.homeTeamResult.reb)")
                            .frame(minWidth: 40)
                        Text("\(game.homeTeamResult.tov)")
                            .frame(minWidth: 40)
                    }
                }
                     .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.clear),  lineWidth: 0)
                     )
            }
        }
        .frame(width:400, height:100)
    }
}

struct PanelGameTopPlayers: View {
    @Environment(\.colorScheme) var colorScheme

    var game: mGame
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("PanelBackground"))

            NavigationLink(destination: BoxscoreView(boxscore: BoxscoreModel(gameId: "\(game.id)", preview: false))) {
                if let ptsNameA = game.awayTeamResult.leadPtsName,
                   let rebNameA = game.awayTeamResult.leadRebName,
                   let astNameA = game.awayTeamResult.leadAstName,
                   let ptsA = game.awayTeamResult.leadPts,
                   let rebA = game.awayTeamResult.leadReb,
                   let astA = game.awayTeamResult.leadAst,
                   let ptsNameH = game.homeTeamResult.leadPtsName,
                   let rebNameH = game.homeTeamResult.leadRebName,
                   let astNameH = game.homeTeamResult.leadAstName,
                   let ptsH = game.homeTeamResult.leadPts,
                   let rebH = game.homeTeamResult.leadReb,
                   let astH = game.homeTeamResult.leadAst {
                    
                    Grid(alignment: .topLeading,
                         horizontalSpacing: 1,
                         verticalSpacing: 0) {
                        GridRow {
                            Text("\(ptsNameA)")
                                .frame(width: 100)
                                //.minimumScaleFactor(0.2)
                                .lineLimit(1)
                            Text("\(ptsA)")
                                .frame(minWidth: 50)
                            Text("PTS")
                                .bold()
                                .frame(minWidth: 50)
                            Text("\(ptsH)")
                                .frame(minWidth: 50)
                            Text("\(ptsNameH)")
                                .frame(minWidth: 100)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1)
                        }
                        GridRow {
                            Text("\(rebNameA)")
                                .frame(minWidth: 100)
                            Text("\(rebA)")
                                .frame(minWidth: 50)
                            Text("REB")
                                .bold()
                                .frame(minWidth: 50)
                            Text("\(rebH)")
                                .frame(minWidth: 50)
                            Text("\(rebNameH)")
                                .frame(minWidth: 100)
                        }
                        GridRow {
                            Text("\(astNameA)")
                                .frame(minWidth: 100)
                            Text("\(astA)")
                                .frame(minWidth: 50)
                            Text("AST")
                                .bold()
                                .frame(minWidth: 50)
                            Text("\(astH)")
                                .frame(minWidth: 50)
                            Text("\(astNameH)")
                                .frame(minWidth: 100)
                        }
                    }
                }
                else {
                    let _ = print("DetailsGameView NOOO Point leader")
                }
            }
        }
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .frame(width:400, height:100)
    }
}

struct GameDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        GameDetailsView(game: DayGames(preview: true).getPreviewGame(), bPreview: true)
    }
}

