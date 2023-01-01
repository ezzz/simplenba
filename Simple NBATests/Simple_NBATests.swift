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

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        let mPlay = PlayByPlay(gameId: "0022200161", preview: false)
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
