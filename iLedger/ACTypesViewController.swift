//
//  ACTypesViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 12/1/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

class ACTypesViewController: UINavigationController {
    
    var moc: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        moc = CoreDataHelper.managedObjectContext(dataBaseFilename: "MyLedger")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("persistentStoreDidChange"), name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("persistentStoreWillChange:"), name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("retrieveICloudChanges:"), name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
    }
    
    func persistentStoreDidChange(){
        //reenable UI and fetch data
        self.navigationItem.title = "iCloudReady"
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        //loadData()
    }
    
    func persistentStoreWillChange(notification: NSNotification){
        moc.performBlock { () -> Void in
            if self.moc.hasChanges{
                var error: NSError? = nil
                self.moc.save(&error)
                if error != nil{
                    println("Save error: \(error)")
                }else{
                    //drop any managed object references
                    self.moc.reset()
                }
            }
        }
    }
    
    func retrieveICloudChanges(notification: NSNotification){
        moc.performBlock { () -> Void in
            self.moc.mergeChangesFromContextDidSaveNotification(notification)
            //self.loadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StatusBar Style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.viewControllers.last!.preferredStatusBarStyle()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
