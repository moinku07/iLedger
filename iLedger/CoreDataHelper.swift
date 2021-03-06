//
//  CoreDataHelper.swift
//  CoreDataPractice
//
//  Created by Moin Uddin on 10/30/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    class func dataBaseFilename(name: String? = nil) ->NSString{
        if name != nil{
            return "\(name!).sqlite";
        }
        return "database.sqlite";
    }
    
    class func managedObjectContext(dataBaseFilename: String? = nil) -> NSManagedObjectContext{
        var error: NSError? = nil;
        
        let urls: NSArray = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        var url: NSURL = urls.lastObject as! NSURL
        url = url.URLByAppendingPathComponent(CoreDataHelper.dataBaseFilename(name: dataBaseFilename) as String)
        //println(url)
        
        let managedModel: NSManagedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)!;
        //println(managedModel)
        
        var storeCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedModel);
        
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
            NSPersistentStoreUbiquitousContentNameKey: "MyLedgerStore"
        ]
        if let success = storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: mOptions, error: &error){
            if (error != nil){
                println("Error: \(error?.localizedDescription)");
                abort();
            }
        }
        
        var managedObjectContext: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType);
        managedObjectContext.persistentStoreCoordinator = storeCoordinator;
        
        //println(managedObjectContext)
        
        return managedObjectContext;
    }
    
    class func insertManagedObject(className: NSString, managedObjectContext: NSManagedObjectContext) -> AnyObject{
        let managedObject: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(className as String, inManagedObjectContext: managedObjectContext) as! NSManagedObject;
        return managedObject;
    }
    
    class func saveManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> Bool{
        var error: NSError? = nil;
        if !managedObjectContext.save(&error){
            println("Save Error: \(error?.localizedDescription)")
            return false;
        }else{
            return true;
        }
    }
    
    class func fetchEntities(className: NSString, withPredicate predicate: NSPredicate?, andSorter sorter: NSArray?, managedObjectContext: NSManagedObjectContext, limit: Int? = nil, expressions: NSArray? = nil) -> NSArray{
        let fetchRequest: NSFetchRequest = NSFetchRequest();
        if limit != nil{
            fetchRequest.fetchLimit = limit!
        }
        let entityDescription: NSEntityDescription = NSEntityDescription.entityForName(className as String, inManagedObjectContext: managedObjectContext)!;
        fetchRequest.entity = entityDescription;
        
        if (predicate != nil){
            fetchRequest.predicate = predicate!
        }
        if sorter != nil{
            fetchRequest.sortDescriptors = sorter! as [AnyObject]
        }
        
        if expressions != nil{
            fetchRequest.propertiesToFetch = expressions! as [AnyObject]
            fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        }
        
        fetchRequest.returnsObjectsAsFaults = false;
        var error: NSError? = nil;
        if let items: NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: &error){
            return items;
        }
        if error != nil{
            println("Fetch Error: \(error?.localizedDescription)");
            return [];
        }
        return []
    }
    
    class func fetchEntitiesByGroup(className: NSString, managedObjectContext: NSManagedObjectContext, predicate: NSPredicate?, sorter: NSArray? = nil, groupBy: NSArray? = nil) -> NSArray{
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        let entityDescription: NSEntityDescription = NSEntityDescription.entityForName(className as String, inManagedObjectContext: managedObjectContext)!
        
        fetchRequest.entity = entityDescription
        
        if predicate != nil{
            fetchRequest.predicate = predicate!
        }
        
        if sorter != nil{
            fetchRequest.sortDescriptors = sorter! as [AnyObject]
        }
        
        if groupBy != nil{
            fetchRequest.propertiesToGroupBy = groupBy! as [AnyObject]
            fetchRequest.resultType = .DictionaryResultType
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        
        var error: NSError?
        
        let items: NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)!
        
        return items
    }
   
}
