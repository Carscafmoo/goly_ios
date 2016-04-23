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
    var messages: [String]
    let cal: NSCalendar
    let calOpts: NSCalendarOptions
    init() {
        goals = Goal.loadGoals()
        cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calOpts = NSCalendarOptions(rawValue: 0)
        
        messages = [String]()
        messages.append("Chiggity-check ch-check ch-check it in!")
        messages.append("Looks like it's time for an update!  Let's check in on some goals!")
        messages.append("Gooooooooooooooooooooooaaaallllllll!")
        messages.append("Time to check in on some of our goals")
        messages.append("No better time to check in than now!")
        messages.append("Let's see how we're doing on those goals!")
        messages.append("It's goal time!")
        messages.append("Hey! Listen!  You can check in on your goals...")
        messages.append("Hey, how 'bout them goals?")
    }
    
    // Schedule 10 future notifications.
    func scheduleNotifications(app: UIApplication) {
        clearNotifications(app)
        if var goals = self.goals {
            // Load goals already sorts by frequency and activity
            // If no goals are active, the first goal will be inactive and you can return
            if (!goals[0].active) { return }
            let frequency = goals[0].checkInFrequency
            
            var timeframe = Timeframe(frequency: frequency, now: NSDate()) // start now!
            
            // But... don't bother the user if they have already checked in all goals for this timeframe
            goals = goals.filter { $0.checkInFrequency == frequency && ($0.checkIns.count == 0 || $0.checkIns[0].timeframe.startDate.timeIntervalSince1970 < timeframe.startDate.timeIntervalSince1970) }
            if (goals.count == 0) { // Then you have nothing to alert about in this timeframe
                timeframe = timeframe.next()
            }
            
            
            // Now figure out the last day of each of the next 10 checkIn timeframes associated with this most frequently checked-in active goal and schedule notifications at 9:00 PM on each of those nights
            for _ in 0..<10 {
                // Find the end of the timeframe and subtract a day, then register a notification for that day
                let noteDate = cal.dateByAddingUnit(.Day, value: -1, toDate: timeframe.endDate, options: calOpts)
                scheduleNotification(app, date: noteDate!)
                
                timeframe = timeframe.next()
            }
        }
    }
    
    // Unschedule all future notifications
    func clearNotifications(app: UIApplication) {
        app.cancelAllLocalNotifications()
    }
    
    func scheduleNotification(app: UIApplication, date: NSDate) {
        let notification = UILocalNotification()
        let date = cal.startOfDayForDate(date)
        notification.fireDate = cal.dateByAddingUnit(.Hour,value: 21, toDate: date, options: calOpts)
        notification.alertBody = checkInMessage()
        notification.alertAction = "check in"
        notification.soundName = UILocalNotificationDefaultSoundName
        app.scheduleLocalNotification(notification)
    }
    
    func checkInMessage() -> String {
        // Ugh http://stackoverflow.com/questions/24003191
        let randomIndex = Int(arc4random_uniform(UInt32(messages.count)))
        
        return messages[randomIndex]
    }
}