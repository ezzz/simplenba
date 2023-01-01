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
        
    func doubleValue()->Double {
        switch self {
        case .int:
            return 0
        case .double(let x):
            return x
        case .string:
            return 0
        case .null:
            return 0
        }
    }
        
}

// MARK: - Struct from internal model
struct mScoreboard {
    var isLoaded = false
    let gamesDate: String
    let games: [mGame]
}

struct mGame : Identifiable {
    let id, time, statusText, arenaName: String
    let status: Int
    var awayTeamResult, homeTeamResult: mTeamGameResult
    var diff_qtr1, diff_qtr2, diff_qtr3, diff_qtr4, diff_ft: Int?
}

class mTeamGameResult {
    let id : Int
    let teamTricode, teamName, teamWinsLoss: String
    let pts, pts_qtr1, pts_qtr2, pts_qtr3, pts_qtr4, pts_ot: Int
    let fg_pct, ft_pct, fg3_pct: Double
    let ast, reb, tov: Int
    var leadPts, leadReb, leadAst : Int?
    var leadPtsName, leadRebName, leadAstName : String?

    init(id: Int, teamTricode: String, teamName: String, teamWinsLoss: String, pts: Int, pts_qtr1: Int, pts_qtr2: Int, pts_qtr3: Int, pts_qtr4: Int, pts_ot: Int, fg_pct: Double, ft_pct:Double, fg3_pct:Double, ast:Int, reb:Int, tov:Int) {
        self.id = id
        self.teamTricode = teamTricode
        self.teamName = teamName
        self.teamWinsLoss = teamWinsLoss
        self.pts = pts
        self.pts_qtr1 = pts_qtr1
        self.pts_qtr2 = pts_qtr2
        self.pts_qtr3 = pts_qtr3
        self.pts_qtr4 = pts_qtr4
        self.pts_ot = pts_ot
        self.fg_pct = fg_pct
        self.ft_pct = ft_pct
        self.fg3_pct = fg3_pct
        self.ast = ast
        self.reb = reb
        self.tov = tov
    }
}


class DayGames: ObservableObject {
    var bPreview: Bool
    
    @Published var gamesByDay = [String: mScoreboard]()
    @Published var selectedDay: Date
    @Published var selectedDayPlus1: Date
    @Published var selectedDayMinus1: Date
    @Published var selectedStringDay: String
    
    init(preview: Bool) {
        print("Loading DayGames")
        bPreview = preview
        let today = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        selectedDay = today
        selectedDayPlus1 = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        selectedDayMinus1 = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        selectedStringDay = formatter.string(from: today)
        loadJson(gamesDateString: selectedStringDay)
        if !bPreview {
            //loadJson(gamesDate:Calendar.current.date(byAdding: .day, value: 1, to: self.selectedDay)!)
            //loadJson(gamesDate:Calendar.current.date(byAdding: .day, value: -1, to: self.selectedDay)!)
        }
    }
    
