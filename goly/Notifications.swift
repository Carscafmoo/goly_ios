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
            
            // If the most frequent goal CI frequency is daily, you're in good shape.  If it's weekly though, you're in trouble.  All others are fine.
            var cifs = [goals[0].checkInFrequency]
            if (goals[0].checkInFrequency == .Weekly) {
                // See if there's any non-weekly goals; take the lowest check-in frequency among them
                let nonWeeklies = goals.filter { return $0.checkInFrequency != .Weekly; }
                if nonWeeklies.count > 0 {
                    // Should still be able to take the first one -- they should still be in order
                    cifs.append(nonWeeklies[0].checkInFrequency)
                }
            }
            
            // Now, loop through the next 10 dates on which anything would need to check in
            // Start now...
            let date = Date()
            var (nextCheckInDate, nextCheckInTimeframe) = calculateNextCheckIn(cifs, date: date)
            
            let nextCheckInTime = checkInTime(nextCheckInDate)
            
            // Don't schedule anything for today if it's past check-in time or if there are no goals to check in
            if (nextCheckInTime.timeIntervalSince1970 <= date.timeIntervalSince1970 || Goal.goalsNeedingCheckInOnDate(nextCheckInDate).count == 0) {
                (nextCheckInDate, nextCheckInTimeframe) = calculateNextCheckIn(cifs, date: nextCheckInTimeframe.next().startDate as Date)
            }
            
            // Now go through the next ten and schedule notifications if we have any goals coming due on these timeframes
            for _ in 0..<10 {
                let goalsToCi = goals.filter { return $0.needsCheckInOnDate(nextCheckInDate) }
                let randomIndex = Int(arc4random_uniform(UInt32(goalsToCi.count)))
                let msg = goalsToCi[randomIndex].prompt
                scheduleNotification(app, date: nextCheckInDate, message: msg)
                
                (nextCheckInDate, nextCheckInTimeframe) = calculateNextCheckIn(cifs, date: nextCheckInTimeframe.next().startDate as Date)
            }
        }
    }
    
    // Unschedule all future notifications
    func clearNotifications(_ app: UIApplication) {
        app.cancelAllLocalNotifications()
    }
    
    func scheduleNotification(_ app: UIApplication, date: Date, message: String) {
        let notification = UILocalNotification()
        notification.fireDate = checkInTime(date)
        notification.alertBody = message
        notification.alertAction = "check in"
        notification.soundName = UILocalNotificationDefaultSoundName
        app.scheduleLocalNotification(notification)
    }
    
    // Calculate the next check-in time of any frequency given a date.
    // E.g., if you have a weekly and monthly frequency, and you pass May 30, 2016 this will return May 31 (EOM)
    func calculateNextCheckIn(_ cifs: [Frequency], date: Date) -> (Date, Timeframe) {
        var tf = Timeframe(frequency: cifs[0], now: date)
        var cid = tf.checkInDate()
        for (index, cif) in cifs.enumerated() {
            if (index == 0) { continue }
            let newTf = Timeframe(frequency:cif, now:date)
            let newCid = newTf.checkInDate()
            if (newCid.timeIntervalSince1970 < cid.timeIntervalSince1970) {
                tf = newTf
                cid = newCid
            }
        }
        
        return (cid, tf)
    }
    
    // Get the check in time of a given date
    func checkInTime(_ date: Date) -> Date {
        return (cal as NSCalendar).date(byAdding: .hour, value: 21, to: cal.startOfDay(for: date))!
    }
}
