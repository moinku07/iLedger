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
            return NSNumber(double: NSDate().timeIntervalSince1970 * 100000).stringValue
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
            //formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
            formatter.locale = NSLocale(localeIdentifier: "en_US")
            return formatter.stringFromDate(NSDate())
        }
    }
    
    class func getTimeString(date: NSDate, format: String? = nil) -> String{
        var dateFormat: String = format != nil ? format! : "yyyy-MM-dd HH:mm:ss"
        
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        //formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter.stringFromDate(date)
    }
    
    class func getDate(date: String, format: String? = nil) -> NSDate{
        var dateFormat: String = format != nil ? format! : "yyyy-MM-dd HH:mm:ss"
        
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        //formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter.dateFromString(date)!
    }
    
    class func getDate(date: NSDate? = nil, years: Int? = nil, months: Int? = nil, days: Int? = nil, hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil) -> NSDate{
        
        let nDate: NSDate = date != nil ? date! : NSDate()
        
        var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        //println(calendar.timeZone)
        //calendar.timeZone = NSTimeZone(name: "Asia/Dhaka")!
        calendar.locale = NSLocale(localeIdentifier: "en_US")
        
        var dateComponents: NSDateComponents = calendar.components(
            (NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond), fromDate: nDate)
        //dateComponents.timeZone = NSTimeZone(name: "Asia/Dhaka")
        
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
    
    class func getDateByAdding(date: NSDate? = nil, years: Int? = nil, months: Int? = nil, days: Int? = nil, hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil) -> NSDate{
        
        let nDate: NSDate = date != nil ? date! : NSDate()
        
        var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        //println(calendar.timeZone)
        //calendar.timeZone = NSTimeZone(name: "Asia/Dhaka")!
        calendar.locale = NSLocale(localeIdentifier: "en_US")
        
        var dateComponents: NSDateComponents = NSDateComponents()
        //dateComponents.timeZone = NSTimeZone(name: "Asia/Dhaka")
        
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
        
        let newDate: NSDate = calendar.dateByAddingComponents(dateComponents, toDate: nDate, options: NSCalendarOptions.allZeros)!
        
        return newDate
    }
    
    class func getWeekStartEndDate(date: NSDate? = nil) -> (NSDate, NSDate){
        let nDate: NSDate = date != nil ? date! : NSDate()
        var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let weekdayComponents: NSDateComponents = calendar.components(
            (NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond), fromDate: nDate)
        
        let componentsToSubtract: NSDateComponents = NSDateComponents()
        componentsToSubtract.day = 0 - weekdayComponents.weekday + 1
        componentsToSubtract.hour = 0 - weekdayComponents.hour
        componentsToSubtract.minute = 0 - weekdayComponents.minute
        componentsToSubtract.second = 0 - weekdayComponents.second
        
        let beginningOfWeek: NSDate = calendar.dateByAddingComponents(componentsToSubtract, toDate: nDate, options: NSCalendarOptions.allZeros)!
        
        let componentsToAdd: NSDateComponents = NSDateComponents()
        componentsToAdd.day = 7
        let endOfWeek: NSDate = calendar.dateByAddingComponents(componentsToAdd, toDate: beginningOfWeek, options: NSCalendarOptions.allZeros)!
        
        //println(beginningOfWeek)
        //println(endOfWeek)
        
        return (beginningOfWeek, endOfWeek)
    }
    
    class func getMonthStartEndDate(date: NSDate? = nil) -> (NSDate, NSDate){
        let nDate: NSDate = date != nil ? date! : NSDate()
        var calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let weekdayComponents: NSDateComponents = calendar.components(
            (NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond), fromDate: nDate)
        
        let componentsToSubtract: NSDateComponents = NSDateComponents()
        componentsToSubtract.day = 0 - weekdayComponents.day + 1
        componentsToSubtract.hour = 0 - weekdayComponents.hour
        componentsToSubtract.minute = 0 - weekdayComponents.minute
        componentsToSubtract.second = 0 - weekdayComponents.second
        
        let beginningOfMonth: NSDate = calendar.dateByAddingComponents(componentsToSubtract, toDate: nDate, options: NSCalendarOptions.allZeros)!
        
        var dayToAdd: Int = 0
        switch weekdayComponents.month{
        case 1,3,5,7,8,10,12:
            dayToAdd = 31
        case 2:
            dayToAdd = 28
            if weekdayComponents.year % 4 == 0{
                dayToAdd = 29
            }
        default:
            dayToAdd = 30
        }
        
        let componentsToAdd: NSDateComponents = NSDateComponents()
        componentsToAdd.day = dayToAdd - 1
        
        let endOfWeek: NSDate = calendar.dateByAddingComponents(componentsToAdd, toDate: beginningOfMonth, options: NSCalendarOptions.allZeros)!
        
        //println(beginningOfMonth)
        //println(endOfWeek)
        
        return (beginningOfMonth, endOfWeek)
    }
    
    class func getTimeStamp(timestring: String) -> NSTimeInterval{
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let date: NSDate = formatter.dateFromString(timestring)!
        return (date.timeIntervalSince1970 * 1000)
    }
    class func compare(ts1: String, ts2: String) -> NSComparisonResult{
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //formatter.timeZone = NSTimeZone(name: "Asia/Dhaka")
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        let date1: NSDate = formatter.dateFromString(ts1)!
        let date2: NSDate = formatter.dateFromString(ts2)!
        return date1.compare(date2)
    }
}
