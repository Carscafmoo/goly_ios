//
//  CheckIn.swift
//  goly
//
//  Created by Carson Moore on 4/3/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import Foundation
class CheckIn: NSObject, NSCoding {
    var timeframe: Timeframe
    var value: Int
    var timestamp: NSDate
    
    // MARK: Init
    // Initialize a brand new check-in given the cif of the goal and the value to check in with
    init(value: Int, frequency: Frequency) {
        let now = NSDate()
        self.timeframe = Timeframe(frequency: frequency, now: now)
        self.value = value
        self.timestamp = now
    }
    
    // convenience initializer for e.g. a specified date or time
    convenience init(value: Int, frequency: Frequency, date: NSDate) {
        self.init(value: value, frequency: frequency)
        self.timeframe = Timeframe(frequency: frequency, now: date)
        self.timestamp = NSDate()
    }
    
    // convenience initializer for coded objects
    convenience init(value: Int, timeframe: Timeframe, timestamp: NSDate) {
        self.init(value: value, frequency: timeframe.frequency)
        self.timeframe = timeframe
        self.timestamp = timestamp
    }
    
    // MARK: NSCoding implementation
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(timeframe, forKey: "timeframe")
        aCoder.encodeInteger(value, forKey: "value")
        aCoder.encodeObject(timestamp, forKey: "timestamp")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let timeframe = aDecoder.decodeObjectForKey("timeframe") as! Timeframe
        let value = aDecoder.decodeIntegerForKey("value")
        let timestamp = aDecoder.decodeObjectForKey("timestamp") as! NSDate
        
        self.init(value: value, timeframe: timeframe, timestamp: timestamp)
    }
}