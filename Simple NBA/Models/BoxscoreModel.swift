//
//  BoxscoreModel.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 10/11/2022.
//

import Foundation

struct jBoxscore: Decodable {
    var game: jGameBoxscore
}

struct jGameBoxscore: Decodable {
    var gameId: String
    var gameCode: String
    var gameStatus: Int
    var gameStatusText: String
    var homeTeam: jTeamBoxScore
    var awayTeam: jTeamBoxScore
}

struct jTeamBoxScore: Decodable {
    var teamId: Int
    var teamName: String
    var teamCity: String
    var teamTricode: String
    var score: Int
    var players: [jPlayerBoxscore]
}

struct jPlayerBoxscore: Decodable {
    var status: String
    var notPlayingReason: String?
    var notPlayingDescription: String?
    var order: Int
    var personId: Int
    var jerseyNum: String
    var position: String?
    var starter: String
    var oncourt: String
    var played: String
    var statistics: jStatisticBoxscore
    var nameI: String
}

extension jPlayerBoxscore: Identifiable {
    var id: Int { return personId }
}

struct jStatisticBoxscore: Decodable {
    var assists: Int
    var blocks: Int
    var blocksReceived: Int
    var fieldGoalsAttempted: Int
    var fieldGoalsMade: Int
    var fieldGoalsPercentage: Float
    var foulsOffensive: Int
    var foulsDrawn: Int
    var foulsPersonal: Int
    var foulsTechnical: Int
    var freeThrowsAttempted: Int
    var freeThrowsMade: Int
    var freeThrowsPercentage: Float
    var minus: Float
    var minutes: String
    var minutesCalculated: String
    var plus: Float
    var plusMinusPoints: Float
    var points: Int
    var pointsFastBreak: Int
    var pointsInThePaint: Int
    var pointsSecondChance: Int
    var reboundsDefensive: Int
    var reboundsOffensive: Int
    var reboundsTotal: Int
    var steals: Int
    var threePointersAttempted: Int
    var threePointersMade: Int
    var threePointersPercentage: Float
    var turnovers: Int
    var twoPointersAttempted: Int
    var twoPointersMade: Int
    var twoPointersPercentage: Float
}



class BoxscoreModel: ObservableObject {
    @Published var dataIsLoaded: Bool = false
    @Published var gameBoxscore: jBoxscore? = nil
    var bPreview: Bool
    var iGameId: String
    var top5away = [jPlayerBoxscore]()
    var top5home = [jPlayerBoxscore]()

    init(gameId: String, preview: Bool) {
        bPreview = preview
        iGameId = gameId
        loadJson()
    }
    
    func loadJson() {
        print ("Loading json")
        if (self.bPreview) {
            guard let pathToJsonPreview = Bundle.main.path(forResource: "boxscore", ofType: "json") else {
                print ("error: no path to json file")
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let content = try Data(contentsOf: URL(fileURLWithPath: pathToJsonPreview))
                    self.gameBoxscore = try JSONDecoder().decode(jBoxscore.self, from: content)
                    self.getTop5()
                    self.dataIsLoaded = true
                } catch {
                    print("Preview Not data loaded. Error:\(error)")
                }
            }
        }
        else {
            let endpoint = URL(string: "https://cdn.nba.com/static/json/liveData/boxscore/boxscore_\(self.iGameId).json")!
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
                        let dataFromJson = try JSONDecoder().decode(jBoxscore.self, from: content)
                        self.gameBoxscore = dataFromJson
                        self.getTop5()
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
    
    func getTop5() {
        let awayOrdered = self.gameBoxscore!.game.awayTeam.players.sorted { $0.statistics.points > $1.statistics.points }
        var count = 1
        for player in awayOrdered {
            self.top5away.append(player)
            if count >= 5 {
                break
            }
            count += 1
        }
        
        let homeOrdered = self.gameBoxscore!.game.homeTeam.players.sorted { $0.statistics.points > $1.statistics.points }
        count = 1
        for player in homeOrdered {
            self.top5home.append(player)
            if count >= 5 {
                break
            }
            count += 1
        }
    }
    
    func getMinutesPretty(minutes: String) -> String {
        return String(minutes.dropLast(4).dropFirst(2)).replacingOccurrences(of: "M", with: ":")
    }
}
