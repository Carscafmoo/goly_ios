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
    var timestamp: Date
    
    // MARK: Init
    // Initialize a brand new check-in given the cif of the goal and the value to check in with
    init(value: Int, frequency: Frequency) {
        let now = Date()
        self.timeframe = Timeframe(frequency: frequency, now: now)
        self.value = value
        self.timestamp = now
    }
    
    // convenience initializer for e.g. a specified date or time
    convenience init(value: Int, frequency: Frequency, date: Date) {
        self.init(value: value, frequency: frequency)
        self.timeframe = Timeframe(frequency: frequency, now: date)
        self.timestamp = Date()
    }
    
    // convenience initializer for coded objects
    convenience init(value: Int, timeframe: Timeframe, timestamp: Date) {
        self.init(value: value, frequency: timeframe.frequency)
        self.timeframe = timeframe
        self.timestamp = timestamp
    }
    
    // MARK: NSCoding implementation
    func encode(with aCoder: NSCoder) {
        aCoder.encode(timeframe, forKey: "timeframe")
        aCoder.encode(value, forKey: "value")
        aCoder.encode(timestamp, forKey: "timestamp")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let timeframe = aDecoder.decodeObject(forKey: "timeframe") as! Timeframe
        let value = aDecoder.decodeInteger(forKey: "value")
        let timestamp = aDecoder.decodeObject(forKey: "timestamp") as! Date
        
        self.init(value: value, timeframe: timeframe, timestamp: timestamp)
    }
}
