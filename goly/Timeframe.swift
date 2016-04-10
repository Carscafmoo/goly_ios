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
    
    /**
     * Create a timeframe given the time it currently is right now and the frequency for which the timeframe applies
     */
    init(frequency: Frequency, now: NSDate) {
        self.frequency = frequency
        super.init()
        determineStartEnd(frequency, now: now)
    }
    
    // MARK: Stupid date math figuring out stuff
    func determineStartEnd(frequency: Frequency, now: NSDate) {
        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let options = NSCalendarOptions(rawValue: 0) // I think this means... default options?
        switch frequency {
        case .Daily:
            // start is the current date, end is the next date
            self.startDate = cal.startOfDayForDate(now)
            self.endDate = cal.dateByAddingUnit(.Day, value: 1, toDate: self.startDate, options: options)! // unclear what those are.  @TODO pick up here; play around in a playground?
        case .Weekly:
            let component = cal.component(.Weekday, fromDate: now)
            self.startDate = cal.startOfDayForDate(cal.dateByAddingUnit(.Day, value: -1 * component + 1, toDate: now, options: options)!)
            self.endDate = cal.dateByAddingUnit(.Day, value: 7, toDate: self.startDate, options: options)
        case .Monthly:
            self.startDate = startOfMonth(now, cal: cal)
            self.endDate = cal.dateByAddingUnit(.Month, value: 1, toDate: self.startDate, options: options)
        case .Quarterly:
            let monthComponent = (cal.component(.Month, fromDate: now) - 1) % 3
            self.startDate = cal.dateByAddingUnit(.Month, value: -1 * monthComponent, toDate: startOfMonth(now, cal: cal), options: options)
            self.endDate = cal.dateByAddingUnit(.Month, value: 3, toDate: self.startDate, options: options)
        case .Yearly:
            let monthComponent = cal.component(.Month, fromDate: now)
            self.startDate = cal.dateByAddingUnit(.Month, value: -1 * monthComponent + 1, toDate: startOfMonth(now, cal: cal), options: options)
            self.endDate = cal.dateByAddingUnit(.Year, value: 1, toDate: self.startDate, options: options)
        }
    }
    
    // MARK: date helpers
    func startOfMonth(date: NSDate, cal: NSCalendar) -> NSDate {
        let component = cal.component(.Day, fromDate: date)
        
        return cal.startOfDayForDate(cal.dateByAddingUnit(.Day, value: -1 * component + 1, toDate: date, options: NSCalendarOptions(rawValue: 0))!)
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
}

func ==(a: Timeframe, b: Timeframe) -> Bool {
    return a.endDate == b.endDate && a.startDate == b.startDate
}

func !=(a: Timeframe, b: Timeframe) -> Bool {
    return !(a == b)
}