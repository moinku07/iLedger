//
//  Accounts.swift
//  MyLedger
//
//  Created by Moin Uddin on 4/4/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import Foundation
import CoreData

@objc(Accounts)
class Accounts: NSManagedObject {

    @NSManaged var accounttype_id: Double
    @NSManaged var amount: NSDecimalNumber
    @NSManaged var details: String
    @NSManaged var id: NSNumber
    @NSManaged var identifier: String
    @NSManaged var isdeleted: NSNumber
    @NSManaged var modified: NSDate
    @NSManaged var synced: NSNumber
    @NSManaged var url: String
    @NSManaged var user_id: NSNumber
    @NSManaged var accounttype: Accounttypes
    
    // new in v3
    @NSManaged var created: NSDate
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.created = NSDate()
    }

}
