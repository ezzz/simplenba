//
//  ScoreboardV2View.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 20/11/2022.
//

import SwiftUI

struct ScoreboardV2View: View {
    @ObservedObject var dayGames: DayGames
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
                                        ForEach(dayGames.currentWeek, id: \.self) { day in
                                            VStack(spacing: 5) {
                                                Text(dayGames.extractDate(date: day, format: "EEE"))
                                                    .font(.system(size: 14))
                                                    .fontWeight(dayGames.isToday(date: day) ? .bold : .semibold)
                                                Text(dayGames.extractDate(date: day, format: "dd"))
                                                    .font(.system(size: 15))
                                                    .fontWeight(dayGames.isToday(date: day) ? .bold : .semibold)
                                            }
                                            .frame(width:55, height:55)
                                            .background(
                                                ZStack {
                                                    if (dayGames.isSelectedDay(date: day))  {
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
                                                    dayGames.selectedDay = day
                                                    dayGames.loadJson()
                                                }
                                                
                                                
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                }
                            }
                            if (dayGames.dataIsLoaded) {
                                //Text("game")
                            }
                        }
                    }
                    .onAppear {
                        value.scrollTo(3, anchor: .center)
                    }

                    if (dayGames.dataIsLoaded) {
                        //Text("Content loaded")
                        ScrollView {
                            ForEach(dayGames.getGamesPerDay()) { game in
                                //NavigationLink(destination: BoxscoreView(boxscore: BoxscoreModel(gameId: game.gameId, preview: true))) {
                                    ListItemView(game: game)
                                //}
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            dayGames.loadJson()
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

            
            Text("TBD...")
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
            Text(dayGames.extractDate(date: dayGames.selectedDay, format: "MMMM"))
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
    
    var game: mGame
    let iIconSize: CGFloat = 40
    let iFrameIconWidth: CGFloat = 100
    
    var body: some View {
        //GeometryReader { gp in
        HStack {
            VStack {
                Image("\(game.awayTeamResult.teamTricode)_logo")
                    .resizable()
                    .frame(width: iIconSize, height:  iIconSize)
                    .padding(.bottom, -5)
                Text("\(game.awayTeamResult.teamName)")
                    .font(.footnote)
                    .foregroundColor(.white)
                Text("\(game.awayTeamResult.teamWinsLoss)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 90)
            Spacer()
            VStack {
                if (game.status == 1) {
                    Text("\(game.statusText)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                else {
                    VStack {
                        if game.awayTeamResult.pts > game.homeTeamResult.pts {
                            HStack {
                                Text("\(game.awayTeamResult.pts)")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                                Text(" - ")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("\(game.homeTeamResult.pts)")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                        }
                        else {
                            HStack {
                                
                                Text("\(game.awayTeamResult.pts)")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text(" - ")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                Text("\(game.homeTeamResult.pts)")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                            }
                        }
                        Text("\(game.statusText)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(3)
                    }
                }
            }
            Spacer()
            VStack {
                Image("\(game.homeTeamResult.teamTricode)_logo")
                    .resizable()
                    .frame(width: iIconSize, height:  iIconSize)
                    .padding(.bottom, -5)
                Text("\(game.homeTeamResult.teamName)")
                    .font(.footnote)
                    .foregroundColor(.white)
                Text("\(game.homeTeamResult.teamWinsLoss)")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 90)

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


struct ScoreboardV2View_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardV2View(dayGames: DayGames(preview: true))
    }
}
