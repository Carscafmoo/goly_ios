//
//  MockDateInjector.swift
//  golyTests
//
//  Created by Carson Moore on 3/6/19.
//  Copyright © 2019 Carson C. Moore, LLC. All rights reserved.
//

import Foundation
class MockDateInjector: DateInjector {
    let date: Date
    let dateFormatter: DateFormatter
    init(dateString: String) {  // In format YYYY-MM-DD HH:mm:ss
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let date = dateFormatter.date(from: dateString)!

        self.date = date
    }

    override func currentDate() -> Date {
        return date
    }
}
