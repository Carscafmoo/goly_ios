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
        // We only need to encode start, since that is a part of the timeframe, passing it as "now" should yield identical timeframe; as mentioned, we store the String rather than the actual date to deal with timezone issues (e.g., if I store 23:01:00 in Pacific Time and move to Mountain Time, that would get cast to 00:01:00 of *the next day* when it was loaded in.
        aCoder.encode(frequency.rawValue, forKey: "frequency")
        aCoder.encode(self.dateFormatter.string(from: self.startDate), forKey: "startDate")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        var startDate: Date
        let frequency = aDecoder.decodeObject(forKey: "frequency") as! String
        if let start = aDecoder.decodeObject(forKey: "startDate") as? String {
            startDate = Timeframe.getDateFormatter().date(from: start)! // This is not the best way to do this :-(
        } else {
            startDate = aDecoder.decodeObject(forKey: "startDate") as! Date
        }
        
        if let freq = Frequency(rawValue: frequency) {
            self.init(frequency: freq, now: startDate)
        } else {
            return nil
        }
    }
    
    // MARK: display stuff
    func toString() -> String {
        return dateFormatter.string(from: startDate)
    }
    
    func next() -> Timeframe {
        return Timeframe(frequency: frequency, now: endDate)
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