    func loadJson(gamesDateString: String) {
        print("Loading json for date \(gamesDateString)")
        
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
                    self.parseGames(jsonParseData:dataFromJson, forStringDate: gamesDateString)
                } catch {
                    print("Preview Not data loaded:\(error)")
                }
            }
        }
        else {
            let endpoint = URL(string: "https://stats.nba.com/stats/scoreboardv2?GameDate=\(gamesDateString)&LeagueID=00&DayOffset=0")!
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
                        self.parseGames(jsonParseData:dataFromJson, forStringDate: gamesDateString)
                        
                    } catch {
                        print(error)
                    }
                }
                print("Data loaded")
            }
            task.resume()
        }
    }
    
    func parseGames(jsonParseData: jScoreboardV2, forStringDate: String) {
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
                    let awayResult = mTeamGameResult(id: homeTeamId,
                                                     teamTricode: awayScore![4].stringValue(),
                                                     teamName: awayScore![6].stringValue(),
                                                     teamWinsLoss: awayScore![7].stringValue(),
                                                     pts: awayScore![22].intValue(),
                                                     pts_qtr1: awayScore![8].intValue(),
                                                     pts_qtr2: awayScore![9].intValue(),
                                                     pts_qtr3: awayScore![10].intValue(),
                                                     pts_qtr4: awayScore![11].intValue(),
                                                     pts_ot: awayScore![12].intValue() + awayScore![13].intValue() + awayScore![14].intValue() + awayScore![15].intValue() + awayScore![16].intValue() + awayScore![17].intValue() + awayScore![18].intValue() + awayScore![18].intValue() + awayScore![19].intValue() + awayScore![20].intValue() + awayScore![21].intValue(),
                                                     fg_pct:awayScore![23].doubleValue(),
                                                     ft_pct:awayScore![24].doubleValue(),
                                                     fg3_pct:awayScore![25].doubleValue(),
                                                     ast:awayScore![26].intValue(),
                                                     reb:awayScore![27].intValue(),
                                                     tov:awayScore![28].intValue())
                    let homeResult = mTeamGameResult(id: awayTeamId,
                                                     teamTricode: homeScore![4].stringValue(),
                                                     teamName: homeScore![6].stringValue(),
                                                     teamWinsLoss: homeScore![7].stringValue(),
                                                     pts: homeScore![22].intValue(),
                                                     pts_qtr1: homeScore![8].intValue(),
                                                     pts_qtr2: homeScore![9].intValue(),
                                                     pts_qtr3: homeScore![10].intValue(),
                                                     pts_qtr4: homeScore![11].intValue(),
                                                     pts_ot: homeScore![12].intValue() + homeScore![13].intValue() + homeScore![14].intValue() + homeScore![15].intValue() + homeScore![16].intValue() + homeScore![17].intValue() + homeScore![18].intValue() + homeScore![18].intValue() + homeScore![19].intValue() + homeScore![20].intValue() + homeScore![21].intValue(),
                                                     fg_pct:homeScore![23].doubleValue(),
                                                     ft_pct:homeScore![24].doubleValue(),
                                                     fg3_pct:homeScore![25].doubleValue(),
                                                     ast:homeScore![26].intValue(),
                                                     reb:homeScore![27].intValue(),
                                                     tov:homeScore![28].intValue())


                    var game = mGame(id: resultSet.rowSet[i][2].stringValue(), time: resultSet.rowSet[i][0].stringValue(), statusText: resultSet.rowSet[i][4].stringValue(), arenaName: resultSet.rowSet[i][15].stringValue(), status:resultSet.rowSet[i][3].intValue(), awayTeamResult: awayResult, homeTeamResult: homeResult)

                    print("Calculating diff per quarter")
                    game.diff_qtr1 = awayResult.pts_qtr1 - homeResult.pts_qtr1
                    game.diff_qtr2 = awayResult.pts_qtr2 - homeResult.pts_qtr2
                    game.diff_qtr3 = awayResult.pts_qtr3 - homeResult.pts_qtr3
                    game.diff_qtr4 = awayResult.pts_qtr4 - homeResult.pts_qtr4
                    game.diff_ft = awayResult.pts - homeResult.pts
                    games.append(game)

                    
                    
                    
                    print("Game result: \(awayScore![4].stringValue()) \(homeScore![4].stringValue()) \(awayScore![22].stringValue())-\(homeScore![22].stringValue())")
                    
                    
                }
                
            }
            else if resultSet.name == "TeamLeaders" {
                print("Found Team leaders")
                for i in 0 ..< resultSet.rowSet.count {
                    let gameId = resultSet.rowSet[i][0].stringValue()
                    let teamId = resultSet.rowSet[i][1].intValue()
                    if var game = games.first(where: { $0.id == gameId}) {
                        if game.awayTeamResult.id == teamId {
                            game.awayTeamResult.leadPts = resultSet.rowSet[i][7].intValue()
                            game.awayTeamResult.leadReb = resultSet.rowSet[i][10].intValue()
                            game.awayTeamResult.leadAst = resultSet.rowSet[i][13].intValue()
                            game.awayTeamResult.leadPtsName = resultSet.rowSet[i][6].stringValue()
                            game.awayTeamResult.leadRebName = resultSet.rowSet[i][9].stringValue()
                            game.awayTeamResult.leadAstName = resultSet.rowSet[i][12].stringValue()
                            print("For instance \(game.awayTeamResult.leadPtsName) leads points with \(game.awayTeamResult.leadPts) pts")
                        }
                        else if game.homeTeamResult.id == teamId {
                            game.homeTeamResult.leadPts = resultSet.rowSet[i][7].intValue()
                            game.homeTeamResult.leadReb = resultSet.rowSet[i][10].intValue()
                            game.homeTeamResult.leadAst = resultSet.rowSet[i][13].intValue()
                            game.homeTeamResult.leadPtsName = resultSet.rowSet[i][6].stringValue()
                            game.homeTeamResult.leadRebName = resultSet.rowSet[i][9].stringValue()
                            game.homeTeamResult.leadAstName = resultSet.rowSet[i][12].stringValue()
                        }
                    }
                }
            }
            var scoreboard = mScoreboard(gamesDate: jsonParseData.parameters.gameDate, games: games)
            scoreboard.isLoaded = true
            self.gamesByDay[forStringDate] = scoreboard
            print("Data for date \(forStringDate) isLoaded \(self.gamesByDay[forStringDate]!.isLoaded)")
        }
    }
    
    func extractDate(date:Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func getStringDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
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
    
    /*func getIndexFromSelectedDay() -> Int {
     let index = Calendar.current.dateComponents([.day], from: availableDays.keys.first!, to: selectedDay).day!
     return index
     }*/
    
    func updateSelectedDay(dayOffset:Int) {
        self.selectedDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: self.selectedDay)!
        self.selectedDayPlus1 = Calendar.current.date(byAdding: .day, value: 1, to: self.selectedDay)!
        self.selectedDayMinus1 = Calendar.current.date(byAdding: .day, value: -1, to: self.selectedDay)!
        self.selectedStringDay = self.getStringDate(date:self.selectedDay)
        if !self.gamesByDay.keys.contains(self.selectedStringDay) {
            self.loadJson(gamesDateString: self.selectedStringDay)
        }
    }
    
    func getPreviewGame() -> mGame {
        var awayResult = mTeamGameResult(id: 1, teamTricode: "GSW", teamName: "Warriors", teamWinsLoss: "7-2", pts: 102, pts_qtr1: 26, pts_qtr2: 33, pts_qtr3: 23, pts_qtr4: 20, pts_ot: 0, fg_pct:0.437, ft_pct:0.887, fg3_pct:0.32, ast:24, reb:35, tov:16)
        awayResult.leadPts = 35
        awayResult.leadReb = 18
        awayResult.leadAst = 12
        awayResult.leadPtsName = "Giannis Antetokounmpo"
        awayResult.leadRebName = "Trae Young"
        awayResult.leadAstName = "Trae Young"

        var homeResult = mTeamGameResult(id: 2, teamTricode: "CLE", teamName: "Cavaliers", teamWinsLoss: "7-2", pts: 123, pts_qtr1: 38, pts_qtr2: 26, pts_qtr3: 21, pts_qtr4: 29, pts_ot: 0, fg_pct:0.437, ft_pct:0.887, fg3_pct:0.32, ast:24, reb:35, tov:16)
        homeResult.leadPts = 35
        homeResult.leadReb = 18
        homeResult.leadAst = 12
        homeResult.leadPtsName = "home player"
        homeResult.leadRebName = "Trae Young"
        homeResult.leadAstName = "Trae Young"

        return mGame(id: "12", time: "07:00 pm ET", statusText: "Final", arenaName: "Rocket Mortgage FieldHouse", status:1, awayTeamResult: awayResult, homeTeamResult: homeResult)
    }
}
