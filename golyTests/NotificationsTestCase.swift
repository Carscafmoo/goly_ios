//
//  NotificationsTestCase.swift
//  golyTests
//
//  Created by Carson Moore on 3/2/19.
//  Copyright © 2019 Carson C. Moore, LLC. All rights reserved.
//

import XCTest

class NotificationsTestCase: XCTestCase {
    func testNoGoalsNoDates() {
        let (dts, msgs) = Notifications().nextCheckInDates(goals: [Goal]())
        XCTAssertTrue(dts.isEmpty)
        XCTAssertTrue(msgs.isEmpty)
    }

    func testNoActiveGoalsNoDates() {
        let goal = Goal(name: "TEST", prompt: "TEST", frequency: .Daily, target: 1, type: .Binary, checkInFrequency: .Daily)!
        goal.active = false

        let (dts, msgs) = Notifications().nextCheckInDates(goals: [goal])
        XCTAssertTrue(dts.isEmpty)
        XCTAssertTrue(msgs.isEmpty)
    }

    func testActiveDailyGoalNotCheckedInToday() {
        let dateInjector = MockDateInjector(dateString: "2018-10-17 08:00:00")
        let dateFormatter = dateInjector.dateFormatter
        let notifications = Notifications()
        let goal = GoalGenerator().generateDailyGoal()
        let (dts, msgs) = notifications.nextCheckInDates(goals: [goal], dateInjector: dateInjector)
        XCTAssertEqual(dts.count, 10)
        XCTAssertEqual(msgs.count, 10)
        XCTAssertEqual(Set(dts).count, 10)  // No duplicates, I guess

        XCTAssertEqual(dts.min()!, dateFormatter.date(from: "2018-10-17 21:00:00")!)
        XCTAssertEqual(dts.max()!, dateFormatter.date(from: "2018-10-26 21:00:00")!)
        XCTAssertEqual(Set(msgs), Set([goal.prompt]))
    }

    func testActiveDailyGoalCheckedInToday() {
        let dateInjector = MockDateInjector(dateString: "2018-10-17 08:00:00")
        let dateFormatter = dateInjector.dateFormatter
        let notifications = Notifications()
        let goal = GoalGenerator().generateDailyGoal()
        goal.checkIn(1, date: dateInjector.currentDate())
        let (dts, msgs) = notifications.nextCheckInDates(goals: [goal], dateInjector: dateInjector)
        XCTAssertEqual(dts.count, 10)
        XCTAssertEqual(msgs.count, 10)
        XCTAssertEqual(Set(dts).count, 10)  // No duplicates, I guess

        // Shouldn't include today
        XCTAssertEqual(dts.min()!, dateFormatter.date(from: "2018-10-18 21:00:00")!)
        XCTAssertEqual(dts.max()!, dateFormatter.date(from: "2018-10-27 21:00:00")!)
        XCTAssertEqual(Set(msgs), Set([goal.prompt]))
    }

    func testActiveDailyGoalAfterCheckInTime() {
        let dateInjector = MockDateInjector(dateString: "2018-10-17 21:00:01")
        let dateFormatter = dateInjector.dateFormatter
        let notifications = Notifications()
        let goal = GoalGenerator().generateDailyGoal()
        let (dts, msgs) = notifications.nextCheckInDates(goals: [goal], dateInjector: dateInjector)
        XCTAssertEqual(dts.count, 10)
        XCTAssertEqual(msgs.count, 10)
        XCTAssertEqual(Set(dts).count, 10)  // No duplicates, I guess

        // Shouldn't include today
        XCTAssertEqual(dts.min()!, dateFormatter.date(from: "2018-10-18 21:00:00")!)
        XCTAssertEqual(dts.max()!, dateFormatter.date(from: "2018-10-27 21:00:00")!)
        XCTAssertEqual(Set(msgs), Set([goal.prompt]))
    }

    func testActiveWeeklyGoal() { // Weekly in the sense of checking in weekly...
        let dateInjector = MockDateInjector(dateString: "2018-10-17 14:00:00")
        let dateFormatter = dateInjector.dateFormatter
        let notifications = Notifications()
        let goal = GoalGenerator().generateNonConformantGoal()
        goal.checkIns = []
        let (dts, msgs) = notifications.nextCheckInDates(goals: [goal], dateInjector: dateInjector)
        XCTAssertEqual(dts.count, 10)
        XCTAssertEqual(msgs.count, 10)
        XCTAssertEqual(Set(dts).count, 10)  // No duplicates, I guess

        // Should be the next 10 Saturdays...:
        XCTAssertEqual(dts.min()!, dateFormatter.date(from: "2018-10-20 21:00:00")!)
        XCTAssertEqual(dts.max()!, dateFormatter.date(from: "2018-12-08 21:00:00")!)
        XCTAssertEqual(Set(msgs), Set([goal.prompt]))
    }

    func testActiveMonthlyGoal() { // Monthly in the sense of check-in frequency
        let dateInjector = MockDateInjector(dateString: "2018-10-17 14:00:00")
        let dateFormatter = dateInjector.dateFormatter
        let notifications = Notifications()
        let goal = GoalGenerator().generateQuarterlyGoal()
        goal.checkIns = []
        let (dts, msgs) = notifications.nextCheckInDates(goals: [goal], dateInjector: dateInjector)
        XCTAssertEqual(dts.count, 10)
        XCTAssertEqual(msgs.count, 10)
        XCTAssertEqual(Set(dts).count, 10)  // No duplicates, I guess

        // Should be the next 10 Saturdays...:
        XCTAssertEqual(dts.min()!, dateFormatter.date(from: "2018-10-31 21:00:00")!)
        XCTAssertEqual(dts.max()!, dateFormatter.date(from: "2019-07-31 21:00:00")!)
        XCTAssertEqual(Set(msgs), Set([goal.prompt]))
    }

