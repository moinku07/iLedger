//
//  DVSync.swift
//  MyLedger
//
//  Created by Moin Uddin on 3/15/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

// Global variables for AccountTypes
var _isSyncAccountTypes: Bool = false
var _lastAccounttypeModified: NSString?

// GLobal variable for Accounts
var _isSyncAccounts: Bool = false
var _lastAccountModified: NSString?

class DVSync: NSObject {
    
    // MARK: - synchonizeAccountTypes
    class func synchronizeAccountTypes(){
        //println(NSTimeZone.knownTimeZoneNames())
        //println("currentTimeString: \(DVDateFormatter.currentTimeString)")
        //return
        //println("here")
        //_isSyncAccountTypes = true
        
        if DataManager.isConnectedToNetwork() == true && _isSyncAccountTypes == false{
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let last_synced: NSString = prefs.objectForKey("last_synced") as? NSString{
                _lastAccounttypeModified = last_synced
                println("_lastAccounttypeModified: \(_lastAccounttypeModified)")
            }else{
                let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                let predicate: NSPredicate = NSPredicate(format: "synced == YES")
                let sorter: NSSortDescriptor = NSSortDescriptor(key: "modified", ascending: false)
                let results: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: [sorter], managedObjectContext: moc, limit: 1)
                if results.count > 0{
                    let accounttype: Accounttypes = results.lastObject as! Accounttypes
                    _lastAccounttypeModified = DVDateFormatter.getTimeString(accounttype.modified, format: nil)
                    println("_lastAccounttypeModified: \(_lastAccounttypeModified)")
                }else{
                    _lastAccounttypeModified = "0000-00-00 00:00:00"
                    println("_lastAccounttypeModified: \(_lastAccounttypeModified)")
                }
            }
            //println("here1")
            DVSync.postLocalAccounttypeData()
        }
    }
    
    // MARK: - postLocalData
    class func postLocalAccounttypeData(){
        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
        let predicate: NSPredicate = NSPredicate(format: "synced == NO")
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        let results: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: [sorter], managedObjectContext: moc, limit: nil)
        
        var postData: NSMutableArray = NSMutableArray()
        if results.count > 0{
            _isSyncAccountTypes = true
            for (index, item) in enumerate(results){
                let accounttype: Accounttypes = item as! Accounttypes
                //println(accounttype.synced)
                //continue
                if accounttype.id > 0{
                    let dict: NSDictionary = [
                        "identifier": accounttype.identifier,
                        "name": accounttype.name,
                        "type": accounttype.type,
                        "modified": DVDateFormatter.getTimeString(accounttype.modified, format: nil),
                        "created": DVDateFormatter.getTimeString(accounttype.created, format: nil),
                        "user_id": accounttype.user_id,
                        "id" : accounttype.id,
                        "isdeleted": accounttype.isdeleted
                    ]
                    postData.addObject(dict)
                }else{
                    let dict: NSDictionary = [
                        "identifier": accounttype.identifier,
                        "name": accounttype.name,
                        "type": accounttype.type,
                        "modified": DVDateFormatter.getTimeString(accounttype.modified, format: nil),
                        "created": DVDateFormatter.getTimeString(accounttype.created, format: nil),
                        "user_id": accounttype.user_id,
                        "id" : "",
                        "isdeleted": accounttype.isdeleted
                    ]
                    postData.addObject(dict)
                }
            }
            DVSync.accounttypePostSync(["Accounttype": ["data": postData]])
        }else{
            DVSync.fetchServerAccounttypeData()
        }
    }
    
    // MARK: - accounttypePostSync
    class func accounttypePostSync(postdata: NSDictionary){
        //println(postdata)
        
        DataManager.postDataAsyncWithCallback("accounttypes/sync", data: postdata, json: true, completion: { (data, error) -> Void in
            dispatch_async(dispatch_get_main_queue()){
                println("accounttypes/sync")
                //println(data)
                if error == nil && data != nil{
                    //println(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    if let response: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary{
                        if response.objectForKey("success") as? Bool == true{
                            if let savedData: NSArray = response.objectForKey("data") as? NSArray{
                                if savedData.count > 0{
                                    for item in savedData{
                                        //println("here")
                                        let dict: NSDictionary = item as! NSDictionary
                                        let identifier: NSString = dict.objectForKey("identifier") as! NSString
                                        println("identifier: \(identifier)")
                                        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                                        let predicate: NSPredicate = NSPredicate(format: "identifier == '\(identifier)'")
                                        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                                        if result.count > 0{
                                            let accounttype: Accounttypes = result.lastObject as! Accounttypes
                                            if let id: NSNumber = dict.objectForKey("id") as? NSNumber{
                                                accounttype.id = id
                                            }
                                            if let id: NSString = dict.objectForKey("id") as? NSString{
                                                accounttype.id = id.integerValue
                                            }
                                            if let type: NSNumber = dict.objectForKey("type") as? NSNumber{
                                                accounttype.type = type
                                            }
                                            if let type: NSString = dict.objectForKey("type") as? NSString{
                                                accounttype.type = type.integerValue
                                            }
                                            if let user_id: NSNumber = dict.objectForKey("user_id") as? NSNumber{
                                                accounttype.user_id = user_id
                                            }
                                            if let user_id: NSString = dict.objectForKey("user_id") as? NSString{
                                                accounttype.user_id = user_id.integerValue
                                            }
                                            accounttype.name = dict.objectForKey("name") as! NSString as String
                                            accounttype.modified = DVDateFormatter.getDate(dict.objectForKey("modified") as! NSString as String, format: nil)
                                            accounttype.created = DVDateFormatter.getDate(dict.objectForKey("created") as! NSString as String, format: nil)
                                            accounttype.synced = true
                                            var error: NSError?
                                            moc.save(&error)
                                            if error == nil{
                                                println("updated identifier: \(identifier)")
                                            }else{
                                                println(error!.localizedDescription)
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    DVSync.fetchServerAccounttypeData()
                }else if error != nil{
                    DVSync.fetchServerAccounttypeData()
                    println("post error")
                    println(error!.localizedDescription)
                }else{
                    DVSync.fetchServerAccounttypeData()
                }
            }
        })
    }
    
    class func fetchServerAccounttypeData(){
        if _lastAccounttypeModified != nil{
            println("_lastAccounttypeModified: \(_lastAccounttypeModified)")
            let postData: NSDictionary = ["Accounttype": ["modified": _lastAccounttypeModified!]]
            //println(postData)
            DataManager.postDataAsyncWithCallback("accounttypes/lastupdate", data: postData, json: true, completion: { (data, error) -> Void in
                if error == nil && data != nil{
                    if let response: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary{
                        if response.objectForKey("success") as? Bool == true{
                            if let savedData: NSArray = response.objectForKey("data") as? NSArray{
                                //println(savedData);
                                if savedData.count > 0{
                                    var reverseArray: NSMutableArray = NSMutableArray(array: savedData)
                                    let json: NSArray = reverseArray.reverseObjectEnumerator().allObjects
                                    let count: Int = json.count
                                    var added: Int = 0
                                    var last_synced: NSString?
                                    for item in json{
                                        //println("here")
                                        let dict: NSDictionary = item as! NSDictionary
                                        var ID: NSNumber!
                                        if let id: NSNumber = dict.objectForKey("id") as? NSNumber{
                                            ID = id
                                        }
                                        if let id: NSString = dict.objectForKey("id") as? NSString{
                                            ID = id.integerValue
                                        }
                                        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                                        let predicate: NSPredicate = NSPredicate(format: "id == \(ID)")
                                        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                                        if result.count > 0{
                                            let accounttype: Accounttypes = result.lastObject as! Accounttypes
                                            accounttype.id = ID
                                            if let type: NSNumber = dict.objectForKey("type") as? NSNumber{
                                                accounttype.type = type
                                            }
                                            if let type: NSString = dict.objectForKey("type") as? NSString{
                                                accounttype.type = type.integerValue
                                            }
                                            if let user_id: NSNumber = dict.objectForKey("user_id") as? NSNumber{
                                                accounttype.user_id = user_id
                                            }
                                            if let user_id: NSString = dict.objectForKey("user_id") as? NSString{
                                                accounttype.user_id = user_id.integerValue
                                            }
                                            accounttype.name = dict.objectForKey("name") as! NSString as String
                                            accounttype.modified = DVDateFormatter.getDate(dict.objectForKey("modified") as! NSString as String, format: nil)
                                            accounttype.created = DVDateFormatter.getDate(dict.objectForKey("created") as! NSString as String, format: nil)
                                            accounttype.synced = true
                                            if let isdeleted: Bool = dict.objectForKey("isdeleted") as? Bool{
                                                accounttype.isdeleted = isdeleted
                                            }
                                            var error: NSError?
                                            moc.save(&error)
                                            if error == nil{
                                                added++
                                                last_synced = DVDateFormatter.getTimeString(accounttype.modified, format: nil)
                                                println("updated ID: \(ID)")
                                            }else{
                                                println(error!.localizedDescription)
                                            }
                                        }else{
                                            if let accounttype: Accounttypes = CoreDataHelper.insertManagedObject(NSStringFromClass(Accounttypes), managedObjectContext: moc) as? Accounttypes{
                                                accounttype.identifier = DVDateFormatter.currentTimestamp
                                                if let id: NSNumber = dict.objectForKey("id") as? NSNumber{
                                                    accounttype.id = id
                                                }
                                                if let id: NSString = dict.objectForKey("id") as? NSString{
                                                    accounttype.id = id.integerValue
                                                }
                                                if let type: NSNumber = dict.objectForKey("type") as? NSNumber{
                                                    accounttype.type = type
                                                }
                                                if let type: NSString = dict.objectForKey("type") as? NSString{
                                                    accounttype.type = type.integerValue
                                                }
                                                if let user_id: NSNumber = dict.objectForKey("user_id") as? NSNumber{
                                                    accounttype.user_id = user_id
                                                }
                                                if let user_id: NSString = dict.objectForKey("user_id") as? NSString{
                                                    accounttype.user_id = user_id.integerValue
                                                }
                                                accounttype.name = dict.objectForKey("name") as! NSString as String
                                                accounttype.modified = DVDateFormatter.getDate(dict.objectForKey("modified") as! NSString as String, format: nil)
                                                accounttype.created = DVDateFormatter.getDate(dict.objectForKey("created") as! NSString as String, format: nil)
                                                accounttype.synced = true
                                                if let isdeleted: Bool = dict.objectForKey("isdeleted") as? Bool{
                                                    accounttype.isdeleted = isdeleted
                                                }
                                                accounttype.url = ""
                                                let success: Bool = CoreDataHelper.saveManagedObjectContext(moc)
                                                if success == false{
                                                    println("failed to save accounttype.id: \(accounttype.id)")
                                                }else{
                                                    added++
                                                    last_synced = DVDateFormatter.getTimeString(accounttype.modified, format: nil)
                                                    println("saved identifier: \(accounttype.identifier), name: \(accounttype.name)")
                                                }
                                            }
                                        }
                                    }
                                    println("count: \(count), added: \(added)")
                                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                    if last_synced != nil{
                                        prefs.setObject(last_synced, forKey: "last_synced")
                                    }else{
                                        prefs.setObject(DVDateFormatter.currentTimeString, forKey: "last_synced")
                                    }
                                    prefs.synchronize()
                                }
                            }
                        }
                    }
                }else if error != nil{
                    println("post error")
                    println(error!.localizedDescription)
                }
            })
        }
        _lastAccounttypeModified = nil
        _isSyncAccountTypes = false
    }
    
    // MARK: - synchonizeAccounts
    class func synchronizeAccounts(){
        //println(NSTimeZone.knownTimeZoneNames())
        //println("currentTimeString: \(DVDateFormatter.currentTimeString)")
        //return
        //println("here")
        //_isSyncAccounts = true
        
        if DataManager.isConnectedToNetwork() == true && _isSyncAccounts == false{
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let last_synced: NSString = prefs.objectForKey("last_accountsynced") as? NSString{
                _lastAccountModified = last_synced
                println("_lastAccountModified: \(_lastAccountModified)")
            }else{
                let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                let predicate: NSPredicate = NSPredicate(format: "synced == YES")
                let sorter: NSSortDescriptor = NSSortDescriptor(key: "modified", ascending: false)
                let results: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: [sorter], managedObjectContext: moc, limit: 1)
                if results.count > 0{
                    let account: Accounts = results.lastObject as! Accounts
                    _lastAccountModified = DVDateFormatter.getTimeString(account.modified, format: nil)
                    println("_lastAccountModified: \(_lastAccountModified)")
                }else{
                    _lastAccountModified = "0"
                    println("_lastAccountModified: \(_lastAccountModified)")
                }
            }
            //println("here1")
            DVSync.postLocalAccounts()
        }
    }
    
    // MARK: - postLocalData
    class func postLocalAccounts(){
        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
        let predicate: NSPredicate = NSPredicate(format: "synced == NO")
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
        let results: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: [sorter], managedObjectContext: moc, limit: nil)
        
        var postData: NSMutableArray = NSMutableArray()
        if results.count > 0{
            _isSyncAccounts = true
            for (index, item) in enumerate(results){
                let account: Accounts = item as! Accounts
                //println(account.synced)
                //continue
                if account.id > 0{
                    let dict: NSDictionary = [
                        "accounttype_id": account.accounttype_id,
                        "amount": account.amount,
                        "description": account.details,
                        "identifier": account.identifier,
                        "modified": DVDateFormatter.getTimeString(account.modified, format: nil),
                        "created": DVDateFormatter.getTimeString(account.created, format: nil),
                        "user_id": account.user_id,
                        "id" : account.id,
                        "isdeleted": account.isdeleted
                    ]
                    postData.addObject(dict)
                }else{
                    let dict: NSDictionary = [
                        "accounttype_id": account.accounttype_id,
                        "amount": account.amount,
                        "description": account.details,
                        "identifier": account.identifier,
                        "modified": DVDateFormatter.getTimeString(account.modified, format: nil),
                        "created": DVDateFormatter.getTimeString(account.created, format: nil),
                        "user_id": account.user_id,
                        "id" : "",
                        "isdeleted": account.isdeleted
                    ]
                    postData.addObject(dict)
                }
            }
            DVSync.accountPostSync(["Account": ["data": postData]])
        }else{
            DVSync.fetchServerAccountData()
        }
    }
    
    // MARK: - accountPostSync
    class func accountPostSync(postdata: NSDictionary){
        println("accountPostSync")
        println(postdata)
        DataManager.postDataAsyncWithCallback("accounts/sync", data: postdata, json: true, completion: { (data, error) -> Void in
            dispatch_async(dispatch_get_main_queue()){
                println("accounts/sync")
                //println(data)
                if error == nil && data != nil{
                    println(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    if let response: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary{
                        if response.objectForKey("success") as? Bool == true{
                            if let savedData: NSArray = response.objectForKey("data") as? NSArray{
                                if savedData.count > 0{
                                    for item in savedData{
                                        //println("here")
                                        let dict: NSDictionary = item as! NSDictionary
                                        let identifier: NSString = dict.objectForKey("identifier") as! NSString
                                        println("identifier: \(identifier)")
                                        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                                        let predicate: NSPredicate = NSPredicate(format: "identifier == '\(identifier)'")
                                        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                                        if result.count > 0{
                                            let account: Accounts = result.lastObject as! Accounts
                                            if let id: NSNumber = dict.objectForKey("id") as? NSNumber{
                                                account.id = id
                                            }
                                            if let id: NSString = dict.objectForKey("id") as? NSString{
                                                account.id = id.integerValue
                                            }
                                            if let amount: NSDecimalNumber = dict.objectForKey("amount") as? NSDecimalNumber{
                                                account.amount = amount
                                            }
                                            if let amount: NSString = dict.objectForKey("amount") as? NSString{
                                                account.amount = NSDecimalNumber(string: amount as String)
                                            }
                                            if let user_id: NSNumber = dict.objectForKey("user_id") as? NSNumber{
                                                account.user_id = user_id
                                            }
                                            if let user_id: NSString = dict.objectForKey("user_id") as? NSString{
                                                account.user_id = user_id.integerValue
                                            }
                                            if let accounttype_id: NSNumber = dict.objectForKey("accounttype_id") as? NSNumber{
                                                account.accounttype_id = accounttype_id
                                            }
                                            if let accounttype_id: NSString = dict.objectForKey("accounttype_id") as? NSString{
                                                account.accounttype_id = accounttype_id.integerValue
                                            }
                                            account.details = dict.objectForKey("description") as! NSString as String
                                            account.modified = DVDateFormatter.getDate(dict.objectForKey("modified") as! NSString as String, format: nil)
                                            account.created = DVDateFormatter.getDate(dict.objectForKey("created") as! NSString as String, format: nil)
                                            account.synced = true
                                            if let isdeleted: Bool = dict.objectForKey("isdeleted") as? Bool{
                                                account.isdeleted = isdeleted
                                            }
                                            account.url = ""
                                            
                                            var error: NSError?
                                            moc.save(&error)
                                            if error == nil{
                                                println("updated identifier: \(identifier)")
                                            }else{
                                                println(error!.localizedDescription)
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    DVSync.fetchServerAccountData()
                }else if error != nil{
                    DVSync.fetchServerAccountData()
                    println("accounts/sync post error")
                    println(error!.localizedDescription)
                }else{
                    DVSync.fetchServerAccountData()
                }
            }
        })
    }
    
    // MARK: - fetchServerAccountData
    class func fetchServerAccountData(){
        println("fetchServerAccountData")
        if _lastAccountModified != nil && _lastAccountModified != "0"{
            println("_lastAccountModified: \(_lastAccountModified)")
            let postData: NSDictionary = ["Account": ["modified": _lastAccountModified!]]
            println(postData)
            DataManager.postDataAsyncWithCallback("accounts/lastupdate", data: postData, json: true, completion: { (data, error) -> Void in
                if error == nil && data != nil{
                    if let response: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary{
                        if response.objectForKey("success") as? Bool == true{
                            if let savedData: NSArray = response.objectForKey("data") as? NSArray{
                                println(savedData);
                                if savedData.count > 0{
                                    var reverseArray: NSMutableArray = NSMutableArray(array: savedData)
                                    let json: NSArray = reverseArray.reverseObjectEnumerator().allObjects
                                    let count: Int = json.count
                                    var added: Int = 0
                                    var last_synced: NSString?
                                    for item in json{
                                        //println("here")
                                        let dict: NSDictionary = item as! NSDictionary
                                        var ID: NSNumber!
                                        if let id: NSNumber = dict.objectForKey("id") as? NSNumber{
                                            ID = id
                                        }
                                        if let id: NSString = dict.objectForKey("id") as? NSString{
                                            ID = id.integerValue
                                        }
                                        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                                        let predicate: NSPredicate = NSPredicate(format: "id == \(ID)")
                                        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                                        if result.count > 0{
                                            let account: Accounts = result.lastObject as! Accounts
                                            account.id = ID
                                            if let amount: NSDecimalNumber = dict.objectForKey("amount") as? NSDecimalNumber{
                                                account.amount = amount
                                            }
                                            if let amount: NSString = dict.objectForKey("amount") as? NSString{
                                                account.amount = NSDecimalNumber(string: amount as String)
                                            }
                                            if let user_id: NSNumber = dict.objectForKey("user_id") as? NSNumber{
                                                account.user_id = user_id
                                            }
                                            if let user_id: NSString = dict.objectForKey("user_id") as? NSString{
                                                account.user_id = user_id.integerValue
                                            }
                                            if let accounttype_id: NSNumber = dict.objectForKey("accounttype_id") as? NSNumber{
                                                account.accounttype_id = accounttype_id
                                            }
                                            if let accounttype_id: NSString = dict.objectForKey("accounttype_id") as? NSString{
                                                account.accounttype_id = accounttype_id.integerValue
                                            }
                                            
                                            // accounttype for account
                                            let predicate: NSPredicate = NSPredicate(format: "id == \(account.accounttype_id)")
                                            let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                                            if result.count > 0{
                                                let accounttype: Accounttypes = result.lastObject as! Accounttypes
                                                account.accounttype = accounttype
                                            }
                                            //end
                                            
                                            account.details = dict.objectForKey("description") as! NSString as String
                                            account.modified = DVDateFormatter.getDate(dict.objectForKey("modified") as! NSString as String, format: nil)
                                            account.created = DVDateFormatter.getDate(dict.objectForKey("created") as! NSString as String, format: nil)
                                            account.synced = true
                                            if let isdeleted: Bool = dict.objectForKey("isdeleted") as? Bool{
                                                account.isdeleted = isdeleted
                                            }
                                            var error: NSError?
                                            moc.save(&error)
                                            if error == nil{
                                                added++
                                                last_synced = DVDateFormatter.getTimeString(account.modified, format: nil)
                                                println("updated ID: \(ID)")
                                            }else{
                                                println(error!.localizedDescription)
                                            }
                                        }else{
                                            if let account: Accounts = CoreDataHelper.insertManagedObject(NSStringFromClass(Accounts), managedObjectContext: moc) as? Accounts{
                                                account.identifier = DVDateFormatter.currentTimestamp
                                                if let id: NSNumber = dict.objectForKey("id") as? NSNumber{
                                                    account.id = id
                                                }
                                                if let id: NSString = dict.objectForKey("id") as? NSString{
                                                    account.id = id.integerValue
                                                }
                                                if let amount: NSDecimalNumber = dict.objectForKey("amount") as? NSDecimalNumber{
                                                    account.amount = amount
                                                }
                                                if let amount: NSString = dict.objectForKey("amount") as? NSString{
                                                    account.amount = NSDecimalNumber(string: amount as String)
                                                }
                                                if let user_id: NSNumber = dict.objectForKey("user_id") as? NSNumber{
                                                    account.user_id = user_id
                                                }
                                                if let user_id: NSString = dict.objectForKey("user_id") as? NSString{
                                                    account.user_id = user_id.integerValue
                                                }
                                                
                                                if let accounttype_id: NSNumber = dict.objectForKey("accounttype_id") as? NSNumber{
                                                    account.accounttype_id = accounttype_id
                                                }
                                                if let accounttype_id: NSString = dict.objectForKey("accounttype_id") as? NSString{
                                                    account.accounttype_id = accounttype_id.integerValue
                                                }
                                                
                                                // accounttype for account
                                                let predicate: NSPredicate = NSPredicate(format: "id == \(account.accounttype_id)")
                                                let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                                                if result.count > 0{
                                                    let accounttype: Accounttypes = result.lastObject as! Accounttypes
                                                    account.accounttype = accounttype
                                                }
                                                //end
                                                
                                                account.details = dict.objectForKey("description") as! NSString as String
                                                account.modified = DVDateFormatter.getDate(dict.objectForKey("modified") as! NSString as String, format: nil)
                                                account.created = DVDateFormatter.getDate(dict.objectForKey("created") as! NSString as String, format: nil)
                                                account.synced = true
                                                
                                                if let isdeleted: Bool = dict.objectForKey("isdeleted") as? Bool{
                                                    account.isdeleted = isdeleted
                                                }
                                                
                                                account.url = ""
                                                let success: Bool = CoreDataHelper.saveManagedObjectContext(moc)
                                                if success == false{
                                                    println("failed to save accounttype.id: \(account.id)")
                                                }else{
                                                    added++
                                                    last_synced = DVDateFormatter.getTimeString(account.modified, format: nil)
                                                    println("saved identifier: \(account.identifier)")
                                                }
                                            }
                                        }
                                    }
                                    println("count: \(count), added: \(added)")
                                    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                    if last_synced != nil{
                                        prefs.setObject(last_synced, forKey: "last_accountsynced")
                                    }else{
                                        prefs.setObject(DVDateFormatter.currentTimeString, forKey: "last_accountsynced")
                                    }
                                    prefs.synchronize()
                                }
                            }
                        }
                    }
                }else if error != nil{
                    println(error!.code)
                    println("post error")
                    println(error!.localizedDescription)
                }
            })
        }else if _lastAccountModified != nil && _lastAccountModified == "0"{
            self.fetchServerAllAccountData()
        }else{
            _lastAccountModified = nil
            _isSyncAccounts = false
        }
    }
    
    // MARK: - fetchServerAllAccountData
    class func fetchServerAllAccountData(){
        println("_lastAccountModified: \(_lastAccountModified)")
        DataManager.loadDataAsyncWithCallback("accounts/list.json") { (data, error) -> Void in
            if error == nil && data != nil{
                if let savedData: NSArray = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as? NSArray{
                    if savedData.count > 0{
                        var reverseArray: NSMutableArray = NSMutableArray(array: savedData)
                        let json: NSArray = reverseArray.reverseObjectEnumerator().allObjects
                        let count: Int = json.count
                        var added: Int = 0
                        var last_synced: NSString?
                        for item in json{
                            //println("here")
                            let dict: NSDictionary = item as! NSDictionary
                            var ID: NSNumber!
                            if let id: NSNumber = dict.objectForKey("id") as? NSNumber{
                                ID = id
                            }
                            if let id: NSString = dict.objectForKey("id") as? NSString{
                                ID = id.integerValue
                            }
                            let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                            if let account: Accounts = CoreDataHelper.insertManagedObject(NSStringFromClass(Accounts), managedObjectContext: moc) as? Accounts{
                                account.identifier = DVDateFormatter.currentTimestamp
                                if let id: NSNumber = dict.objectForKey("id") as? NSNumber{
                                    account.id = id
                                }
                                if let id: NSString = dict.objectForKey("id") as? NSString{
                                    account.id = id.integerValue
                                }
                                if let amount: NSDecimalNumber = dict.objectForKey("amount") as? NSDecimalNumber{
                                    account.amount = amount
                                }
                                if let amount: NSString = dict.objectForKey("amount") as? NSString{
                                    account.amount = NSDecimalNumber(string: amount as String)
                                }
                                if let user_id: NSNumber = dict.objectForKey("user_id") as? NSNumber{
                                    account.user_id = user_id
                                }
                                if let user_id: NSString = dict.objectForKey("user_id") as? NSString{
                                    account.user_id = user_id.integerValue
                                }
                                
                                if let accounttype_id: NSNumber = dict.objectForKey("accounttype_id") as? NSNumber{
                                    account.accounttype_id = accounttype_id
                                }
                                if let accounttype_id: NSString = dict.objectForKey("accounttype_id") as? NSString{
                                    account.accounttype_id = accounttype_id.integerValue
                                }
                                
                                // accounttype for account
                                let predicate: NSPredicate = NSPredicate(format: "id == \(account.accounttype_id)")
                                let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                                if result.count > 0{
                                    let accounttype: Accounttypes = result.lastObject as! Accounttypes
                                    account.accounttype = accounttype
                                }
                                //end
                                
                                account.details = dict.objectForKey("description") as! NSString as String
                                account.modified = DVDateFormatter.getDate(dict.objectForKey("modified") as! NSString as String, format: nil)
                                account.created = DVDateFormatter.getDate(dict.objectForKey("created") as! NSString as String, format: nil)
                                account.synced = true
                                
                                if let isdeleted: Bool = dict.objectForKey("isdeleted") as? Bool{
                                    account.isdeleted = isdeleted
                                }
                                
                                account.url = ""
                                let success: Bool = CoreDataHelper.saveManagedObjectContext(moc)
                                if success == false{
                                    println("failed to save accounttype.id: \(account.id)")
                                }else{
                                    added++
                                    last_synced = DVDateFormatter.getTimeString(account.modified, format: nil)
                                    println("saved identifier: \(account.identifier)")
                                }
                            }
                        }
                        println("count: \(count), added: \(added)")
                        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        if last_synced != nil{
                            prefs.setObject(last_synced, forKey: "last_accountsynced")
                        }else{
                            prefs.setObject(DVDateFormatter.currentTimeString, forKey: "last_accountsynced")
                        }
                        prefs.synchronize()
                    }
                }
            }else if error != nil{
                println("post error")
                println(error!.localizedDescription)
            }
        }

        _lastAccountModified = nil
        _isSyncAccounts = false
    }
   
}
