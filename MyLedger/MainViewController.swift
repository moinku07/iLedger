//
//  MainViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 12/1/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITabBarController, SideBarDelegate {
    
    var sideBar: SideBar!
    
    let menuItems: NSMutableArray = [["title": "Logout", "icon": "icon-nav-logout"]]
    
    var isSyncAccountTypes: Bool = false
    var accounttypesSyncTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 250 * 1000000), dispatch_get_main_queue()){
            self.sideBar = SideBar(sourceView: self.view.window!, menuItems: self.menuItems)
            self.sideBar.delegate = self
            self.sideBar.shouldDeselectSelectedRow = true
            //self.sideBar.menuItems = self.menuItems
        }
        
        self.synchronizeAccountTypes()
        accounttypesSyncTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("synchronizeAccountTypes"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sideBarDidSelectRowAtIndex(index: Int, dict: NSDictionary) {
        if index == 0{
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.setObject(nil, forKey: "username")
            prefs.setObject(nil, forKey: "password")
            prefs.synchronize()
            self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        sideBar.showSideBar(false)
        sideBar.removeFromSuperview()
    }
    
    // MARK: - synchonizeAccountTypes
    func synchronizeAccountTypes(){
        //println(NSTimeZone.knownTimeZoneNames())
        //println("currentTimeString: \(DVDateFormatter.currentTimeString)")
        //return
        //println("here")
        if DataManager.isConnectedToNetwork() == true && isSyncAccountTypes == false{
            let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
            let predicate: NSPredicate = NSPredicate(format: "synced == 'NO'")!
            let sorter: NSSortDescriptor = NSSortDescriptor(key: "identifier", ascending: true)
            let results: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: [sorter], managedObjectContext: moc, limit: nil)
            if results.count > 0{
                isSyncAccountTypes = true
                for (index, item) in enumerate(results){
                    let accounttype: Accounttypes = item as Accounttypes
                    let actypeid: String = accounttype.id > 0 ? "\(accounttype.id)" : ""
                    let postData: NSDictionary = [
                        "Accounttype": [
                            "name": accounttype.name,
                            "type": accounttype.type,
                            "user_id": accounttype.user_id,
                            "ajax" : true,
                            "id" : actypeid
                        ]
                    ]
                    self.accounttypePostSync(accounttype.identifier, url: accounttype.url, postdata: postData)
                }
                isSyncAccountTypes = false
            }
        }
    }
    
    // MARK: - accounttypePostSync
    func accounttypePostSync(identifier: NSString, url: String, postdata: NSDictionary){
        println(postdata)
        println(url)
        DataManager.postDataAsyncWithCallback(url, data: postdata, json: true, completion: { (data, error) -> Void in
            dispatch_async(dispatch_get_main_queue()){
                if error == nil && data != nil{
                    if let response: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary{
                        if response.objectForKey("success") as? Bool == true{
                            if let savedData: NSDictionary = response.objectForKey("data") as? NSDictionary{
                                let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                                let predicate: NSPredicate = NSPredicate(format: "identifier == '\(identifier)'")!
                                let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                                if result.count > 0{
                                    let accounttype: Accounttypes = result.lastObject as Accounttypes
                                    accounttype.id = (savedData.objectForKey("id") as NSString).integerValue
                                    accounttype.modified = savedData.objectForKey("modified") as String
                                    accounttype.url = ""
                                    accounttype.synced = true
                                    var error: NSError?
                                    moc.save(&error)
                                    if error == nil{
                                        println("coredata synchonized")
                                    }else{
                                        println(error!.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                }else if error != nil{
                    println("post error")
                    println(error!.localizedDescription)
                }
            }
        })
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
