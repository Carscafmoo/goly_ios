//
//  GoalTestCase.swift
//  golyTests
//
//  Created by Carson Moore on 1/6/19.
//  Copyright © 2019 Carson C. Moore, LLC. All rights reserved.
//

import XCTest
@testable import goly

class GoalTestCase: XCTestCase {
    let goalGen: GoalGenerator = GoalGenerator()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInit() {
        var goal = Goal(name: "Test Goal", prompt: "", frequency: .Daily, target: 1, type: .Binary, checkInFrequency: .Daily)
        XCTAssertNil(goal)
        
        goal = Goal(name: "", prompt: "Did you test Goly today?", frequency: .Daily, target: 1, type: .Binary, checkInFrequency: .Daily)
        XCTAssertNil(goal)
        
        goal = Goal(name: "Test goal", prompt: "Did you test Goly today?", frequency: .Daily, target: -1, type: .Binary, checkInFrequency: .Daily)
        XCTAssertNil(goal)
        
        goal = Goal(name: "Test goal", prompt: "Did you test Goly today?", frequency: .Daily, target: 1, type: .Binary, checkInFrequency: .Weekly)  // CIF is > Frequency
        XCTAssertNil(goal)
        
        goal = Goal(name: "Test goal", prompt: "Did you test Goly today?", frequency: .Daily, target: 1, type: .Binary, checkInFrequency: .Daily)  // This should one day create an "inverse" goal
        XCTAssertNotNil(goal)
        
    }

    func testCheckIn() {
        let date = Date()
        let dailyGoal = self.goalGen.generateDailyGoal()
        dailyGoal.checkIns = []
        
        // This is not the best way to do this, but we are going to test lastCheckInTime here as well
        XCTAssertNil(dailyGoal.lastCheckInTime())
        XCTAssertTrue(dailyGoal.needsCheckIn())
        
        dailyGoal.checkIn(1, date: date)
        XCTAssert(dailyGoal.checkIns.count == 1)
        XCTAssert(dailyGoal.checkIns.first!.value == 1)
        XCTAssertFalse(dailyGoal.needsCheckIn())
        XCTAssert(dailyGoal.currentProgress() == 1)
        XCTAssertNotNil(dailyGoal.lastCheckInTime())
        XCTAssertTrue(dailyGoal.lastCheckInTime()! <= Date())
        
        // And, if you check in again... it ovewrites!
        dailyGoal.checkIn(0, date: date)
        XCTAssert(dailyGoal.checkIns.count == 1)
        XCTAssert(dailyGoal.checkIns.first!.value == 0)
        XCTAssertFalse(dailyGoal.needsCheckIn())
        XCTAssert(dailyGoal.currentProgress() == 0)
    }
    
    func testCurrentProgress() {
        let dailyGoal = self.goalGen.generateDailyGoal()
        dailyGoal.checkIns = []
        XCTAssertEqual(dailyGoal.currentProgress(), 0)
        
        // Checking in "yes" should yield progress of 1
        let dt = Date()
        dailyGoal.checkIn(1, date: dt)
        XCTAssertEqual(dailyGoal.currentProgress(), 1)
        
        dailyGoal.checkIn(0, date: dt)
        XCTAssertEqual(dailyGoal.currentProgress(), 0)
        
        // Checking in something old shouldn't really count toward current progress:
        let yesterday = dt - TimeInterval(3600 * 24)
        dailyGoal.checkIn(1, date: yesterday)
        XCTAssertEqual(dailyGoal.currentProgress(), 0)
        
        // And check to make sure it works correctly for non-binary, multi-date Goals
        let multiGoal = self.goalGen.generateWeeklyGoal()
        multiGoal.checkIns = []
        multiGoal.checkIn(30, date: dt)
        XCTAssertEqual(multiGoal.currentProgress(), 30)
        
        multiGoal.checkIn(30, date: dt - TimeInterval(3600 * 24 * 7))
        XCTAssertEqual(multiGoal.currentProgress(), 30)
    }
    
