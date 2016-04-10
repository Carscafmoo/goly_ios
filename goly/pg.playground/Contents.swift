//: Playground - noun: a place where people can play

import Cocoa
// MARK: date helpers
func startOfMonth(date: NSDate, cal: NSCalendar) -> NSDate {
    let component = cal.component(.Day, fromDate: date)
    
    return cal.startOfDayForDate(cal.dateByAddingUnit(.Day, value: -1 * component + 1, toDate: date, options: NSCalendarOptions(rawValue: 0))!)
}
var str = "Hello, playground"
let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
let strDate = "2016-02-29 19:17:17" // "2015-10-06T15:42:34Z"
let dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
let now = dateFormatter.dateFromString(strDate)!
let options = NSCalendarOptions(rawValue: 0)
    // start is the current date, end is the next date
let monthComponent = cal.component(.Month, fromDate: now)
let startDate = cal.dateByAddingUnit(.Month, value: -1 * monthComponent + 1, toDate: startOfMonth(now, cal: cal), options: options)!
let endDate = cal.dateByAddingUnit(.Year, value: 1, toDate: startDate, options: options)

let rightnow = NSDate()

endDate!.timeIntervalSince1970 > rightnow.timeIntervalSince1970

let numbers = [1,2,3,4,5,6]

let a = numbers.sort {
    // Date objects themselves are not comparable for some stupid reason in Swift
    return $0 > $1
}

print(numbers)
print(a)