//
//  Accounts.swift
//  MyLedger
//
//  Created by Moin Uddin on 4/3/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import Foundation
import CoreData

@objc(Accounts)
class Accounts: NSManagedObject {

    @NSManaged var accounttype_id: NSNumber
    @NSManaged var amount: NSDecimalNumber
    @NSManaged var details: String
    @NSManaged var id: NSNumber
    @NSManaged var identifier: String
    @NSManaged var isdeleted: NSNumber
    @NSManaged var modified: String
    @NSManaged var synced: NSNumber
    @NSManaged var url: String
    @NSManaged var user_id: NSNumber
    @NSManaged var accounttype: Accounttypes

}
