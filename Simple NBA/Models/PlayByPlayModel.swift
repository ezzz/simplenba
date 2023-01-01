//
//  PlayByPlayModel.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 06/12/2022.
//

import Foundation

struct jPlayByPlay: Codable {
    let game: jGamePbp
}

struct jGamePbp: Codable {
    let gameId: String
    let actions: [jAction]
}

struct jAction: Codable {
    let actionNumber: Int
    let clock: String
    let period: Int
    let teamTricode: String?
    let actionType: String
    let subType: String
    let scoreHome: String
    let scoreAway: String
    let description: String
    let isFieldGoal: Int
    let shotResult: String?
}



// MARK: - Struct from internal model
struct mPlay {
    let time: String
    let teamTricode: String
    let scoreAway: String
    let scoreHome: String
    let description: String
}



class PlayByPlay: ObservableObject {
    @Published var dataIsLoaded: Bool = false
    @Published var diffTable = [Int:Int]()
    @Published var timeArray = [Int]()

    @Published var playTable = [Int:mPlay]()
    @Published var timePlayArray = [Int]()

    let gameId: String
    let bPreview: Bool
    var numSections = 2
    
    init(gameId: String, preview: Bool) {
        print("Loading DayGames")
        self.gameId = gameId
        self.bPreview = preview
        if preview {
            loadPreview()
        } else {
            loadJson()
        }
    }
    
