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
    var playbyplay: PlayByPlay
    @StateObject var boxscore: BoxscoreModel
    let bPreview: Bool
    @Environment(\.colorScheme) var colorScheme


    //private var selectedGameId = 1
    @State private var collapsed: Bool = true

    var body: some View {
        VStack {
            ScrollViewReader { value in
                VStack {
                    ScrollView(.vertical){
                        PanelGameScoreView(game: game)
                        PanelGameGlobalStatView(game: game)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.6))
                            ScoreGraphView(game: game, playbyplay: playbyplay)
                        }
                        .frame(width:400, height:CGFloat(120+40*playbyplay.numExtraLines))

                        //PanelGameScorePerQuarterView(game: game)
                        PanelGameTopPlayers(game: game, boxscore: BoxscoreModel(gameId: game.id, preview: false))
                            
                        //Text("Curve\nplaybypplay")
                        ScorePlayByPlayView(game: game, playbyplay: PlayByPlay(gameId: game.id, homeTeamTricode: game.homeTeamResult.teamTricode, preview: bPreview))
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
        }
        //.padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.clear),  lineWidth: 0)
        )
        .frame(width:400, height:110)
        /*.background(RoundedRectangle(cornerRadius: 8).fill(LinearGradient(gradient: Gradient(colors: [Color("\(game.awayTeamResult.teamTricode)1"), Color("\(game.homeTeamResult.teamTricode)1")]), startPoint: UnitPoint(x:0.2, y:1), endPoint: UnitPoint(x:0.8, y:0))))*/
        .background(RoundedRectangle(cornerRadius: 8).fill(LinearGradient(gradient: Gradient(colors: [game.colorAway!, game.colorHome!]), startPoint: UnitPoint(x:0.2, y:1), endPoint: UnitPoint(x:0.8, y:0))))
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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("PanelBackground"))

            VStack {
                Grid(alignment: .center,
                     horizontalSpacing: 1,
                     verticalSpacing: 2) {
                    
                    GridRow {
                        ZStack {
                            Capsule()
                                .fill(game.colorAway!.opacity(game.awayTeamResult.isbest_fg_pct ? 0.7 : 0.0))
                                .frame(width: 70, height: 25)
                            Text("\(game.awayTeamResult.fg_pct*100, specifier: "%.0f") %")
                                .frame(width: 100)
                                .foregroundColor(colorScheme == .dark || game.awayTeamResult.isbest_fg_pct ? .white : .black)
                                .bold(game.homeTeamResult.isbest_fg_pct)
                        }
                        Text("Field Goals")
                            .frame(minWidth: 130)
                            .font(.subheadline)
                            .bold()
                        ZStack {
                            Capsule()
                                .fill(game.colorHome!.opacity(game.homeTeamResult.isbest_fg_pct ? 0.7 : 0.0))
                                .frame(width: 70, height: 25)
                            Text("\(game.homeTeamResult.fg_pct*100, specifier: "%.0f") %")
                                .frame(width: 100)
                                .foregroundColor(colorScheme == .dark || game.homeTeamResult.isbest_fg_pct ? .white : .black)
                                .bold(game.homeTeamResult.isbest_fg_pct)
                        }
                    }
                    GridRow {
                        ZStack {
                            Capsule()
                                .fill(game.colorAway!.opacity(game.awayTeamResult.isbest_fg3_pct ? 0.7 : 0.0))
                                .frame(width: 70, height: 25)
                            Text("\(game.awayTeamResult.fg3_pct*100, specifier: "%.0f") %")
                                .frame(width: 100)
                                .foregroundColor(colorScheme == .dark || game.awayTeamResult.isbest_fg3_pct ? .white : .black)
                        }
                        Text("3 Points")
                            .frame(minWidth: 100)
                            .font(.subheadline)
                            .bold()
                        ZStack {
                            Capsule()
                                .fill(game.colorHome!.opacity(game.homeTeamResult.isbest_fg3_pct ? 0.7 : 0.0))
                                .frame(width: 70, height: 25)
                            Text("\(game.homeTeamResult.fg3_pct*100, specifier: "%.0f") %")
                                .frame(width: 100)
                                .foregroundColor(colorScheme == .dark || game.homeTeamResult.isbest_fg3_pct ? .white : .black)
                        }
                    }
                    GridRow {
                        ZStack {
                            Capsule()
                                .fill(game.colorAway!.opacity(game.awayTeamResult.isbest_reb ? 0.7 : 0.0))
                                .frame(width: 50, height: 25)
                            Text("\(game.awayTeamResult.reb)")
                                .frame(width: 100)
                                .foregroundColor(colorScheme == .dark || game.awayTeamResult.isbest_reb ? .white : .black)
                        }
                        Text("Rebounds")
                            .frame(minWidth: 100)
                            .font(.subheadline)
                            .bold()
                        ZStack {
                            Capsule()
                                .fill(game.colorHome!.opacity(game.homeTeamResult.isbest_reb ? 0.7 : 0.0))
                                .frame(width: 50, height: 25)
                            Text("\(game.homeTeamResult.reb)")
                                .frame(width: 100)
                                .foregroundColor(colorScheme == .dark || game.homeTeamResult.isbest_reb ? .white : .black)
                        }
                    }
                    GridRow {
                        ZStack {
                            Capsule()
                                .fill(game.colorAway!.opacity(game.awayTeamResult.isbest_ast ? 0.7 : 0.0))
                                .frame(width: 50, height: 25)
                            Text("\(game.awayTeamResult.ast)")
                                .frame(width: 100)
                                .foregroundColor(colorScheme == .dark || game.awayTeamResult.isbest_ast ? .white : .black)
                        }
                        Text("Assists")
                            .frame(minWidth: 100)
                            .font(.subheadline)
                            .bold()
                        ZStack {
                            Capsule()
                                .fill(game.colorHome!.opacity(game.homeTeamResult.isbest_ast ? 0.7 : 0.0))
                                .frame(width: 50, height: 25)
                            Text("\(game.homeTeamResult.ast)")
                                .frame(width: 100)
                                .foregroundColor(colorScheme == .dark || game.homeTeamResult.isbest_ast ? .white : .black)
                        }
                    }

                }
                     .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.clear),  lineWidth: 0)
                     )
            }
        }
        .frame(width:400, height:115)
    }
    
}

