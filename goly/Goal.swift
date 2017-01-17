//
//  Goal.swift
//  goly
//
//  Created by Carson Moore on 3/19/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//
import Foundation
class Goal: NSObject, NSCoding {
    var name: String
    var prompt: String
    var frequency: Frequency
    var target: Int
    var type: Type
    var checkInFrequency: Frequency
    var active: Bool
    var created: Date
    var checkIns: [CheckIn]
    
    // I am not certain I fully understand why this is a good practice
    struct PropertyKey {
        static let nameKey = "name"
        static let promptKey = "prompt"
        static let frequencyKey = "frequency"
        static let targetKey = "target"
        static let typeKey = "type"
        static let checkInFrequencyKey = "checkInFrequency"
        static let activeKey = "active"
        static let createdKey = "created"
        static let checkInsKey = "checkIns"
    }
    
    // MARK: Archiving paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("goals")
    
    init?(name: String, prompt: String, frequency: Frequency, target: Int, type: Type, checkInFrequency: Frequency) {
        self.name = name
        self.prompt = prompt
        self.frequency = frequency
        self.target = target
        self.type = type
        self.checkInFrequency = checkInFrequency
        self.active = true
        self.created = Date()
        self.checkIns = [CheckIn]()
        super.init()
        
        if (name.isEmpty || prompt.isEmpty || target < 0 || !Frequency.conforms(frequency, checkInFrequency: checkInFrequency)) {
            return nil
        }
    }
    
    // MARK: Check-ins
    //  - dedupe -- make sure you have no existing cis with this timeframe
    //  - sort -- make sure we sort by timeframe DESC so we always have most recent cis first -- this is ESSENTIAL for 
    //              lastCheckInTime to work :-)
    func checkIn(_ value: Int, date: Date) {
        let timeframe = Timeframe(frequency: self.checkInFrequency, now: date)
        
        checkIns = checkIns.filter { (x) in x.timeframe != timeframe }
        
        checkIns.append(CheckIn(value: value, frequency: self.checkInFrequency, date: date))
        self.checkIns = checkIns.sorted {
            // Date objects themselves are not comparable for some stupid reason in Swift
            return $0.timeframe.startDate.timeIntervalSince1970 > $1.timeframe.startDate.timeIntervalSince1970
        }
    }
    
    // Helper to get last check-in time displayed on list view
    func lastCheckInTime() -> Date? {
        if let ci = checkIns.first {
            return ci.timeframe.startDate as Date?
        } else {
            return nil
        }
    }
    
    // Calculate the total value for the current timeframe
    func currentProgress() -> Int {
        let timeframe = Timeframe(frequency: self.frequency, now: Date())
        let value = timeframeValue(timeframe)
        
        return value
    }
    
    // Calculate the total value for a given timeframe
    func timeframeValue(_ tf: Timeframe) -> Int {
        // Check-ins are sorted by date descending so we can break once we exit the timeframe
        var val = 0
        for ci in checkIns {
            if (ci.timeframe.endDate.timeIntervalSince1970 <= tf.startDate.timeIntervalSince1970) {
                break
            }
            
            if (ci.timeframe.startDate.timeIntervalSince1970 < tf.endDate.timeIntervalSince1970) {
                val += ci.value
            }
        }
        
        return val
    }
    
    // Determine whether a goal needs to be checked in right now.
    // Contains some slight optimization compared to needsCheckInOnDate
    func needsCheckIn() -> Bool {
        if (!active) { return false }
        
        let tf = Timeframe(frequency: checkInFrequency, now: Date())
        if (!tf.isCheckInDate()) { return false; }
        if (checkIns.count == 0) { return true }
        
        return tf.startDate.timeIntervalSince1970 > checkIns[0].timeframe.startDate.timeIntervalSince1970
    }
    
    // Determine whether a goal needs to be checked in at a given time
    func needsCheckInOnDate(_ date: Date) -> Bool {
        if (!active) { return false }
        
        let tf = Timeframe(frequency: checkInFrequency, now: date)
        if (!tf.dateIsCheckInDate(date)) { return false; }
        if (checkIns.count == 0) { return true }
        
        // Uses an optimization handy for most common use case where check-in date is in the future (for notification scheduling)
        if let _ = getCheckInForDate(date) { return false }
        
        return true
    }
    
