//
//  Notifications.swift
//  goly
//
//  Created by Carson Moore on 4/23/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import UIKit
class Notifications {
    var goals: [Goal]?
    let cal: Calendar
    init() {
        goals = Goal.loadGoals()
        cal = Calendar(identifier: Calendar.Identifier.gregorian)
    }
    
    // Schedule 10 future notifications.
    func scheduleNotifications(_ app: UIApplication) {
        clearNotifications(app)
        if var goals = self.goals {
            // If there's no goals, go ahead and return
            if goals.count == 0 { return }
            
            // Load goals already sorts by frequency and activity
            // If no goals are active, the first goal will be inactive and you can return
            if (!goals[0].active) { return }

            // Now, loop through the next 10 dates on which anything would need to check in
            // Start now...
            let (nextCheckInDts, nextCheckInMessages) = nextCheckInDates(goals: goals)
            for i in 0..<nextCheckInDts.count {
                scheduleNotification(app, date: nextCheckInDts[i], message: nextCheckInMessages[i])
            }
        }
    }
    
    // Unschedule all future notifications
    func clearNotifications(_ app: UIApplication) {
        app.cancelAllLocalNotifications()
    }
    
    func scheduleNotification(_ app: UIApplication, date: Date, message: String) {
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = message
        notification.alertAction = "check in"
        notification.soundName = UILocalNotificationDefaultSoundName
        app.scheduleLocalNotification(notification)
    }

    // Figure out what are the next 10 dates that will need CheckIns:
    func nextCheckInDates(goals: [Goal], dateInjector: DateInjector=DateInjector()) -> ([Date], [String]) {
        var nextDates = [Date]()
        var messages = [String]()
        let activeGoals = goals.filter { (goal) -> Bool in goal.active }
        if activeGoals.isEmpty {
            return (nextDates, messages)
        }

        var date = dateInjector.currentDate()
        // If it's too late to check in now, don't schedule one for today:
        if cal.component(.hour, from: date) >= Settings.getCheckInHour() {
            date = cal.date(byAdding: .day, value: 1, to: date)!
        }

        // Note: it really feels like you can do something more performy with the highest check-in frequency,
        // But weekly CIF + quarterly+ goal screws that up; see testNotificationsForReallyNonConformingStuff for more
        var n = 0  // Number of notifications
        while n < 10 {
            if let checkInGoal = activeGoals.filter({ $0.needsCheckInOnDate(date) }).randomElement() {
                nextDates.append(checkInTime(date))
                messages.append(checkInGoal.prompt)
                n += 1
            }

            date = cal.date(byAdding: .day, value: 1, to: date)!
        }

        return (nextDates, messages)
    }

    // Get the check in time of a given date
    func checkInTime(_ date: Date) -> Date {
        return (cal as NSCalendar).date(byAdding: .hour, value: Settings.getCheckInHour(), to: cal.startOfDay(for: date))!
    }
}
