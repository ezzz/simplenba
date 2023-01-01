//
//  ScoreboardV2View.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 20/11/2022.
//

import SwiftUI
import SwiftUIPager

struct ScoreboardV3View: View {
    @EnvironmentObject var scoreData: DayGames
    @State var page = Page.withIndex(2)
    @State var isPresented: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    @Namespace var animation
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { value in
                    HStack {
                        LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                            Section(header: HeaderView()) {
                                HStack {
                                
                                    
                                    CapsuleForDate(day: self.scoreData.selectedDayMinus1, isButton: false, offset: -1)
                                    Spacer()
                                    CapsuleForDate(day: self.scoreData.selectedDay, isButton: true, offset: 0)
                                    Spacer()
                                    CapsuleForDate(day: self.scoreData.selectedDayPlus1, isButton: false, offset: 1)
                                }
                               // .padding()
                            }
                        }
                    }
                }
                GeometryReader { proxy in
                    VStack(spacing: 10) {
                        GameListView(gamesStringDay: scoreData.selectedStringDay)
                            .environmentObject(scoreData)
                    }
                }
                Spacer()
            }
        }
    }
    
    func HeaderView() -> some View {
        
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 5) {
                Text("Games")
                    .font(.largeTitle.bold())
                Spacer()
                Image("logo-nba")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height:  45)
            }
            .hLeading()
            //Text(scoreData.extractDate(date: scoreData.selectedDay, format: "MMMM"))
            //    .foregroundColor(.gray)
        }
        //.padding()
        .padding(.leading, 15)
    }
    
    func CapsuleForDate(day: Date, isButton: Bool, offset: Int ) -> some View {
        ZStack {
            VStack(spacing: 5) {
                if isButton {
                    Text(scoreData.extractDate(date: day, format: "MMMM"))
                        .font(.system(size: 15))
                        .bold()
                }
                HStack {
                    if offset == -1 {
                        Image(systemName: "chevron.left")
                    }
                    Text(scoreData.extractDate(date: day, format: "EEE dd"))
                        .font(.system(size: 15))
                    if offset == 1 {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .foregroundColor(isButton ? Color.white : Color.blue)
            .frame(width:(isButton ? 140 : 120), height:50)
            .background(
                ZStack {
                    Capsule()
                        .fill((isButton ? Color.blue : Color.clear).opacity(1.0))
                        //.matchedGeometryEffect(id: "ANNIM", in: animation)
                }
            )
            .onTapGesture {
             //print("Selected day is \(day)")
             //todayGames.selectedDay = day
             //withAnimation(Animation.linear) {
             /*
              withAnimation(.easeInOut(duration: 0.1)) {*/
              //print("Selected day is \(dayIndex) date \(scoreData.availableDays[dayIndex])")
              scoreData.updateSelectedDay(dayOffset: offset)
              //TBD page = Page.withIndex(scoreData.getIndexFromSelectedDay())
              //TBD scoreData.loadJson(gamesDate: day)
              
             }
            
        }
    }
}

struct GameListView: View {
    @EnvironmentObject var scoreData: DayGames

    var gamesStringDay: String
    
    var body: some View {
        ZStack {
            let _ = print("Creating view for day \(gamesStringDay)")
            
            if scoreData.gamesByDay[gamesStringDay]?.isLoaded ?? false {
                let _ = print("Should display games for date \(gamesStringDay). Nb games \(scoreData.gamesByDay[gamesStringDay]!.games.count)")
                if scoreData.gamesByDay[gamesStringDay]!.games.count == 0 {
                    Spacer()
                    Text("No games")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)   // << here !!
                }
                else {
                    VStack {
                        ScrollView {
                            ForEach(scoreData.gamesByDay[gamesStringDay]!.games) { game in
                                NavigationLink(destination: GameDetailsView(game: game, bPreview: false)) {//BoxscoreView(boxscore:  //BoxscoreModel(gameId: "\(game.id)", preview: false))) {
                                    VStack {
                                        ListItemView(game: game)
                                        //Text("\(game.id)")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        //TBDscoreData.loadJson(gamesDate: dayOfView)
                    }

                }
            }
            else {
                let _ = print("But games are not displayed for \(gamesStringDay)")
                VStack {
                    Text("Loading data...")
                        .font(.title2)
                }
            }
        }
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


struct ScoreboardV3View_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardV3View()
            .environmentObject(DayGames(preview: false))
    }
}
