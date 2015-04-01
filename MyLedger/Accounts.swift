//
//  Accounts.swift
//  MyLedger
//
//  Created by Moin Uddin on 3/28/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import Foundation
import CoreData

@objc(Accounts)
class Accounts: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var identifier: String
    @NSManaged var isdeleted: NSNumber
    @NSManaged var user_id: NSNumber
    @NSManaged var details: String
    @NSManaged var amount: NSDecimalNumber
    @NSManaged var modified: String
    @NSManaged var url: String
    @NSManaged var synced: NSNumber
    @NSManaged var accounttype_id: NSNumber

}
