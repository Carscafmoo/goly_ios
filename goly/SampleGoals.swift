//
//  SampleGoals.swift
//  goly
//
//  Created by Carson Moore on 4/19/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//
import Foundation
class GoalGenerator {
    let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let opts = NSCalendarOptions(rawValue: 0)
    let date = NSDate()
    
    func generateDailyGoal() -> Goal {
        let goal = Goal(name: "Sample Daily Goal", prompt: "Did you brush your teeth today?", frequency: .Daily, target: 1, type: .Binary, checkInFrequency: .Daily)!
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -10, toDate: date, options: opts)!)
        // Skip a day to make sure this still works
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -8, toDate: date, options: opts)!)
        // Check in a 0
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -7, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -6, toDate: date, options: opts)!)
        // Skip one more day why not
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -4, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -3, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Day, value: -2, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -1, toDate: date, options: opts)!)
        // goal.checkIn(0, date: date)
        
        return goal
    }
    
    func generateWeeklyGoal() -> Goal {
        let goal = Goal(name: "Sample Weekly Goal", prompt: "How many minutes of piano did you practice?", frequency: .Weekly, target: 60, type: .Numeric, checkInFrequency: .Daily)!
        goal.checkIn(20, date: cal.dateByAddingUnit(.Day, value: -17, toDate: date, options: opts)!)
        goal.checkIn(15, date: cal.dateByAddingUnit(.Day, value: -15, toDate: date, options: opts)!)
        goal.checkIn(24, date: cal.dateByAddingUnit(.Day, value: -14, toDate: date, options: opts)!)
        goal.checkIn(13, date: cal.dateByAddingUnit(.Day, value: -13, toDate: date, options: opts)!)
        goal.checkIn(11, date: cal.dateByAddingUnit(.Day, value: -10, toDate: date, options: opts)!)
        // Skip a day to make sure this still works
        goal.checkIn(7, date: cal.dateByAddingUnit(.Day, value: -8, toDate: date, options: opts)!)
        // Check in a 0
        goal.checkIn(9, date: cal.dateByAddingUnit(.Day, value: -7, toDate: date, options: opts)!)
        goal.checkIn(4, date: cal.dateByAddingUnit(.Day, value: -6, toDate: date, options: opts)!)
        // Skip one more day why not
        goal.checkIn(21, date: cal.dateByAddingUnit(.Day, value: -4, toDate: date, options: opts)!)
        goal.checkIn(20, date: cal.dateByAddingUnit(.Day, value: -3, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Day, value: -1, toDate: date, options: opts)!)
        // goal.checkIn(20, date: date)
        
        return goal
    }
    
    func generateMonthlyGoal() -> Goal {
        let goal = Goal(name: "Sample Monthly Goal", prompt: "Did you call your parents today?", frequency: .Monthly, target: 5, type: .Binary, checkInFrequency: .Daily)!
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -75, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Day, value: -73, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Day, value: -70, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -65, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -62, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -48, toDate: date, options: opts)!)
        // Skip a day to make sure this still works
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -8, toDate: date, options: opts)!)
        // Check in a 0
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -7, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -6, toDate: date, options: opts)!)
        // Skip one more day why not
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -4, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Day, value: -3, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -2, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Day, value: -1, toDate: date, options: opts)!)
        // goal.checkIn(0, date: date)
        
        return goal
    }
    
    func generateQuarterlyGoal() -> Goal {
        let goal = Goal(name: "Sample Quarterly Goal", prompt: "Did you take an online course this month?", frequency: .Quarterly, target: 1, type: .Binary, checkInFrequency: .Monthly)!
        goal.checkIn(1, date: cal.dateByAddingUnit(.Month, value: -10, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Month, value: -9, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -8, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -7, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -6, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -5, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -4, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -3, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Month, value: -1, toDate: date, options: opts)!)
        // goal.checkIn(1, date: date)
        
        return goal
    }
    
    func generateYearlyGoal() -> Goal {
        let goal = Goal(name: "Sample Yearly Goal", prompt: "Did you take dance lessons this quarter?", frequency: .Yearly, target: 1, type: .Binary, checkInFrequency: .Monthly)!
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -30, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -29, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -28, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -27, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -26, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -25, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -24, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -23, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -21, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -20, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -19, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -18, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -17, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -16, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -15, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -14, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -13, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -11, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -10, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -9, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -8, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -7, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -6, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -5, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -4, toDate: date, options: opts)!)
        goal.checkIn(1, date: cal.dateByAddingUnit(.Month, value: -3, toDate: date, options: opts)!)
        goal.checkIn(0, date: cal.dateByAddingUnit(.Month, value: -1, toDate: date, options: opts)!)
        
        return goal
    }
    
    func getSampleGoals() -> [Goal] {
        return [generateDailyGoal(), generateWeeklyGoal(), generateMonthlyGoal(), generateQuarterlyGoal(), generateYearlyGoal()]
    }
    
    
    
    
}
