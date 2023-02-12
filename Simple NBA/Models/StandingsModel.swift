//
//  StandingsModel.swift
//  Simple NBA
//
//  Created by Bruno ARENE on 28/01/2023.
//

import Foundation

import SwiftUI

// MARK: - ScoreboardV2
struct jStandingsV2: Codable {
    let resource: String
    let parameters: jParametersStandings
    let resultSets: [ResultSetStandings]
}

// MARK: - Parameters
struct jParametersStandings: Codable {
    let SeasonYear, SeasonType : String
}

// MARK: - ResultSet
struct ResultSetStandings: Codable {
    let name: String
    let headers: [String]
    let rowSet: [[RowSet]]
}

// MARK: - Struct from internal model
struct mStandings {
    var isLoaded = false
    var westConferenceStandings: [mTeamStanding] = []
    var eastConferenceStandings: [mTeamStanding] = []
}

struct mTeamStanding : Identifiable {
    let id, name, record, currenStreak, leagueRank, winPct, gb, last10, pointsAtt, pointsDef: String
}

class Standings: ObservableObject {
    @Published var standings = mStandings(isLoaded: false)
    
    init() {
        print("Loading Standings")
        loadJson()
    }
    
    func loadJson() {
        print("Standings - Loading json for standings")
    //
        let endpoint = URL(string: "https://stats.nba.com/stats/leaguestandingsv3?LeagueID=00&Season=2022-23&SeasonType=Regular+Season&SeasonYear=")!
        print("Standings - Get data from \(endpoint)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("stats.nba.com", forHTTPHeaderField: "Referer")
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
                    let dataFromJson = try JSONDecoder().decode(jStandingsV2.self, from: content)
                    self.parseStandings(jsonParseData:dataFromJson)

                } catch {
                    print(error)
                }
            }
            print("Standings - Data loaded")
        }
        task.resume()
        
    }
        
    func parseStandings(jsonParseData: jStandingsV2) {
        print ("Parsing data jStandingsV2")
        for resultSet in jsonParseData.resultSets {
            for i in 0 ..< resultSet.rowSet.count {
                let gb_double = resultSet.rowSet[i][38].doubleValue()
                let gb_int = resultSet.rowSet[i][38].intValue()
                
                var sgb = "-"
                if gb_double + Double(gb_int) > 0 {
                    if gb_int > 0 {
                        sgb = "\(gb_int)"
                    }
                    else {
                        sgb = String(format: "%.1f", gb_double)
                    }
                }
                print("gb_double \(gb_double) gb_int \(gb_int) -> sgb \(sgb) ")
                print("Test \(resultSet.rowSet[i][38].intValue()) / \(resultSet.rowSet[i][38].doubleValue())")
                let team = mTeamStanding(id: resultSet.rowSet[i][2].stringValue(),
                                         name: resultSet.rowSet[i][4].stringValue(),
                                         record: resultSet.rowSet[i][17].stringValue(),
                                         currenStreak: resultSet.rowSet[i][37].stringValue(),
                                         leagueRank: "\(resultSet.rowSet[i][8].intValue())",
                                         winPct: String(format: "%.0f", resultSet.rowSet[i][32].doubleValue()*100),
                                         gb: sgb,
                                         last10: resultSet.rowSet[i][20].stringValue(),
                                         pointsAtt: String(format: "%.1f", resultSet.rowSet[i][58].doubleValue()),
                                         pointsDef: String(format: "%.1f", resultSet.rowSet[i][59].doubleValue()))
                let conference = resultSet.rowSet[i][6].stringValue()
                
                if conference == "West" {
                    self.standings.westConferenceStandings.append(team)
                }
                else {
                    self.standings.eastConferenceStandings.append(team)
                }
            }
            self.standings.isLoaded = true
        }
    }
}
