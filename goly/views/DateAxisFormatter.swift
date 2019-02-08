//
//  DateAxisFormatter.swift
//  goly
//
//  Created by Carson Moore on 1/16/17.
//  Copyright © 2017 Carson C. Moore, LLC. All rights reserved.
//

import Foundation
import Charts
class DateAxisFormatter: NSObject, IAxisValueFormatter {
    var dates: [String]?
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var retVal = ""
        if let dts = dates {
            retVal = dts[Int(value)]
        }
        
        return retVal
    }
    
}
