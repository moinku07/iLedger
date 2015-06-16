//
//  Accounttypes.swift
//  MyLedger
//
//  Created by Moin Uddin on 4/4/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import Foundation
import CoreData

@objc(Accounttypes)
class Accounttypes: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var identifier: String
    @NSManaged var isdeleted: NSNumber
    @NSManaged var modified: NSDate
    @NSManaged var name: String
    @NSManaged var synced: NSNumber
    @NSManaged var type: NSNumber
    @NSManaged var url: String
    @NSManaged var user_id: NSNumber
    @NSManaged var account: NSSet
    
    // new in v2
    @NSManaged var created: NSDate
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.created = NSDate()
    }

}
