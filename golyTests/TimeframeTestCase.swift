//
//  TimeframeTestCase.swift
//  golyTests
//
//  Created by Carson Moore on 1/26/19.
//  Copyright © 2019 Carson C. Moore, LLC. All rights reserved.
//

import XCTest

class TimeframeTestCase: XCTestCase {
    let formatter = DateFormatter()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        formatter.dateFormat = "yyyy-MM-dd"
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIsStandard() {
        let standardTf = Timeframe(frequency: .Daily, now: Date())
        XCTAssertTrue(standardTf.isStandard())

        let nonStandardTf = Timeframe(frequency: .Weekly, startDate: formatter.date(from: "2018-10-01")!, endDate: formatter.date(from: "2018-10-07")!)!
        XCTAssertFalse(nonStandardTf.isStandard())

        let otherNonStandardTf = Timeframe(frequency: .Weekly, startDate: formatter.date(from: "2018-10-28")!, endDate: formatter.date(from: "2018-11-01")!)!
        XCTAssertFalse(otherNonStandardTf.isStandard())
    }

    func testIsCurrent() {
        let currentTf = Timeframe(frequency: .Daily, now: Date())
        XCTAssertTrue(currentTf.isCurrent())

        // Assuming a linear, non-repeating model of time...
        let pastTf = Timeframe(frequency: .Monthly, startDate: formatter.date(from:"2018-10-01")!, endDate: formatter.date(from: "2018-11-01")!)!
        XCTAssertFalse(pastTf.isCurrent())

        // Assuming I never grow to be this old...
        let futureTf = Timeframe(frequency: .Monthly, startDate: formatter.date(from:"2099-10-01")!, endDate: formatter.date(from: "2099-11-01")!)!
        XCTAssertFalse(futureTf.isCurrent())

        // A good test if I could freeze time here would be to assure that end_date is not inclusive... but I can't, so /shrug
    }

    func testToString() {
        let currentDailyTf = Timeframe(frequency: .Daily, now: Date())
        XCTAssertEqual(currentDailyTf.toString(), "today")

        let pastDailyTf = Timeframe(frequency: .Daily, now: formatter.date(from: "2018-10-17")!)
        XCTAssertEqual(pastDailyTf.toString(), "October 17, 2018")  // This will obvi fail right now

        // We don't have a good way of testing the nonconformant pathway until we tackle the date refactoring: https://medium.com/@johnsundell/time-traveling-in-swift-unit-tests-583a2c3ce85b

        let pastMonthlyTf = Timeframe(frequency: .Monthly, now: formatter.date(from: "2018-10-17")!)
        XCTAssertEqual(pastMonthlyTf.toString(), "Oct 1 – 31, 2018")

        let pastWeeklyTf = Timeframe(frequency: .Weekly, startDate: formatter.date(from: "2018-10-01")!, endDate: formatter.date(from: "2018-10-07")!)!
        XCTAssertEqual(pastWeeklyTf.toString(), "Oct 1 – 6, 2018")

        let pastYearlyTf = Timeframe(frequency: .Yearly, now: formatter.date(from: "2018-10-17")!)
        XCTAssertEqual(pastYearlyTf.toString(), "2018")

        let pastQuarterlyTf = Timeframe(frequency: .Quarterly, now: formatter.date(from: "2018-10-17")!)
        XCTAssertEqual(pastQuarterlyTf.toString(), "Oct 1 – Dec 31, 2018")
    }
}
