//
//  Accounttypes.swift
//  MyLedger
//
//  Created by Moin Uddin on 3/10/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import Foundation
import CoreData

@objc(Accounttypes)
class Accounttypes: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var identifier: String
    @NSManaged var modified: String
    @NSManaged var name: String
    @NSManaged var synced: NSNumber
    @NSManaged var type: NSNumber
    @NSManaged var url: String
    @NSManaged var user_id: NSNumber

}
