//
//  SampleGoals.swift
//  goly
//
//  Created by Carson Moore on 4/19/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//
import Foundation
class GoalGenerator {
    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
    let date = Date()
    let formatter = DateFormatter()
    
    func generateDailyGoal() -> Goal {
        let goal = Goal(name: "Sample Daily Goal", prompt: "Did you brush your teeth today?", frequency: .Daily, target: 1, type: .Binary, checkInFrequency: .Daily)!
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -10, to: date)!)
        // Skip a day to make sure this still works
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -8, to: date)!)
        // Check in a 0
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -7, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -6, to: date)!)
        // Skip one more day why not
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -4, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -3, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .day, value: -2, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -1, to: date)!)
        // goal.checkIn(0, date: date)

        return goal
    }
    
    func generateWeeklyGoal() -> Goal {
        let goal = Goal(name: "Sample Weekly Goal", prompt: "How many minutes of piano did you practice?", frequency: .Weekly, target: 60, type: .Numeric, checkInFrequency: .Daily)!
        goal.checkIn(20, date: (cal as Calendar).date(byAdding: .day, value: -17, to: date)!)
        goal.checkIn(15, date: (cal as Calendar).date(byAdding: .day, value: -15, to: date)!)
        goal.checkIn(24, date: (cal as Calendar).date(byAdding: .day, value: -14, to: date)!)
        goal.checkIn(13, date: (cal as Calendar).date(byAdding: .day, value: -13, to: date)!)
        goal.checkIn(11, date: (cal as Calendar).date(byAdding: .day, value: -10, to: date)!)
        // Skip a day to make sure this still works
        goal.checkIn(7, date: (cal as Calendar).date(byAdding: .day, value: -8, to: date)!)
        // Check in a 0
        goal.checkIn(9, date: (cal as Calendar).date(byAdding: .day, value: -7, to: date)!)
        goal.checkIn(4, date: (cal as Calendar).date(byAdding: .day, value: -6, to: date)!)
        // Skip one more day why not
        goal.checkIn(21, date: (cal as Calendar).date(byAdding: .day, value: -4, to: date)!)
        goal.checkIn(20, date: (cal as Calendar).date(byAdding: .day, value: -3, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .day, value: -1, to: date)!)
        // goal.checkIn(20, date: date)

        return goal
    }
    
    func generateMonthlyGoal() -> Goal {
        let goal = Goal(name: "Sample Monthly Goal", prompt: "Did you call your parents today?", frequency: .Monthly, target: 5, type: .Binary, checkInFrequency: .Daily)!
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -75, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .day, value: -73, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .day, value: -70, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -65, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -62, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -48, to: date)!)
        // Skip a day to make sure this still works
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -8, to: date)!)
        // Check in a 0
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -7, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -6, to: date)!)
        // Skip one more day why not
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -4, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .day, value: -3, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -2, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .day, value: -1, to: date)!)
        // goal.checkIn(0, date: date)
        
        return goal
    }
    
    func generateQuarterlyGoal() -> Goal {
        let goal = Goal(name: "Sample Quarterly Goal", prompt: "Did you take an online course this month?", frequency: .Quarterly, target: 1, type: .Binary, checkInFrequency: .Monthly)!
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .month, value: -10, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .month, value: -9, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .month, value: -8, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .month, value: -7, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .month, value: -6, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .month, value: -5, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .month, value: -4, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .month, value: -3, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .month, value: -1, to: date)!)
        // goal.checkIn(1, date: date)
        
        return goal
    }
    
    func generateYearlyGoal() -> Goal {
        let goal = Goal(name: "Sample Yearly Goal", prompt: "Did you take dance lessons this quarter?", frequency: .Yearly, target: 1, type: .Binary, checkInFrequency: .Quarterly)!
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -30, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -29, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -28, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -27, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -26, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -25, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -24, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -23, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -21, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -20, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -19, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -18, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -17, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -16, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -15, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -14, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -13, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -11, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -10, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -9, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -8, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -7, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -6, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -5, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -4, to: date)!)
        goal.checkIn(1, date: (cal as Calendar).date(byAdding: .quarter, value: -3, to: date)!)
        goal.checkIn(0, date: (cal as Calendar).date(byAdding: .quarter, value: -1, to: date)!)
        
        return goal
    }
    
    func generateNonConformantGoal() -> Goal {
        let goal = Goal(name: "Sample Nonconformant Goal", prompt: "Did you cook dinner this week?", frequency: .Monthly, target: 4, type: .Binary, checkInFrequency: .Weekly)!
        formatter.dateFormat = "yyyy-MM-dd"

        // Should check in every Saturday I guess from whenever til whenever.
        goal.checkIn(1, date: formatter.date(from: "2018-10-06")!)
        goal.checkIn(0, date: formatter.date(from: "2018-10-13")!)
        goal.checkIn(1, date: formatter.date(from: "2018-10-20")!)
        goal.checkIn(1, date: formatter.date(from: "2018-10-27")!)
        goal.checkIn(1, date: formatter.date(from: "2018-10-31")!)

        return goal
    }

    func getSampleGoals() -> [Goal] {
        return [generateDailyGoal(), generateWeeklyGoal(), generateMonthlyGoal(), generateQuarterlyGoal(), generateYearlyGoal(), generateNonConformantGoal()]
    }
    
    
    
    
}
