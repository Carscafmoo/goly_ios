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

    func testSubTimeframes() {
        // Daily timeframe should have a subtf of just itself:
        let dailyTf = Timeframe(frequency: .Daily, now: Date())
        let dailySubs = dailyTf.subTimeframes(subFrequency: .Daily)
        XCTAssertEqual(dailySubs.count, 1)
        XCTAssertEqual(dailySubs.first!.startDate, dailyTf.startDate)
        XCTAssertEqual(dailySubs.first!.endDate, dailyTf.endDate)

        // For any sort of normal, conformant situation, you would expect it to behave... well, like you'd expect it to behave:
        let quarterlyTf = Timeframe(frequency: .Quarterly, now: Date())
        let quarterlySubs = quarterlyTf.subTimeframes(subFrequency: .Monthly)
        XCTAssertEqual(quarterlySubs.count, 3)
        XCTAssertEqual(quarterlySubs.first!.startDate, quarterlyTf.startDate)
        XCTAssertEqual(quarterlySubs.last!.endDate, quarterlyTf.endDate)

        // And for any sort of non-conforming timeframe, you would expect it to sort of chop appropriately:
        let monthlyTf = Timeframe(frequency: .Monthly, now: formatter.date(from: "2019-01-01")!)
        let monthlySubs = monthlyTf.subTimeframes(subFrequency: .Weekly)
        XCTAssertEqual(monthlySubs.count, 5)
        XCTAssertEqual(monthlySubs.first!.startDate, monthlyTf.startDate)
        XCTAssertEqual(monthlySubs.last!.endDate, monthlyTf.endDate)
    }

    func testUserPreferencesForWeekday() {
        // So we can re-set it later
        let checkInDaySetting = Settings.getWeekBeginsDay()

        UserDefaults.standard.set(1, forKey: Settings.SettingsBundleKeys.weekBeginsKey)
        let midweek_test = Timeframe(frequency: .Weekly, now: formatter.date(from: "2018-10-17")!)
        XCTAssertEqual(midweek_test.startDate, formatter.date(from: "2018-10-15")) // Monday
        XCTAssertEqual(midweek_test.endDate, formatter.date(from: "2018-10-22")) // Monday

        let beginning_of_week_test = Timeframe(frequency: .Weekly, now: formatter.date(from: "2018-10-15")!)
        XCTAssertEqual(beginning_of_week_test.startDate, formatter.date(from: "2018-10-15")) // Monday
        XCTAssertEqual(beginning_of_week_test.endDate, formatter.date(from: "2018-10-22")) // Monday

        let end_of_week_test = Timeframe(frequency: .Weekly, now: formatter.date(from: "2018-10-21")!)
        XCTAssertEqual(end_of_week_test.startDate, formatter.date(from: "2018-10-15")) // Monday
        XCTAssertEqual(end_of_week_test.endDate, formatter.date(from: "2018-10-22")) // Monday)

        UserDefaults.standard.set(checkInDaySetting, forKey: Settings.SettingsBundleKeys.weekBeginsKey)

    }
}
