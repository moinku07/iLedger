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
    
    class var currentDate: NSDate {
        get {
            return NSDate()
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
    
    class func getTimeString(date: NSDate, format: String? = nil) -> String{
        var dateFormat: String = format != nil ? format! : "yyyy-MM-dd HH:mm:ss"
        
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter.stringFromDate(date)
    }
    
    class func getDate(date: String, format: String? = nil) -> NSDate{
        var dateFormat: String = format != nil ? format! : "yyyy-MM-dd HH:mm:ss"
        
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter.dateFromString(date)!
    }
    
    class func getDate(date: NSDate? = nil, years: Int? = nil, months: Int? = nil, days: Int? = nil, hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil) -> NSDate{
        
        let nDate: NSDate = date != nil ? date! : NSDate()
        
        var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.timeZone = NSTimeZone(name: "Asia/Dhaka")!
        calendar.locale = NSLocale(localeIdentifier: "en_US")
        
        var dateComponents: NSDateComponents = calendar.components(
            NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond, fromDate: nDate)
        dateComponents.timeZone = NSTimeZone(name: "Asia/Dhaka")
        //dateComponents.locale = NSLocale(localeIdentifier: "en_US")
        
        if years != nil{
            dateComponents.year = years!
        }
        if months != nil{
            dateComponents.month = months!
        }
        if days != nil{
            dateComponents.day = days!
        }
        if hours != nil{
            dateComponents.hour = hours!
        }
        if minutes != nil{
            dateComponents.minute = minutes!
        }
        if seconds != nil{
            dateComponents.second = seconds!
        }
        
        let newDate: NSDate = calendar.dateFromComponents(dateComponents)!
        
        return newDate
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
