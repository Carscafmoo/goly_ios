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

    static func conforms(frequency: Frequency, checkInFrequency: Frequency) -> Bool {
        switch frequency {
        case .Daily:
            return checkInFrequency == .Daily
        case .Weekly:
            return checkInFrequency == .Daily || checkInFrequency == .Weekly
        case .Monthly:
            return checkInFrequency == .Daily || checkInFrequency == .Monthly
        case .Quarterly:
            return checkInFrequency == .Daily || checkInFrequency == .Monthly || checkInFrequency == .Quarterly
        case .Yearly:
            return checkInFrequency != .Weekly
        }
    }
}