    func testTimeFrameValue() {
        let dailyGoal = self.goalGen.generateDailyGoal()
        let today = Date()
        let yesterday = today - TimeInterval(3600 * 24)
        let nextWeek = today + TimeInterval(3600 * 24 * 7)
        let oneDayTimeframe = Timeframe(frequency: Frequency.Daily, now: today)
        let oneDayTimeframeYesterday = Timeframe(frequency: Frequency.Daily, now: yesterday)
        let oneWeekTimeframe = Timeframe(frequency: Frequency.Weekly, now: nextWeek)
        dailyGoal.checkIns = []
        
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframe), 0)
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframeYesterday), 0)
        XCTAssertEqual(dailyGoal.timeframeValue(oneWeekTimeframe), 0)
        
        // Checking in "yes" should yield progress of 1
        dailyGoal.checkIn(1, date: today)
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframe), 1)
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframeYesterday), 0)
        XCTAssertEqual(dailyGoal.timeframeValue(oneWeekTimeframe), 0)
        
        dailyGoal.checkIn(0, date: today)
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframe), 0)
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframeYesterday), 0)
        XCTAssertEqual(dailyGoal.timeframeValue(oneWeekTimeframe), 0)
        
        // Checking in something old shouldn't count toward current progress:
        dailyGoal.checkIn(1, date: yesterday)
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframe), 0)
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframeYesterday), 1)
        XCTAssertEqual(dailyGoal.timeframeValue(oneWeekTimeframe), 0)
        
        dailyGoal.checkIn(1, date: nextWeek)
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframe), 0)
        XCTAssertEqual(dailyGoal.timeframeValue(oneDayTimeframeYesterday), 1)
        XCTAssertEqual(dailyGoal.timeframeValue(oneWeekTimeframe), 1)
    }
    
    func testNeedsCheckInOnDate() {
        // Have we checked in? Should include > 1 and 0 as not needing to still check in:
        let dailyGoal = self.goalGen.generateDailyGoal()
        let today = Date()
        let yesterday = today - TimeInterval(3600 * 24)
        dailyGoal.checkIns = []
        XCTAssertTrue(dailyGoal.needsCheckIn())
        XCTAssertTrue(dailyGoal.needsCheckInOnDate(today))
        
        dailyGoal.checkIn(1, date: today)
        XCTAssertFalse(dailyGoal.needsCheckIn())
        XCTAssertFalse(dailyGoal.needsCheckInOnDate(today))
        XCTAssertTrue(dailyGoal.needsCheckInOnDate(yesterday))
        
        dailyGoal.checkIn(0, date: yesterday)
        XCTAssertFalse(dailyGoal.needsCheckIn())
        XCTAssertFalse(dailyGoal.needsCheckInOnDate(today))
        XCTAssertFalse(dailyGoal.needsCheckInOnDate(yesterday))
    }
    
    func testGetCheckInFrequency() {
        let dailyGoal = self.goalGen.generateDailyGoal()
        let monthlyGoal = self.goalGen.generateMonthlyGoal()
        let nonconformantGoal = self.goalGen.generateNonConformantGoal()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Daily goal should always yield the same value as its check-in tf no matter what:
        // This is really dumb but assertEqual doesn't seem to use == so assertTrue (a == b) is necessary
        XCTAssertTrue(Timeframe(frequency: Frequency.Daily, now: Date()) == dailyGoal.getCheckInTimeframeForDate(date: Date()))
        
        // Monthly Goal should yield the same deal, the daily frequecy, every time:
        XCTAssertTrue(Timeframe(frequency: Frequency.Daily, now: Date()) == monthlyGoal.getCheckInTimeframeForDate(date: Date()))
        
        // But the nonconformant goal should be bounded by the month start / end:
        let monthStart = formatter.date(from: "2018-10-01")!
        let monthEnd = formatter.date(from: "2018-10-31")!
        let funkyTf = nonconformantGoal.getCheckInTimeframeForDate(date: monthStart)
        XCTAssertEqual(funkyTf.startDate, monthStart)
        XCTAssertEqual(funkyTf.endDate, formatter.date(from: "2018-10-07")!)
        
        let normalTf = nonconformantGoal.getCheckInTimeframeForDate(date: formatter.date(from: "2018-10-17")!)
        XCTAssertEqual(normalTf.startDate, formatter.date(from: "2018-10-14")!)
        XCTAssertEqual(normalTf.endDate, formatter.date(from: "2018-10-21")!)
        
        let endTf = nonconformantGoal.getCheckInTimeframeForDate(date: monthEnd)
        XCTAssertEqual(endTf.startDate, formatter.date(from: "2018-10-28")!)
        XCTAssertEqual(endTf.endDate, formatter.date(from: "2018-11-01"))
    }
    
    func testForNonconformingTimeframes() {
        let goal = self.goalGen.generateNonConformantGoal()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        goal.checkIns = []
        
        // This should need to check in on Saturdays and also on the last day of October, but no other days:
        XCTAssertTrue(goal.needsCheckInOnDate(formatter.date(from: "2018-10-06")!))
        XCTAssertTrue(goal.needsCheckInOnDate(formatter.date(from: "2018-10-13")!))
        XCTAssertTrue(goal.needsCheckInOnDate(formatter.date(from: "2018-10-20")!))
        XCTAssertTrue(goal.needsCheckInOnDate(formatter.date(from: "2018-10-27")!))
        XCTAssertTrue(goal.needsCheckInOnDate(formatter.date(from: "2018-10-31")!))
        
        XCTAssertFalse(goal.needsCheckInOnDate(formatter.date(from: "2018-10-01")!))
        XCTAssertFalse(goal.needsCheckInOnDate(formatter.date(from: "2018-10-02")!))
        XCTAssertFalse(goal.needsCheckInOnDate(formatter.date(from: "2018-10-03")!))
        XCTAssertFalse(goal.needsCheckInOnDate(formatter.date(from: "2018-10-04")!))
        XCTAssertFalse(goal.needsCheckInOnDate(formatter.date(from: "2018-10-05")!))
        XCTAssertFalse(goal.needsCheckInOnDate(formatter.date(from: "2018-10-07")!))
        
        // Otherwise, it should pretty much work exactly as expected in terms of the accrual of checks-in relative to the goal's timeframe:
        let timeframe = Timeframe(frequency: goal.frequency, now: formatter.date(from: "2018-10-01")!)
        goal.checkIn(1, date: formatter.date(from: "2018-10-06")!)
        goal.checkIn(0, date: formatter.date(from: "2018-10-13")!)
        goal.checkIn(1, date: formatter.date(from: "2018-10-20")!)
        goal.checkIn(1, date: formatter.date(from: "2018-10-27")!)
        XCTAssertEqual(goal.timeframeValue(timeframe), 3)
        
        goal.checkIn(1, date: formatter.date(from: "2018-10-31")!)
        XCTAssertEqual(goal.timeframeValue(timeframe), 4)
        
        // And checking in to a bordering timeframe doesn't break the system:
        goal.checkIn(0, date: formatter.date(from: "2018-10-31")!)
        goal.checkIn(1, date: formatter.date(from: "2018-11-01")!)
        XCTAssertEqual(goal.timeframeValue(timeframe), 3)
    }

    /*This actually overwrites all saved goals, which is not what we want
     Creating an extension which overrides the static property of the archive path
     was not a successful endeavor.
 func testLoadGoals() {
        // Delete any existing goals:
        Goal.saveGoals([])
        let goals = self.goalGen.getSampleGoals()
        Goal.saveGoals(goals)

        let sortedGoals = Goal.loadGoals()

        Goal.saveGoals([])

    }*/
}
