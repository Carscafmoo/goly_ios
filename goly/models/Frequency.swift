//
//  Frequency.swift
//  goly
//
//  Created by Carson Moore on 3/19/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

enum Frequency: String {
    case Daily = "Daily"
    case Weekly = "Weekly"
    case Monthly = "Monthly"
    case Quarterly = "Quarterly"
    case Yearly = "Yearly"

    static func conforms(_ frequency: Frequency, checkInFrequency: Frequency) -> Bool {
        switch frequency {
        case .Daily:
            return checkInFrequency == .Daily
        case .Weekly:
            return checkInFrequency == .Daily || checkInFrequency == .Weekly
        case .Monthly:
            return checkInFrequency == .Daily || checkInFrequency == .Weekly || checkInFrequency == .Monthly
        case .Quarterly:
            return checkInFrequency == .Daily || checkInFrequency == .Weekly || checkInFrequency == .Monthly || checkInFrequency == .Quarterly
        case .Yearly:
            return true
        }
    }
    
    // Convert a frequency (which is an adverb) into a noun referring to the current instance (e.g., today)
    static func thisNounify(_ f: Frequency) -> String {
        switch f {
        case .Daily:
            return "today"
        case .Weekly:
            return "this week"
        case .Monthly:
            return "this month"
        case .Quarterly:
            return "this quarter"
        case .Yearly:
            return "this year"
        }
    }
    
    static func nounify(_ f: Frequency) -> String {
        switch f {
            case .Daily:
            return "day"
            case .Weekly:
            return "week"
            case .Monthly:
            return "month"
            case .Quarterly:
            return "quarter"
            case .Yearly:
            return "year"
        }
    }

    static func equals(_ lhs: Frequency, rhs: Frequency) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func order() -> Int {
        switch self {
        case .Daily:
            return 0
        case .Weekly:
            return 1
        case .Monthly:
            return 2
        case .Quarterly:
            return 3
        case .Yearly:
            return 4
        }
    }
}
