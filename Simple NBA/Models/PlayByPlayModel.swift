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
    let isFieldGoal: Int
    let isShotMade: Bool
    let isHomeShot: Bool
}



class PlayByPlay: ObservableObject {
    @Published var dataIsLoaded: Bool = false
    @Published var diffTable = [Int:Int]()
    @Published var timeArray = [Int]()

    @Published var playTable = [Int:mPlay]()
    @Published var timePlayArray = [Int]()
    
    let gameId: String
    let homeTeamTricode: String
    let bPreview: Bool
    
    // Num display lines
    var numExtraLines: Int = 0
    var numOverTime: Int = 0
    
    init(gameId: String, homeTeamTricode: String, preview: Bool) {
        print("Loading DayGames")
        self.gameId = gameId
        self.bPreview = preview
        self.homeTeamTricode = homeTeamTricode
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
            var timeFromStart = 0
            if action.period > 4 { // OT
                timeFromStart = (action.period - 4)*5*60 + 4*12*60 + (12*60 - imin*60 - isec)
            }
            else { // Regular time
                timeFromStart = (action.period - 1)*12*60 + (12*60 - imin*60 - isec)
            }
            
            var homeShot = false
            
            if (action.shotResult != nil && action.shotResult! == "Made") || (action.actionType == "period") {
                let diffScore = -(Int(action.scoreHome) ?? 0) + (Int(action.scoreAway) ?? 0)
                if abs(diffScore) > maxDiff {
                    maxDiff = abs(diffScore)
                }
                
                diffTable[timeFromStart] = diffScore
                timeArray.append(timeFromStart)
                //print("         self.diffTable[\(timeFromStart)] = \(diffScore)")
                //print("         self.timeArray.append(\(timeFromStart)")

                if self.numOverTime >= 1 {
                    print ("Action in OT \(self.numOverTime) num \(action.actionNumber) \(action.clock) \(action.period) (\(min):\(sec)) \(timeFromStart) type \(action.actionType) score \(action.scoreHome) - \(action.scoreAway) (\(diffScore))")
                }
                
                if action.teamTricode == self.homeTeamTricode {
                    homeShot = true
                }

            }
            
            
            if abs(action.period - 4) > numOverTime {
                self.numOverTime = action.period - 4
            }

            
            playTable[action.actionNumber] = mPlay(time: "\(min):\(sec)", teamTricode: action.teamTricode ?? "", scoreAway: action.scoreAway, scoreHome: action.scoreHome, description: action.description, isFieldGoal: action.isFieldGoal, isShotMade: (action.shotResult != nil && action.shotResult! == "Made") ? true : false, isHomeShot: homeShot)
            timePlayArray.append(action.actionNumber)
            
            //print ("            playTable[\(action.actionNumber)] = mPlay(time: \"\(min):\(sec)\", teamTricode: \"\(action.teamTricode ?? "")\", scoreAway: \"\(action.scoreAway)\", scoreHome: \"\(action.scoreHome)\", description: \"\(action.description)\", isFieldGoal: \(action.isFieldGoal), isShotMade: \((action.shotResult != nil && action.shotResult! == "Made") ? true : false), isHomeShot: \(homeShot))")
            //print ("            timePlayArray.append(\(action.actionNumber)) // Period \(action.period)")

        }
        self.numExtraLines = max(2, Int(abs(maxDiff)/10)+1) - 2
        print ("Playbyplpay data parsed and loaded for gameid \(jsonParseData.game.gameId) maxdiff \(maxDiff) numLines \(self.numExtraLines) numOverTime \(self.numOverTime)")
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
        873    :    -18        ,
        886    :    -28        ,
        903    :    -27        ,
        924    :    -26        ,
        957    :    -24        ,
        987    :    -22        ,
        1006    :    -15        ,
        1072    :    -12        ,
        1152    :    -7        ,
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
        12*4*60    :    7,
        12*4*60 + 5*60   :    -7]

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
        2830, 12*4*60, 12*4*60 + 5*60]
        
        self.numExtraLines = 1
        self.numOverTime = 1
        
        for dt in previewTimes {
            self.timeArray.append(dt)
            self.diffTable[dt] = previewData[dt]
        }
        
        playTable[553] = mPlay(time: "05:59", teamTricode: "PHI", scoreAway: "109", scoreHome: "98", description: "J. Harden REBOUND (Off:0 Def:3)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(553) // Period 4
        playTable[554] = mPlay(time: "05:57", teamTricode: "PHI", scoreAway: "111", scoreHome: "98", description: "T. Maxey running Layup (22 PTS) (J. Harden 9 AST)", isFieldGoal: 1, isShotMade: true, isHomeShot: false)
        timePlayArray.append(554) // Period 4
        playTable[556] = mPlay(time: "05:46", teamTricode: "LAC", scoreAway: "111", scoreHome: "98", description: "MISS N. Powell 8' driving floating Shot", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(556) // Period 4
        playTable[557] = mPlay(time: "05:45", teamTricode: "LAC", scoreAway: "111", scoreHome: "98", description: "TEAM offensive REBOUND", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(557) // Period 4
        playTable[558] = mPlay(time: "05:45", teamTricode: "PHI", scoreAway: "111", scoreHome: "98", description: "J. Embiid loose ball personal FOUL (2 PF)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(558) // Period 4
        playTable[560] = mPlay(time: "05:45", teamTricode: "LAC", scoreAway: "111", scoreHome: "98", description: "SUB out: N. Powell", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(560) // Period 4
        playTable[561] = mPlay(time: "05:45", teamTricode: "LAC", scoreAway: "111", scoreHome: "98", description: "SUB out: N. Batum", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(561) // Period 4
        playTable[562] = mPlay(time: "05:45", teamTricode: "LAC", scoreAway: "111", scoreHome: "98", description: "SUB in: M. Morris Sr.", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(562) // Period 4
        playTable[563] = mPlay(time: "05:45", teamTricode: "LAC", scoreAway: "111", scoreHome: "98", description: "SUB in: P. George", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(563) // Period 4
        playTable[564] = mPlay(time: "05:45", teamTricode: "PHI", scoreAway: "111", scoreHome: "98", description: "SUB out: G. Niang", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(564) // Period 4
        playTable[565] = mPlay(time: "05:45", teamTricode: "PHI", scoreAway: "111", scoreHome: "98", description: "SUB in: P. Tucker", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(565) // Period 4
        playTable[566] = mPlay(time: "05:31", teamTricode: "LAC", scoreAway: "111", scoreHome: "98", description: "LAC shot clock Team TURNOVER", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(566) // Period 4
        playTable[567] = mPlay(time: "05:13", teamTricode: "LAC", scoreAway: "111", scoreHome: "98", description: "M. Morris Sr. personal FOUL (2 PF) (Harden 2 FT)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(567) // Period 4
        playTable[569] = mPlay(time: "05:13", teamTricode: "PHI", scoreAway: "112", scoreHome: "98", description: "J. Harden Free Throw 1 of 2 (5 PTS)", isFieldGoal: 0, isShotMade: true, isHomeShot: false)
        timePlayArray.append(569) // Period 4
        playTable[570] = mPlay(time: "05:13", teamTricode: "PHI", scoreAway: "113", scoreHome: "98", description: "J. Harden Free Throw 2 of 2 (6 PTS)", isFieldGoal: 0, isShotMade: true, isHomeShot: false)
        timePlayArray.append(570) // Period 4
        playTable[573] = mPlay(time: "04:54", teamTricode: "LAC", scoreAway: "113", scoreHome: "98", description: "MISS T. Mann step back 3PT", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(573) // Period 4
        playTable[574] = mPlay(time: "04:50", teamTricode: "LAC", scoreAway: "113", scoreHome: "98", description: "T. Mann REBOUND (Off:2 Def:2)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(574) // Period 4
        playTable[575] = mPlay(time: "04:48", teamTricode: "LAC", scoreAway: "113", scoreHome: "98", description: "MISS P. George 25' 3PT", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(575) // Period 4
        playTable[576] = mPlay(time: "04:48", teamTricode: "LAC", scoreAway: "113", scoreHome: "98", description: "TEAM offensive REBOUND", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(576) // Period 4
        playTable[578] = mPlay(time: "04:35", teamTricode: "LAC", scoreAway: "113", scoreHome: "98", description: "MISS K. Leonard 16' pullup Shot", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(578) // Period 4
        playTable[579] = mPlay(time: "04:32", teamTricode: "PHI", scoreAway: "113", scoreHome: "98", description: "J. Embiid REBOUND (Off:2 Def:6)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(579) // Period 4
        playTable[581] = mPlay(time: "04:24", teamTricode: "LAC", scoreAway: "113", scoreHome: "98", description: "I. Zubac shooting personal FOUL (3 PF) (Embiid 2 FT)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(581) // Period 4
        playTable[583] = mPlay(time: "04:24", teamTricode: "PHI", scoreAway: "114", scoreHome: "98", description: "J. Embiid Free Throw 1 of 2 (40 PTS)", isFieldGoal: 0, isShotMade: true, isHomeShot: false)
        timePlayArray.append(583) // Period 4
        playTable[584] = mPlay(time: "04:24", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "J. Embiid Free Throw 2 of 2 (41 PTS)", isFieldGoal: 0, isShotMade: true, isHomeShot: false)
        timePlayArray.append(584) // Period 4
        playTable[585] = mPlay(time: "04:14", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "P. George bad pass out-of-bounds TURNOVER (5 TO)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(585) // Period 4
        playTable[586] = mPlay(time: "03:52", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "MISS T. Harris 27' 3PT", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(586) // Period 4
        playTable[587] = mPlay(time: "03:46", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "J. Embiid REBOUND (Off:3 Def:6)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(587) // Period 4
        playTable[588] = mPlay(time: "03:46", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "MISS J. Embiid tip DUNK", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(588) // Period 4
        playTable[589] = mPlay(time: "03:45", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "P. Tucker REBOUND (Off:2 Def:2)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(589) // Period 4
        playTable[590] = mPlay(time: "03:36", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "MISS J. Embiid 29' step back 3PT", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(590) // Period 4
        playTable[591] = mPlay(time: "03:31", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "T. Harris REBOUND (Off:1 Def:4)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(591) // Period 4
        playTable[592] = mPlay(time: "03:23", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "J. Harden backcourt TURNOVER (3 TO)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(592) // Period 4
        playTable[595] = mPlay(time: "03:16", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "PHI Timeout", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(595) // Period 4
        playTable[597] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "MISS P. George driving Layup", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(597) // Period 4
        playTable[598] = mPlay(time: "03:16", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "T. Harris REBOUND (Off:1 Def:5)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(598) // Period 4
        playTable[599] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB out: K. Leonard", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(599) // Period 4
        playTable[600] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB out: M. Morris Sr.", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(600) // Period 4
        playTable[601] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB out: P. George", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(601) // Period 4
        playTable[602] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB out: T. Mann", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(602) // Period 4
        playTable[603] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB out: I. Zubac", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(603) // Period 4
        playTable[604] = mPlay(time: "03:16", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "SUB out: P. Tucker", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(604) // Period 4
        playTable[605] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB in: J. Preston", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(605) // Period 4
        playTable[606] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB in: M. Brown", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(606) // Period 4
        playTable[607] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB in: A. Coffey", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(607) // Period 4
        playTable[608] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB in: R. Covington", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(608) // Period 4
        playTable[609] = mPlay(time: "03:16", teamTricode: "LAC", scoreAway: "115", scoreHome: "98", description: "SUB in: N. Powell", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(609) // Period 4
        playTable[610] = mPlay(time: "03:16", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "SUB in: S. Milton", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(610) // Period 4
        playTable[611] = mPlay(time: "02:56", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "MISS T. Maxey 26' 3PT", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(611) // Period 4
        playTable[612] = mPlay(time: "02:53", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "TEAM offensive REBOUND", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(612) // Period 4
        playTable[614] = mPlay(time: "02:53", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "SUB out: J. Embiid", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(614) // Period 4
        playTable[615] = mPlay(time: "02:53", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "SUB in: P. Reed", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(615) // Period 4
        playTable[616] = mPlay(time: "02:53", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "SUB out: J. Harden", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(616) // Period 4
        playTable[617] = mPlay(time: "02:53", teamTricode: "PHI", scoreAway: "115", scoreHome: "98", description: "SUB in: F. Korkmaz", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(617) // Period 4
        playTable[618] = mPlay(time: "02:51", teamTricode: "PHI", scoreAway: "117", scoreHome: "98", description: "F. Korkmaz cutting Layup (2 PTS) (T. Harris 6 AST)", isFieldGoal: 1, isShotMade: true, isHomeShot: false)
        timePlayArray.append(618) // Period 4
        playTable[620] = mPlay(time: "02:35", teamTricode: "LAC", scoreAway: "117", scoreHome: "100", description: "M. Brown DUNK (4 PTS) (J. Preston 1 AST)", isFieldGoal: 1, isShotMade: true, isHomeShot: true)
        timePlayArray.append(620) // Period 4
        playTable[622] = mPlay(time: "02:16", teamTricode: "PHI", scoreAway: "117", scoreHome: "100", description: "MISS S. Milton 12' pullup Shot", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(622) // Period 4
        playTable[623] = mPlay(time: "02:11", teamTricode: "PHI", scoreAway: "117", scoreHome: "100", description: "F. Korkmaz REBOUND (Off:1 Def:0)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(623) // Period 4
        playTable[624] = mPlay(time: "02:05", teamTricode: "LAC", scoreAway: "117", scoreHome: "100", description: "R. Covington shooting personal FOUL (3 PF) (Harris 2 FT)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(624) // Period 4
        playTable[626] = mPlay(time: "02:05", teamTricode: "PHI", scoreAway: "118", scoreHome: "100", description: "T. Harris Free Throw 1 of 2 (20 PTS)", isFieldGoal: 0, isShotMade: true, isHomeShot: false)
        timePlayArray.append(626) // Period 4
        playTable[627] = mPlay(time: "02:05", teamTricode: "PHI", scoreAway: "118", scoreHome: "100", description: "SUB out: T. Maxey", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(627) // Period 4
        playTable[628] = mPlay(time: "02:05", teamTricode: "PHI", scoreAway: "118", scoreHome: "100", description: "SUB out: S. Milton", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(628) // Period 4
        playTable[629] = mPlay(time: "02:05", teamTricode: "PHI", scoreAway: "118", scoreHome: "100", description: "SUB in: J. Springer", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(629) // Period 4
        playTable[630] = mPlay(time: "02:05", teamTricode: "PHI", scoreAway: "118", scoreHome: "100", description: "SUB in: M. Thybulle", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(630) // Period 4
        playTable[631] = mPlay(time: "02:05", teamTricode: "PHI", scoreAway: "118", scoreHome: "100", description: "MISS T. Harris Free Throw 2 of 2", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(631) // Period 4
        playTable[632] = mPlay(time: "02:03", teamTricode: "LAC", scoreAway: "118", scoreHome: "100", description: "M. Brown REBOUND (Off:1 Def:2)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(632) // Period 4
        playTable[633] = mPlay(time: "01:57", teamTricode: "PHI", scoreAway: "118", scoreHome: "100", description: "J. Springer personal FOUL (1 PF) (Powell 2 FT)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(633) // Period 4
        playTable[635] = mPlay(time: "01:57", teamTricode: "LAC", scoreAway: "118", scoreHome: "101", description: "N. Powell Free Throw 1 of 2 (9 PTS)", isFieldGoal: 0, isShotMade: true, isHomeShot: true)
        timePlayArray.append(635) // Period 4
        playTable[636] = mPlay(time: "01:57", teamTricode: "PHI", scoreAway: "118", scoreHome: "101", description: "SUB out: T. Harris", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(636) // Period 4
        playTable[637] = mPlay(time: "01:57", teamTricode: "PHI", scoreAway: "118", scoreHome: "101", description: "SUB in: D. House Jr.", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(637) // Period 4
        playTable[638] = mPlay(time: "01:57", teamTricode: "LAC", scoreAway: "118", scoreHome: "102", description: "N. Powell Free Throw 2 of 2 (10 PTS)", isFieldGoal: 0, isShotMade: true, isHomeShot: true)
        timePlayArray.append(638) // Period 4
        playTable[639] = mPlay(time: "01:43", teamTricode: "PHI", scoreAway: "118", scoreHome: "102", description: "M. Thybulle bad pass out-of-bounds TURNOVER (1 TO)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(639) // Period 4
        playTable[640] = mPlay(time: "01:34", teamTricode: "LAC", scoreAway: "118", scoreHome: "102", description: "MISS J. Preston 26' 3PT", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(640) // Period 4
        playTable[641] = mPlay(time: "01:27", teamTricode: "LAC", scoreAway: "118", scoreHome: "102", description: "R. Covington REBOUND (Off:1 Def:0)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(641) // Period 4
        playTable[642] = mPlay(time: "01:27", teamTricode: "LAC", scoreAway: "118", scoreHome: "102", description: "MISS R. Covington tip Layup", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(642) // Period 4
        playTable[643] = mPlay(time: "01:27", teamTricode: "PHI", scoreAway: "118", scoreHome: "102", description: "P. Reed REBOUND (Off:0 Def:1)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(643) // Period 4
        playTable[644] = mPlay(time: "01:20", teamTricode: "PHI", scoreAway: "120", scoreHome: "102", description: "F. Korkmaz 11' driving floating Jump Shot (4 PTS) (M. Thybulle 1 AST)", isFieldGoal: 1, isShotMade: true, isHomeShot: false)
        timePlayArray.append(644) // Period 4
        playTable[646] = mPlay(time: "01:04", teamTricode: "LAC", scoreAway: "120", scoreHome: "102", description: "N. Powell bad pass TURNOVER (3 TO)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(646) // Period 4
        playTable[647] = mPlay(time: "01:04", teamTricode: "PHI", scoreAway: "120", scoreHome: "102", description: "J. Springer STEAL (1 STL)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(647) // Period 4
        playTable[648] = mPlay(time: "01:01", teamTricode: "PHI", scoreAway: "120", scoreHome: "102", description: "MISS J. Springer running Layup", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(648) // Period 4
        playTable[649] = mPlay(time: "01:00", teamTricode: "LAC", scoreAway: "120", scoreHome: "102", description: "R. Covington REBOUND (Off:1 Def:1)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(649) // Period 4
        playTable[650] = mPlay(time: "00:53", teamTricode: "LAC", scoreAway: "120", scoreHome: "105", description: "N. Powell 25' 3PT pullup (13 PTS)", isFieldGoal: 1, isShotMade: true, isHomeShot: true)
        timePlayArray.append(650) // Period 4
        playTable[651] = mPlay(time: "00:37", teamTricode: "PHI", scoreAway: "120", scoreHome: "105", description: "MISS D. House Jr. 26' 3PT", isFieldGoal: 1, isShotMade: false, isHomeShot: false)
        timePlayArray.append(651) // Period 4
        playTable[652] = mPlay(time: "00:35", teamTricode: "LAC", scoreAway: "120", scoreHome: "105", description: "J. Preston REBOUND (Off:0 Def:1)", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(652) // Period 4
        playTable[653] = mPlay(time: "00:31", teamTricode: "LAC", scoreAway: "120", scoreHome: "108", description: "N. Powell 26' 3PT running pullup (16 PTS) (J. Preston 2 AST)", isFieldGoal: 1, isShotMade: true, isHomeShot: true)
        timePlayArray.append(653) // Period 4
        playTable[655] = mPlay(time: "00:06", teamTricode: "PHI", scoreAway: "120", scoreHome: "108", description: "PHI shot clock Team TURNOVER", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(655) // Period 4
        playTable[656] = mPlay(time: "00:00", teamTricode: "LAC", scoreAway: "120", scoreHome: "110", description: "J. Preston 17' pullup Jump Shot (2 PTS)", isFieldGoal: 1, isShotMade: true, isHomeShot: true)
        timePlayArray.append(656) // Period 4
        playTable[657] = mPlay(time: "00:00", teamTricode: "", scoreAway: "120", scoreHome: "110", description: "Period End", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(657) // Period 4
        playTable[658] = mPlay(time: "00:00", teamTricode: "", scoreAway: "120", scoreHome: "110", description: "Game End", isFieldGoal: 0, isShotMade: false, isHomeShot: false)
        timePlayArray.append(658) // Period 4
        
        self.dataIsLoaded = true
        print ("Loaded preview data for playbyplay")
    }
}
