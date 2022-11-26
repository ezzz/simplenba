//
//  StatisticDataLoader.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 02/11/2022.
//

import Foundation

struct GameResult: Identifiable {
    var id: String
    var gameresult: String
}

// JSON struct for
struct jTodayScoreboard: Decodable {
    var scoreboard: jScoreboard
    
    //let mainScores: jTodayScoreboard = nil
}

struct jScoreboard: Decodable {
    var gameDate: String
    var leagueId: String
    var leagueName: String
    var games: [jGame]
}

struct jGame: Decodable {
    var gameId: String
    var gameCode: String
    var gameStatus: Int
    var gameStatusText: String
    var homeTeam: jTeam
    var awayTeam: jTeam
}

// Now conform to Identifiable
extension jGame: Identifiable {
    var id: String { return gameId }
}

struct jTeam: Decodable {
    var teamId: Int
    var teamName: String
    var teamCity: String
    var teamTricode: String
    var wins: Int
    var losses: Int
    var score: Int
}

class TodayGames: ObservableObject {
    @Published var dataIsLoaded: Bool = false
    @Published var results: jTodayScoreboard? = nil
    @Published var currentWeek: [Date] = []
    @Published var selectedDay: Date = Date()
    var bPreview: Bool
    
    init(preview: Bool) {
        bPreview = preview
        fetchCurrentWeek()
        loadJson()
    }
    
    func loadJson() {
        print("Loading json")
        if (self.bPreview) {
            guard let pathToJsonPreview = Bundle.main.path(forResource: "live_todayscoreboard", ofType: "json") else {
                print ("error: no path to json file")
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let content = try Data(contentsOf: URL(fileURLWithPath: pathToJsonPreview))
                    let dataFromJson = try JSONDecoder().decode(jTodayScoreboard.self, from: content)
                    print ("(preview) Scoreboard for \(dataFromJson.scoreboard.gameDate)")
                    for game in dataFromJson.scoreboard.games {
                        print ("\(game.awayTeam.teamTricode) \(game.awayTeam.score) - \(game.homeTeam.score) \(game.homeTeam.teamTricode)")
                    }
                    self.results = dataFromJson
                    self.dataIsLoaded = true
                    print("Preview data loaded")

                } catch {
                    print("Preview Not data loaded:\(error)")
                }
            }
        }
        else {
            let endpoint = URL(string: "https://stats.nba.com/stats/scoreboardv2?GameDate=2022-12-05&LeagueID=00&DayOffset=0")!
            //URL(string: "https://cdn.nba.com/static/json/liveData/scoreboard/todaysScoreboard_00.json")!
            var request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                guard error == nil else {
                    print ("error: \(error!)")
                    return
                }
                
                guard let content = data else {
                    print("No data")
                    return
                }
                
                DispatchQueue.main.async {
                    do {
                        let dataFromJson = try JSONDecoder().decode(jTodayScoreboard.self, from: content)
                        print ("Scoreboard for \(dataFromJson.scoreboard.gameDate)")
                        for game in dataFromJson.scoreboard.games {
                            print ("\(game.awayTeam.teamTricode) \(game.awayTeam.score) - \(game.homeTeam.score) \(game.homeTeam.teamTricode)")
                        }
                        self.results = dataFromJson
                        self.dataIsLoaded = true
                        
                    } catch {
                        print(error)
                    }
                }
                print("Data loaded")
                
            }
            task.resume()
        }
    }
    
    func fetchCurrentWeek() {
        print ("Fecth current week")
        let today = Date()
        let calendar = Calendar.current
        //let week = calendar.dateInterval(of: .weekOfMonth, for: today)
        /*guard let firstWeekDay = week?.start else {
            return
        }*/
        
        (-3...4).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: today) {
                currentWeek.append(weekday)
            }
        }
    }
    
    func extractDate(date:Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func isToday(date: Date)->Bool {
        let calendar = Calendar.current
        return calendar.isDate(Date(), inSameDayAs: date)
    }
    
    func isSelectedDay(date: Date)->Bool {
        let calendar = Calendar.current
        return calendar.isDate(selectedDay, inSameDayAs: date)
    }
}
