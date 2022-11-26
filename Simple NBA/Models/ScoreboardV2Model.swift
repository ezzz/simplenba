//
//  ScoreboardV2.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 02/11/2022.
//
//
import Foundation

// MARK: - ScoreboardV2
struct jScoreboardV2: Codable {
    let resource: String
    let parameters: Parameters
    let resultSets: [ResultSet]
}

// MARK: - Parameters
struct Parameters: Codable {
    let gameDate, leagueID, dayOffset: String

    enum CodingKeys: String, CodingKey {
        case gameDate = "GameDate"
        case leagueID = "LeagueID"
        case dayOffset = "DayOffset"
    }
}

// MARK: - ResultSet
struct ResultSet: Codable {
    let name: String
    let headers: [String]
    let rowSet: [[RowSet]]
}

enum RowSet: Codable {
    case int(Int)
    case double(Double)
    case string(String)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .int(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if container.decodeNil() {
            self = .null
            return
        }
        throw DecodingError.typeMismatch(RowSet.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RowSet"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let x):
            try container.encode(x)
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .null:
            try container.encodeNil()
        }
    }
                            
    func stringValue()->String {
        switch self {
        case .int(let x):
            return String(format: "%d", x)
        case .double(let x):
            return String(format: "%.1f", x)
        case .string(let x):
            return x
        case .null:
            return ""
        }
    }
        
    func intValue()->Int {
        switch self {
        case .int(let x):
            return x
        case .double:
            return 0
        case .string:
            return 0
        case .null:
            return 0
        }
    }
        
}

// MARK: - Struct from internal model
struct mScoreboard {
    let gamesDate: String
    let games: [mGame]
}

struct mGame : Identifiable {
    let id, time, statusText: String
    let status: Int
    let awayTeamResult, homeTeamResult: mTeamGameResult
}

struct mTeamGameResult {
    let teamTricode, teamName, teamWinsLoss: String
    let pts, pts_qtr1, pts_qtr2, pts_qtr3, pts_qtr4: Int
}


class DayGames: ObservableObject {
    @Published var dataIsLoaded: Bool = false
    @Published var gamesByDay = [String: mScoreboard]()
    @Published var currentWeek: [Date] = []
    @Published var selectedDay: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    var bPreview: Bool
    
    init(preview: Bool) {
        print("Loading DayGames")
        bPreview = preview
        fetchCurrentWeek()
        loadJson()
    }
    
    func loadJson() {
        print("Loading json")
        if (self.bPreview) {
            guard let pathToJsonPreview = Bundle.main.path(forResource: "scoreboardV2", ofType: "json") else {
                print ("error: no path to json file")
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let content = try Data(contentsOf: URL(fileURLWithPath: pathToJsonPreview))
                    let dataFromJson = try JSONDecoder().decode(jScoreboardV2.self, from: content)
                    print ("(preview) ScoreboardV2 for \(dataFromJson.parameters.gameDate)")
                    /*for game in dataFromJson.scoreboard.gameDate {
                        print ("\(game.awayTeam.teamTricode) \(game.awayTeam.score) - \(game.homeTeam.score) \(game.homeTeam.teamTricode)")
                    }*/
                    print("Preview data loaded")
                    self.parseGames(jsonParseData:dataFromJson)
                } catch {
                    print("Preview Not data loaded:\(error)")
                }
            }
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let selectedDayString = dateFormatter.string(from: self.selectedDay)
            let endpoint = URL(string: "https://stats.nba.com/stats/scoreboardv2?GameDate=\(selectedDayString)&LeagueID=00&DayOffset=0")!
            print("Get data from \(endpoint)")
            var request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.setValue("x-nba-stats-origin", forHTTPHeaderField: "x-nba-stats-origin")
            
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
                        let dataFromJson = try JSONDecoder().decode(jScoreboardV2.self, from: content)
                        print ("Scoreboard for \(dataFromJson.parameters.gameDate)")
                        /*for game in dataFromJson.scoreboard.games {
                            print ("\(game.awayTeam.teamTricode) \(game.awayTeam.score) - \(game.homeTeam.score) \(game.homeTeam.teamTricode)")
                        }*/
                        self.parseGames(jsonParseData:dataFromJson)
                        
                    } catch {
                        print(error)
                    }
                }
                print("Data loaded")
            }
            task.resume()
        }
    }
    
    func parseGames(jsonParseData: jScoreboardV2) {
        print ("Parsing data ScoreboardV2 for \(jsonParseData.parameters.gameDate)")
        //do {
            var games = [mGame]()
            for resultSet in jsonParseData.resultSets {
                /*for header in resultSet.headers {
                 print("H: \(header)")
                 
                 }*/
                if resultSet.name == "GameHeader" {
                    for i in 0 ..< resultSet.rowSet.count {
                        //print("\(resultSet.headers[i]): \(resultSet.rowSet[i][6].stringValue())")
                        let homeTeamId = resultSet.rowSet[i][6].intValue()
                        let awayTeamId = resultSet.rowSet[i][7].intValue()
                        let homeScore = jsonParseData.resultSets[1].rowSet.first(where: { $0[3].intValue() == homeTeamId } )
                        let awayScore = jsonParseData.resultSets[1].rowSet.first(where: { $0[3].intValue() == awayTeamId } )
                        let awayResult = mTeamGameResult(teamTricode: awayScore![4].stringValue(), teamName: awayScore![6].stringValue(), teamWinsLoss: awayScore![7].stringValue(), pts: awayScore![22].intValue(), pts_qtr1: 0, pts_qtr2: 0, pts_qtr3: 0, pts_qtr4: 0)
                        let homeResult = mTeamGameResult(teamTricode: homeScore![4].stringValue(), teamName: homeScore![6].stringValue(), teamWinsLoss: homeScore![7].stringValue(), pts: homeScore![22].intValue(), pts_qtr1: 0, pts_qtr2: 0, pts_qtr3: 0, pts_qtr4: 0)
                        games.append(mGame(id: resultSet.rowSet[i][2].stringValue(), time: resultSet.rowSet[i][0].stringValue(), statusText: resultSet.rowSet[i][4].stringValue(), status:resultSet.rowSet[i][3].intValue(), awayTeamResult: awayResult, homeTeamResult: homeResult))
                        
                        print("Game result: \(awayScore![4].stringValue()) \(homeScore![4].stringValue()) \(awayScore![22].stringValue())-\(homeScore![22].stringValue())")
                    }
                    
                }
                let scoreboard = mScoreboard(gamesDate: jsonParseData.parameters.gameDate, games: games)
                self.gamesByDay[jsonParseData.parameters.gameDate] = scoreboard

            }
        /*}
        catch {
            print(error)
        }*/
        print("Preview data parsed")
        self.dataIsLoaded = true

    }
    func getGamesPerDay() -> [mGame] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"

        
        if let games = self.gamesByDay[dateFormatter.string(from: self.selectedDay)] {
            print("Games found :) for date \(dateFormatter.string(from: self.selectedDay))")
            return games.games
        }
        print("Games not found :( for date \(dateFormatter.string(from: self.selectedDay))")
        return []
    }
    func fetchCurrentWeek() {
        print ("Fecth current week")
        let today = Date()
        let calendar = Calendar.current
        (-5...2).forEach { day in
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
