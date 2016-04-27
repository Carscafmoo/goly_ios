//
//  Timeframe.swift
//  goly
//
//  Created by Carson Moore on 4/3/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import Foundation
class Timeframe: NSObject, NSCoding {
    var startDate: NSDate! // Start is always local midnight I guess?
    var endDate: NSDate! // Timeframe does not include end time -- it's [start, end)
    var frequency: Frequency
    var dateFormatter: NSDateFormatter!
    var cal: NSCalendar
    var calOpts: NSCalendarOptions
    
    /**
     * Create a timeframe given the time it currently is right now and the frequency for which the timeframe applies
     */
    init(frequency: Frequency, now: NSDate) {
        self.frequency = frequency
        self.dateFormatter = Timeframe.getDateFormatter()
        cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calOpts = NSCalendarOptions(rawValue: 0) // I think this means... default options?
        super.init()
        determineStartEnd(frequency, now: now)
        
        
    }
    
    // MARK: Stupid date math figuring out stuff
    func determineStartEnd(frequency: Frequency, now: NSDate) {
        switch frequency {
        case .Daily:
            // start is the current date, end is the next date
            self.startDate = cal.startOfDayForDate(now)
            self.endDate = cal.dateByAddingUnit(.Day, value: 1, toDate: self.startDate, options: calOpts)! // unclear what those are.  @TODO pick up here; play around in a playground?
        case .Weekly:
            let component = cal.component(.Weekday, fromDate: now)
            self.startDate = cal.startOfDayForDate(cal.dateByAddingUnit(.Day, value: -1 * component + 1, toDate: now, options: calOpts)!)
            self.endDate = cal.dateByAddingUnit(.Day, value: 7, toDate: self.startDate, options: calOpts)
        case .Monthly:
            self.startDate = startOfMonth(now)
            self.endDate = cal.dateByAddingUnit(.Month, value: 1, toDate: self.startDate, options: calOpts)
        case .Quarterly:
            let monthComponent = (cal.component(.Month, fromDate: now) - 1) % 3
            self.startDate = cal.dateByAddingUnit(.Month, value: -1 * monthComponent, toDate: startOfMonth(now), options: calOpts)
            self.endDate = cal.dateByAddingUnit(.Month, value: 3, toDate: self.startDate, options: calOpts)
        case .Yearly:
            let monthComponent = cal.component(.Month, fromDate: now)
            self.startDate = cal.dateByAddingUnit(.Month, value: -1 * monthComponent + 1, toDate: startOfMonth(now), options: calOpts)
            self.endDate = cal.dateByAddingUnit(.Year, value: 1, toDate: self.startDate, options: calOpts)
        }
    }
    
    // MARK: date helpers
    func startOfMonth(date: NSDate) -> NSDate {
        let component = cal.component(.Day, fromDate: date)
        
        return cal.startOfDayForDate(cal.dateByAddingUnit(.Day, value: -1 * component + 1, toDate: date, options: NSCalendarOptions(rawValue: 0))!)
    }
    
    // Return midnight on the day that this timeframe would need to be checked in
    // e.g. a daily check-in would need to be checked in on the date of its start date;
    // generally it is the day before the end date
    func checkInDate() -> NSDate {
        return cal.startOfDayForDate(cal.dateByAddingUnit(.Day, value: -1, toDate: endDate, options: calOpts)!)
    }
    
    // Is today the check in date for this timeframe?
    func isCheckInDate() -> Bool {
        return dateIsCheckInDate(NSDate())
    }
    
    // Is a given date the check in date for this timeframe?
    func dateIsCheckInDate(date: NSDate) -> Bool {
        return cal.startOfDayForDate(date) == checkInDate()
    }
    
    // MARK: NSCoding implementation
    func encodeWithCoder(aCoder: NSCoder) {
        // We only need to encode startDate, since that is a part of the timeframe, passing it as "now" should yield identical timeframe
        aCoder.encodeObject(frequency.rawValue, forKey: "frequency")
        aCoder.encodeObject(startDate, forKey: "startDate")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let frequency = aDecoder.decodeObjectForKey("frequency") as! String
        let startDate = aDecoder.decodeObjectForKey("startDate") as! NSDate
        if let freq = Frequency(rawValue: frequency) {
            self.init(frequency: freq, now: startDate)
        } else {
            return nil
        }
    }
    
    // MARK: display stuff
    func toString() -> String {
        return dateFormatter.stringFromDate(startDate)
    }
    
    func next() -> Timeframe {
        return Timeframe(frequency: frequency, now: endDate)
    }
    
    // Return a list of timeframes between two given points.  Incomplete timeframes are included
    // -- so for example, specifying quarerly timeframes between march and april should return both Q1 and Q2.
    static func fromRange(startDate: NSDate, endDate: NSDate, frequency: Frequency) -> [Timeframe] {
        var tfs = [Timeframe]()
        
        var tf = Timeframe(frequency: frequency, now: startDate)
        while (tf.startDate.timeIntervalSince1970 <= endDate.timeIntervalSince1970) { // <= includes the end date here
            tfs.append(tf)
            tf = tf.next()
        }
        
        return tfs
    }
    
    static func getDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // @TODO: Probably figure out where the user is?
        
        return dateFormatter
    }
}

func ==(a: Timeframe, b: Timeframe) -> Bool {
    return a.endDate == b.endDate && a.startDate == b.startDate
}

func !=(a: Timeframe, b: Timeframe) -> Bool {
    return !(a == b)
}