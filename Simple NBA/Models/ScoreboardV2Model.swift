//
//  ScoreboardV2.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 02/11/2022.
//

import SwiftUI

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
    var colorAway, colorHome: Color?
}

class mTeamGameResult {
    let id : Int
    let teamTricode, teamName, teamWinsLoss: String
    let pts, pts_qtr1, pts_qtr2, pts_qtr3, pts_qtr4: Int
    let nb_ot, pts_ot1, pts_ot2, pts_ot3, pts_ot4, pts_ot5, pts_ot6, pts_ot7, pts_ot8, pts_ot9, pts_ot10: Int
    let fg_pct, ft_pct, fg3_pct: Double
    let ast, reb, tov: Int
    var isbest_fg_pct, isbest_ft_pct, isbest_fg3_pct, isbest_ast, isbest_reb, isbest_tov: Bool
    var leadPts, leadReb, leadAst : Int?
    var leadPtsName, leadRebName, leadAstName : String?

    init(id: Int, teamTricode: String, teamName: String, teamWinsLoss: String, pts_qtr1: Int, pts_qtr2: Int, pts_qtr3: Int, pts_qtr4: Int,
         nb_ot: Int, pts_ot1: Int, pts_ot2: Int, pts_ot3: Int, pts_ot4: Int, pts_ot5: Int, pts_ot6: Int, pts_ot7: Int, pts_ot8: Int, pts_ot9: Int, pts_ot10: Int,
         pts: Int, fg_pct: Double, ft_pct:Double, fg3_pct:Double, ast:Int, reb:Int, tov:Int) {
        self.id = id
        self.teamTricode = teamTricode
        self.teamName = teamName
        self.teamWinsLoss = teamWinsLoss
        self.pts = pts
        self.pts_qtr1 = pts_qtr1
        self.pts_qtr2 = pts_qtr2
        self.pts_qtr3 = pts_qtr3
        self.pts_qtr4 = pts_qtr4
        self.nb_ot = nb_ot
        self.pts_ot1 = pts_ot1
        self.pts_ot2 = pts_ot2
        self.pts_ot3 = pts_ot3
        self.pts_ot4 = pts_ot4
        self.pts_ot5 = pts_ot5
        self.pts_ot6 = pts_ot6
        self.pts_ot7 = pts_ot7
        self.pts_ot8 = pts_ot8
        self.pts_ot9 = pts_ot9
        self.pts_ot10 = pts_ot10
        self.fg_pct = fg_pct
        self.ft_pct = ft_pct
        self.fg3_pct = fg3_pct
        self.ast = ast
        self.reb = reb
        self.tov = tov
        isbest_fg_pct = false
        isbest_ft_pct = false
        isbest_fg3_pct = false
        isbest_ast = false
        isbest_reb = false
        isbest_tov = false
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
        print ("SelectedStringDay \(selectedStringDay) +1 \(formatter.string(from: selectedDayPlus1)) -1 \(formatter.string(from: selectedDayMinus1))")
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
    
    func reloadTodayAsync() async {
        do {
            
            print("ReloadTodayAsync for date \(selectedStringDay)")
            let endpoint = URL(string: "https://stats.nba.com/stats/scoreboardv2?GameDate=\(selectedStringDay)&LeagueID=00&DayOffset=0")!
            var request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.setValue("x-nba-stats-origin", forHTTPHeaderField: "x-nba-stats-origin")
            let (content, _) = try await URLSession.shared.data(for: request)
            let dataFromJson = try JSONDecoder().decode(jScoreboardV2.self, from: content)
            
            print ("ReloadTodayAsync Scoreboard for \(dataFromJson.parameters.gameDate)")
            self.parseGames(jsonParseData:dataFromJson, forStringDate: selectedStringDay)
            print("ReloadTodayAsync -> data loaded :)")
        }
        catch {
            // TODO: do some error handling
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
                    
                    // Calculate nb of overtime
                    var nb_ot = 0
                    var index = 12
                    var points_ot = 0
                    repeat {
                        points_ot = awayScore![12].intValue() + homeScore![12].intValue()
                        if points_ot > 0 {
                            nb_ot += 1
                        }
                    }
                    while points_ot > 0 || index == 21
                            
                    let awayResult = mTeamGameResult(id: homeTeamId,
                                                     teamTricode: awayScore![4].stringValue(),
                                                     teamName: awayScore![6].stringValue(),
                                                     teamWinsLoss: awayScore![7].stringValue(),
                                                     pts_qtr1: awayScore![8].intValue(),
                                                     pts_qtr2: awayScore![9].intValue(),
                                                     pts_qtr3: awayScore![10].intValue(),
                                                     pts_qtr4: awayScore![11].intValue(),
                                                     nb_ot: nb_ot,
                                                     pts_ot1: awayScore![12].intValue(),
                                                     pts_ot2: awayScore![13].intValue(),
                                                     pts_ot3: awayScore![14].intValue(),
                                                     pts_ot4: awayScore![15].intValue(),
                                                     pts_ot5: awayScore![16].intValue(),
                                                     pts_ot6: awayScore![17].intValue(),
                                                     pts_ot7: awayScore![18].intValue(),
                                                     pts_ot8: awayScore![19].intValue(),
                                                     pts_ot9: awayScore![20].intValue(),
                                                     pts_ot10: awayScore![21].intValue(),
                                                     pts: awayScore![22].intValue(),
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
                                                     pts_qtr1: homeScore![8].intValue(),
                                                     pts_qtr2: homeScore![9].intValue(),
                                                     pts_qtr3: homeScore![10].intValue(),
                                                     pts_qtr4: homeScore![11].intValue(),
                                                     nb_ot: nb_ot,
                                                     pts_ot1: homeScore![12].intValue(),
                                                     pts_ot2: homeScore![13].intValue(),
                                                     pts_ot3: homeScore![14].intValue(),
                                                     pts_ot4: homeScore![15].intValue(),
                                                     pts_ot5: homeScore![16].intValue(),
                                                     pts_ot6: homeScore![17].intValue(),
                                                     pts_ot7: homeScore![18].intValue(),
                                                     pts_ot8: homeScore![19].intValue(),
                                                     pts_ot9: homeScore![20].intValue(),
                                                     pts_ot10: homeScore![21].intValue(),
                                                     pts: homeScore![22].intValue(),
                                                     fg_pct:homeScore![23].doubleValue(),
                                                     ft_pct:homeScore![24].doubleValue(),
                                                     fg3_pct:homeScore![25].doubleValue(),
                                                     ast:homeScore![26].intValue(),
                                                     reb:homeScore![27].intValue(),
                                                     tov:homeScore![28].intValue())


                    var game = mGame(id: resultSet.rowSet[i][2].stringValue(), time: resultSet.rowSet[i][0].stringValue(), statusText: resultSet.rowSet[i][4].stringValue(), arenaName: resultSet.rowSet[i][15].stringValue(), status:resultSet.rowSet[i][3].intValue(), awayTeamResult: awayResult, homeTeamResult: homeResult)

                    setColorsForTeams(game: &game)
                    setBestStatsForTeams(game: &game)
                    
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
    
    func updateSelectedDay(dayOffset:Int, reloadJson: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        let startDate = self.selectedDay
        self.selectedDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
        self.selectedDayPlus1 = Calendar.current.date(byAdding: .day, value: dayOffset+1, to: startDate)!
        self.selectedDayMinus1 = Calendar.current.date(byAdding: .day, value: dayOffset-1, to: startDate)!
        
        print ("updateSelectedDay> startDate \(formatter.string(from: startDate)) offset \(dayOffset) / -1 \(dayOffset-1) result \(formatter.string(from: self.selectedDayMinus1))")
        
        self.selectedStringDay = self.getStringDate(date:self.selectedDay)


        if reloadJson || !self.gamesByDay.keys.contains(self.selectedStringDay) {
            self.loadJson(gamesDateString: self.selectedStringDay)
        }
    }
    
    func setColorsForTeams(game: inout mGame) {
        let cAway1 = Color("\(game.awayTeamResult.teamTricode)1")
        let cAway2 = Color("\(game.awayTeamResult.teamTricode)2")
        let cHome1 = Color("\(game.homeTeamResult.teamTricode)1")
        let cHome2 = Color("\(game.homeTeamResult.teamTricode)2")

        let cd11 = getColorDistance(color1: cHome1, color2: cAway1)
        let cd12 = getColorDistance(color1: cHome1, color2: cAway2)
        let cd21 = getColorDistance(color1: cHome2, color2: cAway1)
        let cd22 = getColorDistance(color1: cHome2, color2: cAway2)

        print("Color distance \(cd11) \(cd12) \(cd21) \(cd22) ?")

        if cd11 > cd12 && cd11 > cd21 && cd11 > cd22 {
            game.colorAway = cAway1
            game.colorHome = cHome1
        }
        else if cd12 > cd11 && cd12 > cd21 && cd12 > cd22 {
            game.colorAway = cAway1
            game.colorHome = cHome2
        }
        else if cd21 > cd11 && cd21 > cd12 && cd21 > cd22 {
            game.colorAway = cAway2
            game.colorHome = cHome1
        }
        else {
            game.colorAway = cAway2
            game.colorHome = cHome2
        }
    }
    
    func getColorDistance(color1: Color, color2: Color) -> CGFloat {
        let uic1 = UIColor(color1)
        let uic2 = UIColor(color2)

        let red = (uic1.cgColor.components![0] - uic2.cgColor.components![0])
        let green = (uic1.cgColor.components![1] - uic2.cgColor.components![1])
        let blue = (uic1.cgColor.components![2] - uic2.cgColor.components![2])
        
        return red*red+green*green+blue*blue
    }

    func setBestStatsForTeams(game: inout mGame) {
        if game.awayTeamResult.fg_pct > game.homeTeamResult.fg_pct {
            game.awayTeamResult.isbest_fg_pct = true
        }
        else if game.awayTeamResult.fg_pct < game.homeTeamResult.fg_pct {
            game.homeTeamResult.isbest_fg_pct = true
        }
        
        if game.awayTeamResult.fg3_pct > game.homeTeamResult.fg3_pct {
            game.awayTeamResult.isbest_fg3_pct = true
        }
        else if game.awayTeamResult.fg3_pct < game.homeTeamResult.fg3_pct {
            game.homeTeamResult.isbest_fg3_pct = true
        }
        
        if game.awayTeamResult.ft_pct > game.homeTeamResult.ft_pct {
            game.awayTeamResult.isbest_ft_pct = true
        }
        else if game.awayTeamResult.ft_pct < game.homeTeamResult.ft_pct {
            game.homeTeamResult.isbest_ft_pct = true
        }
        
        if game.awayTeamResult.reb > game.homeTeamResult.reb {
            game.awayTeamResult.isbest_reb = true
        }
        else if game.awayTeamResult.reb < game.homeTeamResult.reb {
            game.homeTeamResult.isbest_reb = true
        }
        
        if game.awayTeamResult.ast > game.homeTeamResult.ast {
            game.awayTeamResult.isbest_ast = true
        }
        else if game.awayTeamResult.ast < game.homeTeamResult.ast {
            game.homeTeamResult.isbest_ast = true
        }
        
        if game.awayTeamResult.tov < game.homeTeamResult.tov {
            game.awayTeamResult.isbest_tov = true
        }
        else if game.awayTeamResult.tov > game.homeTeamResult.tov {
            game.homeTeamResult.isbest_tov = true
        }
    }
    
    func getPreviewGame() -> mGame {
        var awayResult = mTeamGameResult(id: 1, teamTricode: "GSW", teamName: "Warriors", teamWinsLoss: "7-2", pts_qtr1: 26, pts_qtr2: 33, pts_qtr3: 23, pts_qtr4: 20, nb_ot: 2, pts_ot1: 21, pts_ot2: 22, pts_ot3: 0, pts_ot4: 0, pts_ot5: 0, pts_ot6: 0, pts_ot7: 0, pts_ot8: 0, pts_ot9: 0, pts_ot10: 0, pts: 102, fg_pct:0.487, ft_pct:0.887, fg3_pct:0.32, ast:24, reb:35, tov:16)
        awayResult.leadPts = 35
        awayResult.leadReb = 18
        awayResult.leadAst = 12
        awayResult.leadPtsName = "Giannis Antetokounmpo"
        awayResult.leadRebName = "Trae Young"
        awayResult.leadAstName = "Trae Young"
        
        var homeResult = mTeamGameResult(id: 2, teamTricode: "CLE", teamName: "Cavaliers", teamWinsLoss: "7-2", pts_qtr1: 38, pts_qtr2: 26, pts_qtr3: 21, pts_qtr4: 29, nb_ot: 2, pts_ot1: 11, pts_ot2: 12, pts_ot3: 0, pts_ot4: 0, pts_ot5: 0, pts_ot6: 0, pts_ot7: 0, pts_ot8: 0, pts_ot9: 0, pts_ot10: 0, pts: 123, fg_pct:0.437, ft_pct:0.87, fg3_pct:0.37, ast:22, reb:32, tov:16)
        homeResult.leadPts = 35
        homeResult.leadReb = 18
        homeResult.leadAst = 12
        homeResult.leadPtsName = "home player"
        homeResult.leadRebName = "Trae Young"
        homeResult.leadAstName = "Trae Young"
        
        var game = mGame(id: "12", time: "07:00 pm ET", statusText: "Final", arenaName: "Rocket Mortgage FieldHouse", status:1, awayTeamResult: awayResult, homeTeamResult: homeResult)
        game.colorAway = Color("GSW1")
        game.colorHome = Color("HOU1")
        
        setBestStatsForTeams(game: &game)
        
        return game
    }
}

extension Color {
 
    func uiColor() -> UIColor {

        if #available(iOS 14.0, *) {
            return UIColor(self)
        }

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {

        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
}