struct PanelGameTopPlayers: View {
    @Environment(\.colorScheme) var colorScheme

    var game: mGame
    @StateObject var boxscore: BoxscoreModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("PanelBackground"))

            NavigationLink(destination: BoxscoreView(boxscore: BoxscoreModel(gameId: "\(game.id)", preview: false))) {
                if boxscore.dataIsLoaded {
                    HStack {
                        Grid(alignment: .topLeading,
                             horizontalSpacing: 1,
                             verticalSpacing: 2) {
                            GridRow {
                                Text("Player")
                                    .frame(width: 100)
                                    .lineLimit(1)
                                    .bold()
                                    .foregroundColor(.white)
                                    .background(game.colorAway)
                                Text("PTS")
                                    .frame(minWidth: 30)
                                    .foregroundColor(.white)
                                    .background(game.colorAway)
                                Text("REB")
                                    .frame(minWidth: 30)
                                    .foregroundColor(.white)
                                    .background(game.colorAway)
                                Text("AST")
                                    .frame(minWidth: 30)
                                    .foregroundColor(.white)
                                    .background(game.colorAway)
                            }
                            ForEach(boxscore.top5away) { player in
                                GridRow {
                                    Text("\(player.nameI)")
                                        .frame(width: 100)
                                        .lineLimit(1)
                                    Text("\(player.statistics.points)")
                                        .frame(minWidth: 30)
                                    Text("\(player.statistics.reboundsTotal)")
                                        .frame(minWidth: 30)
                                    Text("\(player.statistics.assists)")
                                        .frame(minWidth: 30)
                                }
                            }
                        }
                        Grid(alignment: .topLeading,
                             horizontalSpacing: 1,
                             verticalSpacing: 2) {
                            GridRow {
                                Text("Player")
                                    .frame(width: 100)
                                    .lineLimit(1)
                                    .bold()
                                    .foregroundColor(.white)
                                    .background(game.colorHome)
                                Text("PTS")
                                    .frame(minWidth: 30)
                                    .foregroundColor(.white)
                                    .background(game.colorHome)
                                Text("REB")
                                    .frame(minWidth: 30)
                                    .foregroundColor(.white)
                                    .background(game.colorHome)
                                Text("AST")
                                    .frame(minWidth: 30)
                                    .foregroundColor(.white)
                                    .background(game.colorHome)
                            }
                            ForEach(boxscore.top5home) { player in
                                GridRow {
                                    Text("\(player.nameI)")
                                        .frame(width: 100)
                                        .lineLimit(1)
                                    Text("\(player.statistics.points)")
                                        .frame(minWidth: 30)
                                    Text("\(player.statistics.reboundsTotal)")
                                        .frame(minWidth: 30)
                                    Text("\(player.statistics.assists)")
                                        .frame(minWidth: 30)
                                }
                            }
                        }
                    }
                }
                else {
                    Text("Boxscore loading...")
                }
            }
        }
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .frame(width:400, height:130)
    }
}

struct GameDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        GameDetailsView(game: DayGames(preview: true).getPreviewGame(),
                        playbyplay: PlayByPlay(gameId: "1234", homeTeamTricode: "SAC", preview: true),
                        boxscore: BoxscoreModel(gameId: "123", preview: true),
                        bPreview: true)
    }
}

