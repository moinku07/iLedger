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
}