    func loadJson() {
        print("Loading playbyplay json for gameid \(gameId)")
        
        if (self.bPreview) {
            guard let pathToJsonPreview = Bundle.main.path(forResource: "playbyplay", ofType: "json") else {
                print ("error: no path to json file")
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let content = try Data(contentsOf: URL(fileURLWithPath: pathToJsonPreview))
                    let dataFromJson = try JSONDecoder().decode(jPlayByPlay.self, from: content)
                    print ("(preview) Loaded playbyplay for \(dataFromJson.game.gameId)")
                    self.parsePlayByPlay(jsonParseData:dataFromJson)
                } catch {
                    print("Preview Not data loaded:\(error)")
                }
            }
        }
        else {
            let endpoint = URL(string: "https://cdn.nba.com/static/json/liveData/playbyplay/playbyplay_\(gameId).json")!
            print("Get playbyplay data from \(endpoint)")
            var request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            //request.setValue("x-nba-stats-origin", forHTTPHeaderField: "x-nba-stats-origin")
            
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
                        let dataFromJson = try JSONDecoder().decode(jPlayByPlay.self, from: content)
                        print ("Loaded playbyplay for \(dataFromJson.game.gameId)")
                        self.parsePlayByPlay(jsonParseData:dataFromJson)
                    } catch {
                        print(error)
                    }
                }
                print("Data loaded")
            }
            task.resume()
        }
    }
    
    func parsePlayByPlay(jsonParseData: jPlayByPlay) {
        print ("Parsing playbyplpay data for gameid\(jsonParseData.game.gameId)")
        var maxDiff = 0
        for action in jsonParseData.game.actions {
            let min = action.clock.suffix(9).prefix(2)
            let sec = action.clock.suffix(6).prefix(2)
            let imin = Int(min) ?? 0
            let isec = Int(sec) ?? 0
            let timeFromStart = (action.period - 1)*12*60 + (12*60 - imin*60 - isec)

            if (action.isFieldGoal == 1 && action.shotResult! == "Made") || (action.actionType == "period") {
                let diffScore = -(Int(action.scoreHome) ?? 0) + (Int(action.scoreAway) ?? 0)
                if abs(diffScore) > maxDiff {
                    maxDiff = diffScore
                }
                
                //print ("Action \(action.actionNumber) \(action.clock) \(action.period) (\(min):\(sec)) \(timeFromStart) type \(action.actionType) score \(action.scoreHome) - \(action.scoreAway) (\(diffScore))")
                diffTable[timeFromStart] = diffScore
                timeArray.append(timeFromStart)
            }

            playTable[timeFromStart] = mPlay(time: "\(min):\(sec)", teamTricode: action.teamTricode ?? "", scoreAway: action.scoreAway, scoreHome: action.scoreHome, description: action.description)
            timePlayArray.append(timeFromStart)
            
            print ("            playTable[\(timeFromStart)] = mPlay(time: \"\(min):\(sec)\", teamTricode: \"\(action.teamTricode ?? "")\" ?? \"\", scoreAway: \"\(action.scoreAway)\", scoreHome: \"\(action.scoreHome)\", description: \"\(action.description)\")")
            print ("            timePlayArray.append(\(timeFromStart))")

        }
        self.numSections = min(2, Int(maxDiff/10))
        print ("Playbyplpay data parsed and loaded for gameid\(jsonParseData.game.gameId)")
        self.dataIsLoaded = true

    }
 
    func loadPreview() {
        let previewData = [0    :    0        ,21    :    2        ,
        50    :    4        ,
        71    :    1        ,
        107    :    -1        ,
        145    :    1        ,
        156    :    -2        ,
        172    :    0        ,
        197    :    2        ,
        281    :    -2        ,
        315    :    0        ,
        379    :    -1        ,
        420    :    1        ,
        448    :    3        ,
        476    :    5        ,
        493    :    2        ,
        515    :    0        ,
        563    :    2        ,
        577    :    0        ,
        598    :    1        ,
        657    :    -1        ,
        685    :    -4        ,
        768    :    -6        ,
        833    :    -8        ,
        856    :    -10        ,
        873    :    -8        ,
        886    :    -10        ,
        903    :    -7        ,
        924    :    -6        ,
        957    :    -4        ,
        987    :    -2        ,
        1006    :    -5        ,
        1072    :    -2        ,
        1152    :    -4        ,
        1165    :    -1        ,
        1192    :    -3        ,
        1220    :    -1        ,
        1240    :    -3        ,
        1285    :    -3        ,
        1301    :    -6        ,
        1363    :    -9        ,
        1384    :    -6        ,
        1424    :    -4        ,
        1571    :    -7        ,
        1596    :    -5        ,
        1644    :    -3        ,
        1732    :    -6        ,
        1790    :    -6        ,
        1807    :    -3        ,
        1861    :    -5        ,
        1897    :    -6        ,
        1940    :    -4        ,
        1961    :    -2        ,
        1998    :    -4        ,
        2025    :    -2        ,
        2123    :    0        ,
        2159    :    -1        ,
        2194    :    -4        ,
        2231    :    -1        ,
        2257    :    -3        ,
        2268    :    -1        ,
        2366    :    -3        ,
        2387    :    -1        ,
        2427    :    1        ,
        2518    :    -1        ,
        2537    :    1        ,
        2569    :    4        ,
        2751    :    7        ,
        2830    :    7,
        12*4*60    :    7]

        let previewTimes = [0, 21    ,
        50    ,
        71    ,
        107    ,
        145    ,
        156    ,
        172    ,
        197    ,
        281    ,
        315    ,
        379    ,
        420    ,
        448    ,
        476    ,
        493    ,
        515    ,
        563    ,
        577    ,
        598    ,
        657    ,
        685    ,
        768    ,
        833    ,
        856    ,
        873    ,
        886    ,
        903    ,
        924    ,
        957    ,
        987    ,
        1006    ,
        1072    ,
        1152    ,
        1165    ,
        1192    ,
        1220    ,
        1240    ,
        1285    ,
        1301    ,
        1363    ,
        1384    ,
        1424    ,
        1571    ,
        1596    ,
        1644    ,
        1732    ,
        1790    ,
        1807    ,
        1861    ,
        1897    ,
        1940    ,
        1961    ,
        1998    ,
        2025    ,
        2123    ,
        2159    ,
        2194    ,
        2231    ,
        2257    ,
        2268    ,
        2366    ,
        2387    ,
        2427    ,
        2518    ,
        2537    ,
        2569    ,
        2751    ,
        2830, 12*4*60]
        
        for dt in previewTimes {
            self.timeArray.append(dt)
            self.diffTable[dt] = previewData[dt]
        }
        
        self.playTable[0] = mPlay(time: "12:00", teamTricode: "", scoreAway: "0", scoreHome: "0", description: "Period Start")
        self.timePlayArray.append(0)
        self.playTable[4] = mPlay(time: "11:56", teamTricode: "ORL", scoreAway: "0", scoreHome: "0", description: "Jump Ball B. Bol vs. D. Powell: Tip to W. Carter Jr.")
        self.timePlayArray.append(4)
        self.playTable[21] = mPlay(time: "11:39", teamTricode: "ORL", scoreAway: "0", scoreHome: "2", description: "W. Carter Jr. driving Hook (2 PTS)")
        self.timePlayArray.append(21)
        self.playTable[39] = mPlay(time: "11:21", teamTricode: "DAL", scoreAway: "0", scoreHome: "2", description: "MISS L. Doncic 16' step back Shot")
        self.timePlayArray.append(39)
        self.playTable[42] = mPlay(time: "11:18", teamTricode: "ORL", scoreAway: "0", scoreHome: "2", description: "J. Suggs REBOUND (Off:0 Def:1)")
        self.timePlayArray.append(42)
        self.playTable[50] = mPlay(time: "11:10", teamTricode: "ORL", scoreAway: "0", scoreHome: "4", description: "F. Wagner driving Layup (2 PTS) (J. Suggs 1 AST)")
        self.timePlayArray.append(50)
        self.playTable[71] = mPlay(time: "10:49", teamTricode: "DAL", scoreAway: "3", scoreHome: "4", description: "S. Dinwiddie 26' 3PT  (3 PTS) (L. Doncic 1 AST)")
        self.timePlayArray.append(71)
        self.playTable[91] = mPlay(time: "10:29", teamTricode: "ORL", scoreAway: "3", scoreHome: "4", description: "F. Wagner lost ball TURNOVER (1 TO)")
        self.timePlayArray.append(91)

        
        self.dataIsLoaded = true
        print ("Loaded preview data for playbyplay")
    }
}