    // Pull a check-in for a given date.  If none exists, return nil
    func getCheckInForDate(_ date: Date) -> CheckIn? {
        // Standard optimization -- if you ever hit a case where the date in question is > check In end date
        // You can break, since they're ordered in reverse chron order by timeframe
        for ci in checkIns {
            if (ci.timeframe.endDate.timeIntervalSince1970 < date.timeIntervalSince1970) { break }
            let timeframe = Timeframe(frequency: checkInFrequency, now: date)
            if (ci.timeframe == timeframe) { return ci }
        }
        
        return nil
    }
    
    // MARK: NSCoding implementation
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(prompt, forKey: PropertyKey.promptKey)
        aCoder.encode(frequency.rawValue, forKey: PropertyKey.frequencyKey)
        aCoder.encode(target, forKey: PropertyKey.targetKey)
        aCoder.encode(type.rawValue, forKey: PropertyKey.typeKey)
        aCoder.encode(checkInFrequency.rawValue, forKey: PropertyKey.checkInFrequencyKey)
        aCoder.encode(active, forKey: PropertyKey.activeKey)
        aCoder.encode(created, forKey: PropertyKey.createdKey)
        aCoder.encode(checkIns, forKey: PropertyKey.checkInsKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        let prompt = aDecoder.decodeObject(forKey: PropertyKey.promptKey) as! String
        let frequency = aDecoder.decodeObject(forKey: PropertyKey.frequencyKey) as! String
        let target = aDecoder.decodeInteger(forKey: PropertyKey.targetKey)
        let type = aDecoder.decodeObject(forKey: PropertyKey.typeKey) as! String
        let checkInFrequency = aDecoder.decodeObject(forKey: PropertyKey.checkInFrequencyKey) as! String
        let active = aDecoder.decodeBool(forKey: PropertyKey.activeKey)
        let created = aDecoder.decodeObject(forKey: PropertyKey.createdKey) as! Date
        let checkIns = aDecoder.decodeObject(forKey: PropertyKey.checkInsKey) as! [CheckIn]
        
        if let freq = Frequency(rawValue: frequency), let cif = Frequency(rawValue: checkInFrequency), let typ = Type(rawValue: type) {
            self.init(name: name, prompt: prompt, frequency: freq, target: target, type: typ, checkInFrequency: cif)
            self.active = active
            self.created = created
            self.checkIns = checkIns
        } else {
            return nil
        }
    }
    
    // MARK: Goal collection helpers
    static func loadGoals() -> [Goal]? {
        if let goals = NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [Goal] {
            return Goal.sortGoals(goals)
        }
            
        return nil
    }
    
    static func saveGoals(_ goals: [Goal]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(goals, toFile: ArchiveURL.path)
        if isSuccessfulSave {
        } else {
            print("Save unsuccessful :-(")
        }
    }
    
    static func sortGoals(_ goals: [Goal]) -> [Goal] {
        return goals.sorted {
            if ($0.active && !$1.active) { return true; } // active always comes first
            if (!$0.active && $1.active) { return false; }
            
            // That which is more frequently checked in should come first
            if ($0.checkInFrequency.hashValue < $1.checkInFrequency.hashValue) { return true; }
            if ($0.checkInFrequency.hashValue > $1.checkInFrequency.hashValue) { return false; }
            
            // Otherwise, sort by name I guess
            return $0.name < $1.name
        }
    }
    
    // Return a list of goals that need to be checked in today
    static func goalsNeedingCheckIn() -> [Goal] {
        let retGoals = [Goal]()
        if let goals = loadGoals() {
            return goals.filter { $0.needsCheckIn() }
        }
        
        return retGoals
    }
    
    // Here again, there are some optimizations in needsCheckIn, so we have a separate function
    static func goalsNeedingCheckInOnDate(_ date: Date) -> [Goal] {
        let retGoals = [Goal]()
        if let goals = loadGoals() {
            return goals.filter { $0.needsCheckInOnDate(date) }
        }
        
        return retGoals
    }
}
