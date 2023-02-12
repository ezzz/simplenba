//
//  Simple_NBATests.swift
//  Simple NBATests
//
//  Created by Bruno ARENE on 02/11/2022.
//

import XCTest
@testable import Simple_NBA

final class Simple_NBATests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPlayByPlay() throws {
        print("Starting test PlaybyPlay")
        let mPlay = PlayByPlay(gameId: "0022200758", homeTeamTricode: "SAC", preview: true)
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for 10 seconds")], timeout: 3.0)
        print ("Data loaded : \(mPlay.gameId) actions \(mPlay.diffTable.count)")
        XCTAssert(mPlay.dataIsLoaded == true)
        XCTAssert(mPlay.timeArray.count > 30)
        for dt in mPlay.timeArray {
            let diff = mPlay.diffTable[dt]!
            print("> dt \(dt) -> \(diff)")// diff \(mPlay.diffTable[dt])")
            
        }
    }
    
    func testStandings() throws {
        let st = Standings()
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for 2 seconds")], timeout: 2.0)
        
        XCTAssert(st.standings.isLoaded == true)
        XCTAssert(st.standings.westConferenceStandings.count > 10)
        XCTAssert(st.standings.eastConferenceStandings.count > 10)
        print(("== Western conference ==========================="))
        for team in st.standings.westConferenceStandings {
            print("\(team.leagueRank) - \(team.name) - \(team.record) - \(team.gb) - \(team.pointsAtt) / \(team.pointsDef) - Serie \(team.currenStreak) - L10 \(team.last10) ")
        }
        print(("== Eastern conference ==========================="))
        for team in st.standings.eastConferenceStandings {
            print("\(team.leagueRank) - \(team.name) - \(team.record) - \(team.currenStreak)")
        }
        print(("== =============================================="))
    }
    
    func testDate() throws {
        /*
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let initDate = Date()
        let mydate1 = Calendar.current.date(byAdding: .day, value: -2, to: initDate)!
        let mydate2 = Calendar.current.date(byAdding: .day, value: -2, to: mydate1)!
        let mydate3 = Calendar.current.date(byAdding: .day, value: -2, to: mydate2)!
        let mydate4 = Calendar.current.date(byAdding: .day, value: -2, to: mydate3)!
        print ("Test> \(formatter.string(from: initDate)) -1 \(formatter.string(from: mydate1))")
        print ("Test> \(formatter.string(from: mydate1)) -1 \(formatter.string(from: mydate2))")
        print ("Test> \(formatter.string(from: mydate2)) -1 \(formatter.string(from: mydate3))")
        print ("Test> \(formatter.string(from: mydate3)) -1 \(formatter.string(from: mydate4))")*/
        let daygames = DayGames(preview: false)
        daygames.updateSelectedDay(dayOffset: -1, reloadJson: false)
        daygames.updateSelectedDay(dayOffset: -1, reloadJson: false)
        daygames.updateSelectedDay(dayOffset: -1, reloadJson: false)
        daygames.updateSelectedDay(dayOffset: -1, reloadJson: false)
        daygames.updateSelectedDay(dayOffset: -1, reloadJson: false)
        daygames.updateSelectedDay(dayOffset: -1, reloadJson: false)
        daygames.updateSelectedDay(dayOffset: -1, reloadJson: false)
    }

    func testPlayByPlay2() throws {
        print("Starting test PlaybyPlay")
        let mPlay = PlayByPlay(gameId: "0022200758", homeTeamTricode: "SAC", preview: true)
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for 10 seconds")], timeout: 3.0)
        print ("Data loaded : \(mPlay.gameId) actions \(mPlay.diffTable.count)")
        XCTAssert(mPlay.dataIsLoaded == true)
        XCTAssert(mPlay.timeArray.count > 30)
        for dt in mPlay.timeArray {
            let diff = mPlay.diffTable[dt]!
            print("> dt \(dt) -> \(diff)")// diff \(mPlay.diffTable[dt])")
            
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
