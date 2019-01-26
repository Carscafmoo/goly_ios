//
//  Timeframe.swift
//  goly
//
//  Created by Carson Moore on 4/3/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import Foundation
class Timeframe: NSObject, NSCoding {
    var startDate: Date! // Start is always local midnight I guess?
    var endDate: Date! // Timeframe does not include end time -- it's [start, end)
    var frequency: Frequency
    var dateFormatter: DateFormatter!
    var cal: Calendar
    
    /**
     * Create a timeframe given the time it currently is right now and the frequency for which the timeframe applies
     */
    init(frequency: Frequency, now: Date) {
        self.frequency = frequency
        self.dateFormatter = Timeframe.getDateFormatter()
        cal = Calendar(identifier: Calendar.Identifier.gregorian)
        super.init()
        determineStartEnd(frequency, now: now)
    }
    
    required convenience init?(frequency: Frequency, startDate: Date, endDate: Date) {
        self.init(frequency: frequency, now: startDate)
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // MARK: Stupid date math figuring out stuff
    func determineStartEnd(_ frequency: Frequency, now: Date) {
        switch frequency {
        case .Daily:
            // start is the current date, end is the next date
            self.startDate = cal.startOfDay(for: now)
            self.endDate = (cal as Calendar).date(byAdding: .day, value: 1, to: self.startDate)!
        case .Weekly:
            let component = (cal as Calendar).component(.weekday, from: now)
            self.startDate = cal.startOfDay(for: (cal as Calendar).date(byAdding: .day, value: -1 * component + 1, to: now)!)
            self.endDate = (cal as Calendar).date(byAdding: .day, value: 7, to: self.startDate)
        case .Monthly:
            self.startDate = startOfMonth(now)
            self.endDate = (cal as Calendar).date(byAdding: .month, value: 1, to: self.startDate)
        case .Quarterly:
            let monthComponent = ((cal as Calendar).component(.month, from: now) - 1) % 3
            self.startDate = (cal as Calendar).date(byAdding: .month, value: -1 * monthComponent, to: startOfMonth(now))
            self.endDate = (cal as Calendar).date(byAdding: .month, value: 3, to: self.startDate)
        case .Yearly:
            let monthComponent = (cal as Calendar).component(.month, from: now)
            self.startDate = (cal as Calendar).date(byAdding: .month, value: -1 * monthComponent + 1, to: startOfMonth(now))
            self.endDate = (cal as Calendar).date(byAdding: .year, value: 1, to: self.startDate)
        }
    }
    
    func boundByGoalTimeframe(goalTimeframe: Timeframe) {
        // Used in cases where the goal has a nonconforming timeframe to the checkInTimeframe
        // So for example monthly TFs with Weekly CheckIn TFs could have a case where the
        // CheckInTF spans two months
        self.startDate = max(self.startDate, goalTimeframe.startDate)
        self.endDate = min(self.endDate, goalTimeframe.endDate)
    }
    
    // MARK: date helpers
    func startOfMonth(_ date: Date) -> Date {
        let component = (cal as Calendar).component(.day, from: date)
        
        return cal.startOfDay(for: (cal as NSCalendar).date(byAdding: .day, value: -1 * component + 1, to: date, options: NSCalendar.Options(rawValue: 0))!)
    }
    
    // Return midnight on the day that this timeframe would need to be checked in
    // e.g. a daily check-in would need to be checked in on the date of its start date;
    // generally it is the day before the end date
    func checkInDate() -> Date {
        return cal.startOfDay(for: (cal as NSCalendar).date(byAdding: .day, value: -1, to: endDate)!)
    }
    
    // Is today the check in date for this timeframe?
    func isCheckInDate() -> Bool {
        return dateIsCheckInDate(Date())
    }
    
    // Is a given date the check in date for this timeframe?
    func dateIsCheckInDate(_ date: Date) -> Bool {
        return cal.startOfDay(for: date) == checkInDate()
    }
    
    // MARK: NSCoding implementation
    func encode(with aCoder: NSCoder) {
        // as mentioned elsewhere, we store the String rather than the actual date to deal with timezone issues (e.g., if I store 23:01:00 in Pacific Time and move to Mountain Time, that would get cast to 00:01:00 of *the next day* when it was loaded in.
        aCoder.encode(frequency.rawValue, forKey: "frequency")
        aCoder.encode(self.dateFormatter.string(from: self.startDate), forKey: "startDate")
        aCoder.encode(self.dateFormatter.string(from: self.endDate), forKey: "endDate")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        var startDate: Date
        var endDate: Date? = nil
        let frequency = aDecoder.decodeObject(forKey: "frequency") as! String
        if let start = aDecoder.decodeObject(forKey: "startDate") as? String {
            startDate = Timeframe.getDateFormatter().date(from: start)! // This is not the best way to do this :-(
        } else { // This bit is left in for legacy code
            startDate = aDecoder.decodeObject(forKey: "startDate") as! Date
        }

        if let end = aDecoder.decodeObject(forKey: "endDate") as? String {
            endDate = Timeframe.getDateFormatter().date(from: end)!
        }

        if let freq = Frequency(rawValue: frequency) {
            if endDate != nil {
                self.init(frequency: freq, startDate: startDate, endDate: endDate!)
            } else {
                self.init(frequency: freq, now: startDate)
            }
        } else {
            return nil
        }
    }
    
    // MARK: display stuff
    func toString() -> String {
        // If it's a standard timeframe, give it to me as "this month", "today", etc.
        if self.isCurrent() && self.isStandard() {
            return Frequency.thisNounify(self.frequency)
        }

        // Otherwise, if it's current but not standard (and weekly), use day names:
        if self.isCurrent() && self.frequency == .Weekly {
            return "\(cal.component(.weekday, from: startDate)) - \(cal.component(.weekday, from: endDate))"
        }

        if self.frequency == .Daily {
            let df = DateFormatter()
            df.locale = Locale.current
            df.setLocalizedDateFormatFromTemplate("MMMMdYYYY")
            return df.string(from: startDate)
        }

        if self.frequency == .Yearly {
            let df = DateFormatter()
            df.locale = Locale.current
            df.setLocalizedDateFormatFromTemplate("YYYY")
            return df.string(from: startDate)
        }

        // Otherwise, just give me start -> end dates in a reasonable format:
        let df = DateIntervalFormatter()
        df.locale = Locale.current
        df.dateStyle = .medium
        df.timeStyle = .none

        // We have to subtract one second to get the end of the preceding day here
        return df.string(from: startDate, to: endDate.addingTimeInterval(TimeInterval(-1)))
    }

    // Used to display the value solely for charting purposes -- could use some... improvements, I'm sure
    func toChartString() -> String {
        return dateFormatter.string(from: startDate)
    }
    
    func next() -> Timeframe {
        let nextTimeframe = Timeframe(frequency: frequency, now: endDate)
        if nextTimeframe.endDate < endDate {
            nextTimeframe.startDate = endDate // You may have to do this for nonconformant tfs
        }

        return nextTimeframe
    }
    
    // Return a list of timeframes between two given points.  Incomplete timeframes are included
    // -- so for example, specifying quarerly timeframes between march and april should return both Q1 and Q2.
    static func fromRange(_ startDate: Date, endDate: Date, frequency: Frequency) -> [Timeframe] {
        var tfs = [Timeframe]()
        
        var tf = Timeframe(frequency: frequency, now: startDate)
        while (tf.startDate.timeIntervalSince1970 <= endDate.timeIntervalSince1970) { // <= includes the end date here
            tfs.append(tf)
            tf = tf.next()
        }
        
        return tfs
    }
    
    func subTimeframes(subFrequency: Frequency) -> [Timeframe] {
        let tfs = Timeframe.fromRange(self.startDate, endDate: self.endDate, frequency: subFrequency)
        if tfs.count > 0 {
            tfs.first!.startDate = self.startDate
            tfs.last!.endDate = self.endDate
        }

        return tfs
    }

    // Identify non-conformant timeframes (e.g., a week not starting on (day of week) but instead the first)
    func isStandard() -> Bool {
        return self == Timeframe(frequency: self.frequency, now: self.startDate)
    }

    func isCurrent() -> Bool {
        let now = Date()
        return startDate <= now && now < endDate
    }

    static func getDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US") // @TODO: Probably figure out where the user is?
        
        return dateFormatter
    }
}

func ==(a: Timeframe, b: Timeframe) -> Bool {
    return a.endDate == b.endDate && a.startDate == b.startDate
}

func !=(a: Timeframe, b: Timeframe) -> Bool {
    return !(a == b)
}
