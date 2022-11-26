//
//  ContentView.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 02/11/2022.
//

import SwiftUI
/*
struct ScoreboardView: View {
    
    @ObservedObject var todayGames: TodayGames
    @Environment(\.colorScheme) var colorScheme
    @Namespace var animation
    
    var body: some View {
        TabView {
            VStack {
                ScrollViewReader { value in
                    HStack {
                        LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                            Section(header: HeaderView()) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        ForEach(todayGames.currentWeek, id: \.self) { day in
                                            VStack(spacing: 5) {
                                                Text(todayGames.extractDate(date: day, format: "EEE"))
                                                    .font(.system(size: 14))
                                                    .fontWeight(todayGames.isToday(date: day) ? .bold : .semibold)
                                                Text(todayGames.extractDate(date: day, format: "dd"))
                                                    .font(.system(size: 15))
                                                    .fontWeight(todayGames.isToday(date: day) ? .bold : .semibold)
                                            }
                                            .frame(width:55, height:55)
                                            .background(
                                                ZStack {
                                                    if (todayGames.isSelectedDay(date: day))  {
                                                        Circle()
                                                            .fill(Color.blue.opacity(1.0))
                                                            .matchedGeometryEffect(id: "ANNIM", in: animation)
                                                    }
                                                }
                                            )
                                            .contentShape(Circle())
                                            .onTapGesture {
                                                //print("Selected day is \(day)")
                                                //todayGames.selectedDay = day
                                                //withAnimation(Animation.linear) {
                                                withAnimation(.easeInOut(duration: 0.1)) {
                                                    print("Selected day is \(day)")
                                                    todayGames.selectedDay = day
                                                }
                                                
                                                
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                }
                            }
                            if (todayGames.dataIsLoaded) {
                                //Text("game")
                            }
                        }
                    }
                    .onAppear {
                        value.scrollTo(3, anchor: .center)
                    }

                    if (todayGames.dataIsLoaded) {
                        //Text("Content loaded")
                        ScrollView {
                            ForEach((todayGames.results?.scoreboard.games)!) { game in
                                NavigationLink(destination: BoxscoreView(boxscore: BoxscoreModel(gameId: game.gameId, preview: true))) {
                                    ListItemView(game: game)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            todayGames.loadJson()
                        }
                        //.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        //.frame(minHeight: 650).border(Color.red)
                    }
                    else {
                        Text("Loading data...")
                            .font(.title2)
                    }
                }
                Spacer()

            }
            .tabItem {
                Label("Menu", systemImage: "list.dash")
            }

            Group {
                if (todayGames.dataIsLoaded) {
                    List((todayGames.results?.scoreboard.games)!) { game in
                        NavigationLink(destination: BoxscoreView(boxscore: BoxscoreModel(gameId: game.gameId, preview: true))) {
                            ListItemView(game: game)
                        }
                    }
                    .refreshable {
                        todayGames.loadJson()
                    }
                    .navigationTitle(Text("Results"))
                }
                else {
                    Text("Loading data...")
                        .font(.title2)
                        .refreshable {
                            todayGames.loadJson()
                        }
                        .navigationTitle(Text("Results"))
                    
                }
            }
            .tabItem {
                    Label("Order", systemImage: "square.and.pencil")
            }
        }
    }

    func HeaderView() -> some View {
        
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 5) {
                Text("Games")
                    .foregroundColor(.primary)
                    .font(.largeTitle.bold())
                Spacer()
                Image("logo-nba")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height:  45)
                //.padding(.bottom, -5)
            }
            .hLeading()
            Text(todayGames.extractDate(date: todayGames.selectedDay, format: "MMMM"))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black)
    }
}

extension View {
    func hLeading()->some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading )
    }
    func hTrailing()->some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading )
    }
    func hCenter()->some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading )
    }
}

struct ListItemView: View {
    
    var game: jGame
    let iIconSize: CGFloat = 40
    let iFrameIconWidth: CGFloat = 100
    
    var body: some View {
        //GeometryReader { gp in
        HStack {
            VStack {
                Image("\(game.awayTeam.teamTricode)_logo")
                    .resizable()
                    .frame(width: iIconSize, height:  iIconSize)
                    .padding(.bottom, -5)
                Text("\(game.awayTeam.teamName)")
                    .font(.footnote)
                    .foregroundColor(.white)
                Text("\(game.awayTeam.wins) - \(game.awayTeam.losses)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 80)
            Spacer()
            VStack {
                if (game.gameStatus == 1) {
                    Text("\(game.gameStatusText)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                else {
                    Text("\(game.awayTeam.score) - \(game.homeTeam.score)")
                        .foregroundColor(.white)
                }
            }
            Spacer()
            VStack {
                Image("\(game.homeTeam.teamTricode)_logo")
                    .resizable()
                    .frame(width: iIconSize, height:  iIconSize)
                    .padding(.bottom, -5)
                Text("\(game.homeTeam.teamName)")
                    .font(.footnote)
                    .foregroundColor(.white)
                Text("\(game.homeTeam.wins) - \(game.homeTeam.losses)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 80)

            //.frame(maxWidth: .infinity, maxHeight: .infinity)//.frame(maxWidth: 100)
        }
        //.padding()
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hue: 1.0, saturation: 0.0, brightness: 0.2),  lineWidth: 1/2)
        )
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.1)))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(todayGames: TodayGames(preview: true))
    }
}
*/
