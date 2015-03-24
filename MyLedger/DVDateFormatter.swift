//
//  DVDateFormatter.swift
//  MyLedger
//
//  Created by Moin Uddin on 3/10/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit

class DVDateFormatter: NSObject {
    class var currentTimestamp: String {
        get {
            return "\(NSDate().timeIntervalSince1970 * 1000)"
        }
    }
    class var currentTimeString: String {
        get {
            let formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
            formatter.locale = NSLocale(localeIdentifier: "en_US")
            return formatter.stringFromDate(NSDate())
        }
    }
    
    class func getTimeStamp(timestring: String) -> NSTimeInterval{
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let date: NSDate = formatter.dateFromString(timestring)!
        return (date.timeIntervalSince1970 * 1000)
    }
    class func compare(ts1: String, ts2: String) -> NSComparisonResult{
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let date1: NSDate = formatter.dateFromString(ts1)!
        let date2: NSDate = formatter.dateFromString(ts2)!
        return date1.compare(date2)
    }
}
