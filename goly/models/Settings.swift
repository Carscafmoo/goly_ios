//
//  Settings.swift
//  goly
//
//  Created by Carson Moore on 3/2/19.
//  Copyright © 2019 Carson C. Moore, LLC. All rights reserved.
//

import Foundation

class Settings {
    struct SettingsBundleKeys {
        static let buildVersionKey = "build_preference"
        static let appVersionKey = "version_preference"
        static let checkInTimeKey = "check_in_time_preference"
        static let weekBeginsKey = "week_begins_preference"
    }

    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: SettingsBundleKeys.appVersionKey)
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: SettingsBundleKeys.buildVersionKey)
    }

    class func getCheckInHour() -> Int {
        let intValue = UserDefaults.standard.integer(forKey: SettingsBundleKeys.checkInTimeKey)
        if intValue == 0 {
            return 21  // I guess this is the only way to ... do default values ... ?
        }

        return intValue
    }

    class func getWeekBeginsDay() -> Int {
        return UserDefaults.standard.integer(forKey: SettingsBundleKeys.weekBeginsKey) // The default value is actually 0 anyway, so :/
    }
}