    func testActiveWeeklyWithMonthlyGoal() {
        let dateInjector = MockDateInjector(dateString: "2018-10-17 14:00:00")
        let dateFormatter = dateInjector.dateFormatter
        let notifications = Notifications()
        let monthlyGoal = GoalGenerator().generateQuarterlyGoal() // Monthly CIF, not monthly goal
        let quarterlyGoal = GoalGenerator().generateYearlyGoal() // Quarterly CIF, not quarterly goal...
        let weeklyGoal = GoalGenerator().generateNonConformantGoal() // Weekly CIF, not weekly goal...

        monthlyGoal.checkIns = []
        quarterlyGoal.checkIns = []
        weeklyGoal.checkIns = []

        let (dts, msgs) = notifications.nextCheckInDates(goals: [monthlyGoal, quarterlyGoal, weeklyGoal], dateInjector: dateInjector)
        XCTAssertEqual(dts.count, 10)
        XCTAssertEqual(msgs.count, 10)
        XCTAssertEqual(Set(dts).count, 10)  // No duplicates, I guess

        // Should be the next Saturdays, plus the ends of the months... basically, same as weekly
        XCTAssertEqual(dts.min()!, dateFormatter.date(from: "2018-10-20 21:00:00")!)
        XCTAssertEqual(dts.max()!, dateFormatter.date(from: "2018-12-08 21:00:00")!)
        // This isn't a great test of this; there's a 1/9 chance you don't get more than 1 message...
        // XCTAssertTrue(Set(msgs).count >= 2)
    }

    func testNotificationsForReallyNonConformingStuff() {
        let dateInjector = MockDateInjector(dateString: "2018-10-17 14:00:00")
        let dateFormatter = dateInjector.dateFormatter
        let notifications = Notifications()
        let monthlyGoal = GoalGenerator().generateQuarterlyGoal() // Monthly CIF, not monthly goal
        let weeklyGoal = GoalGenerator().generateNonConformantGoal() // Weekly CIF, not weekly goal...
        weeklyGoal.frequency = .Quarterly  // This should throw the algorithm for a loop ... it won't try to check in on monthly stuff

        monthlyGoal.checkIns = []
        weeklyGoal.checkIns = []

        let (dts, msgs) = notifications.nextCheckInDates(goals: [monthlyGoal, weeklyGoal], dateInjector: dateInjector)
        XCTAssertEqual(dts.count, 10)
        XCTAssertEqual(msgs.count, 10)
        XCTAssertEqual(Set(dts).count, 10)  // No duplicates, I guess

        // Should be the next Saturdays, plus the ends of the months... basically, same as weekly
        XCTAssertEqual(dts.min()!, dateFormatter.date(from: "2018-10-20 21:00:00")!)
        XCTAssertEqual(dts.max()!, dateFormatter.date(from: "2018-12-08 21:00:00")!)
    }

    func testNotificationsGenerateARandomMessage() {
        let notifications = Notifications()
        let dailyGoal1 = GoalGenerator().generateDailyGoal()
        let dailyGoal2 = GoalGenerator().generateDailyGoal()
        dailyGoal1.prompt = "foo"
        dailyGoal2.prompt = "bar"
        let (_, msgs) = notifications.nextCheckInDates(goals: [dailyGoal1, dailyGoal2])
        XCTAssertEqual(Set(msgs), Set(["foo", "bar"])) // Should randomly choose one of the two; Should have 1 / 10^10 chance of not getting both
    }


    func testNotificationsRespectUserPreferences() {
        // Should check in weekly goals on Sunday night if Monday is the first day of the week;
        // Should check in at 8:00 if that's check-in time:
        let checkInTimeSetting = Settings.getCheckInHour()
        let checkInDaySetting = Settings.getWeekBeginsDay()

        UserDefaults.standard.set(20, forKey: Settings.SettingsBundleKeys.checkInTimeKey)
        UserDefaults.standard.set(1, forKey: Settings.SettingsBundleKeys.weekBeginsKey)

        let dateInjector = MockDateInjector(dateString: "2018-10-17 14:00:00")
        let dateFormatter = dateInjector.dateFormatter
        let notifications = Notifications()
        let goal = GoalGenerator().generateNonConformantGoal()
        goal.checkIns = []
        let (dts, msgs) = notifications.nextCheckInDates(goals: [goal], dateInjector: dateInjector)
        XCTAssertEqual(dts.count, 10)
        XCTAssertEqual(msgs.count, 10)
        XCTAssertEqual(Set(dts).count, 10)  // No duplicates, I guess

        // Should be the next 10 Saturdays...:
        XCTAssertEqual(dts.min()!, dateFormatter.date(from: "2018-10-21 20:00:00")!)  // Sunday, 8:00
        XCTAssertEqual(dts.max()!, dateFormatter.date(from: "2018-12-09 20:00:00")!)

        // Reset
        UserDefaults.standard.set(checkInTimeSetting, forKey: Settings.SettingsBundleKeys.checkInTimeKey)
        UserDefaults.standard.set(checkInDaySetting, forKey: Settings.SettingsBundleKeys.weekBeginsKey)
    }
}
