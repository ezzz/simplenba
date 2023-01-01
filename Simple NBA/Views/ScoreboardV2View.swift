//
//  ScoreboardV2View.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 20/11/2022.
//

import SwiftUI
import SwiftUIPager
/*
struct ScoreboardV2View: View {
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
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 0) {
                                        ForEach(scoreData.availableDaysIndex, id: \.self) { dayIndex in
                                            VStack(spacing: 5) {
                                                Text(scoreData.extractDate(date: scoreData.availableDays[dayIndex], format: "EEE"))
                                                    .font(.system(size: 14))
                                                    .fontWeight(scoreData.isToday(date: scoreData.availableDays[dayIndex]) ? .bold : .semibold)
                                                Text(scoreData.extractDate(date: scoreData.availableDays[dayIndex], format: "dd"))
                                                    .font(.system(size: 15))
                                                    .fontWeight(scoreData.isToday(date: scoreData.availableDays[dayIndex]) ? .bold : .semibold)
                                            }
                                            .frame(width:55, height:55)
                                            .background(
                                                ZStack {
                                                    if (scoreData.isSelectedDay(date: scoreData.availableDays[dayIndex]))  {
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
                                                    print("Selected day is \(dayIndex) date \(scoreData.availableDays[dayIndex])")
                                                    scoreData.selectedDayIndex = dayIndex
                                                    //TBD page = Page.withIndex(scoreData.getIndexFromSelectedDay())
                                                    //TBD scoreData.loadJson(gamesDate: day)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                }
                            }
                            if (scoreData.dataIsLoaded) {
                                //Text("game")
                            }
                        }
                    }
                    .onAppear {
                        value.scrollTo(3, anchor: .center)
                    }
                    GeometryReader { proxy in
                        VStack(spacing: 10) {
                            Pager(page: page,
                                  data: scoreData.availableDaysIndex,
                                  id: \.self) {
                                let _ = print("--------- Loading page \($0)/\(scoreData.availableDaysIndex.count) -------------")
                                self.pageView($0)
                            }
                                  .singlePagination(ratio: 0.5, sensitivity: .high)
                                  .onPageWillChange({ (page) in
                                      let _ = print("Page will change to: \(page)")
                                  })
                                  .onPageChanged({ page in
                                      let _ = print("Page changed to: \(page)")
                                      scoreData.selectedDayIndex = page
                                      /*if page == 1 {
                                       let newData = (1...5).map { data1.first! - $0 }.reversed()
                                       withAnimation {
                                       page1.index += newData.count
                                       data1.insert(contentsOf: newData, at: 0)
                                       isPresented.toggle()
                                       }
                                       } else if page == self.data1.count - 2 {
                                       guard let last = self.data1.last else { return }
                                       let newData = (1...5).map { last + $0 }
                                       withAnimation {
                                       isPresented.toggle()
                                       data1.append(contentsOf: newData)
                                       }
                                       }*/
                                  })
                                  .pagingPriority(.simultaneous)
                                  .preferredItemSize(CGSize(width: proxy.size.width-10, height: proxy.size.height-10))
                                  .itemSpacing(10)
                                  .background(Color.gray.opacity(0.2))
                                  .alert(isPresented: self.$isPresented, content: {
                                      Alert(title: Text("Congratulations!"),
                                            message: Text("Five more elements were appended to your Pager"),
                                            dismissButton: .default(Text("Okay!")))
                                  })
                        }
                        //.navigationBarTitle("Infinite Pagers", displayMode: .inline)
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
                    //.foregroundColor(.primary)
                    .font(.largeTitle.bold())
                Spacer()
                Image("logo-nba")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height:  45)
                //.padding(.bottom, -5)
            }
            .hLeading()
            Text(scoreData.extractDate(date: scoreData.selectedDay, format: "MMMM"))
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    func pageView(_ pageIndex: Int) -> some View {
        ZStack {
            let _ = print("Loading view for index \(pageIndex) sel \(scoreData.selectedDayIndex) isLoaded \(scoreData.gamesByIndex[pageIndex]?.isLoaded ?? false)")
            
            if scoreData.gamesByIndex[pageIndex]?.isLoaded ?? false {
                let _ = print("Should display games for index \(pageIndex). Nb games \(scoreData.gamesByIndex[pageIndex]!.games.count)")
                VStack {
                    Text("Data loaded")
                        .font(.title2)
                    ScrollView {
                        ForEach(scoreData.gamesByIndex[pageIndex]!.games) { game in
                            NavigationLink(destination: GameDetailsView(game: game)) {//BoxscoreView(boxscore:  //BoxscoreModel(gameId: "\(game.id)", preview: false))) {
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
                //.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                //.frame(minHeight: 650).border(Color.red)
            }
            else {
                let _ = print("But games are not displayed for index \(pageIndex)")
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
        ScoreboardV2View()
            .environmentObject(DayGames(preview: false))
    }
}
*/
