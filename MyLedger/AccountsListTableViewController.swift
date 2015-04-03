//
//  AccountsListTableViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 3/29/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

class AccountsListTableViewController: UITableViewController {
    
    var tableData: NSMutableArray = NSMutableArray()
    var dataToSynch: NSMutableArray = NSMutableArray()
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Accounts List"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadLocalData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return tableData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        
        if let data = self.tableData.objectAtIndex(indexPath.row) as? NSDictionary{
            cell.textLabel?.text = data["details"] as? String
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let nextVC: AccountAddViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AccountAddViewController") as AccountAddViewController
        
        if let cellData = self.tableData.objectAtIndex(indexPath.row) as? NSDictionary{
            nextVC.isEdit = true
            nextVC.acTypeID = (cellData.objectForKey("id") as NSString).integerValue
            nextVC.identifier = cellData.objectForKey("identifier") as NSString
            nextVC.tableData = [["title": "Type", "type": "picker", "value": (cellData.objectForKey("accounttype_id") as NSString).integerValue],["title": "Description", "type": "textview", "value": cellData.objectForKey("details") as NSString],["title": "Amount", "type": "input", "value": cellData.objectForKey("amount") as NSString]]
            //nextVC.tableData = [["title": "Name", "type": "input", "placeHolder": "Name", "value": cellData.objectForKey("name") as NSString],["title": "Type", "type": "picker", "value": (cellData.objectForKey("type") as NSString).integerValue]]
        }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            AlertManager.showAlert(self, title: "Warning!", message: "Do you want to delete?", buttonNames: ["Yes", "Cancel"], completion: { (index) -> Void in
                if index == 0{
                    self.deleteRowAt(indexPath)
                }
            })
        }
    }
    
    func deleteRowAt(indexPath: NSIndexPath){
        let dict: NSDictionary = tableData.objectAtIndex(indexPath.row) as NSDictionary
        let ID: NSString = dict.objectForKey("id") as NSString
        let identifier: NSString = dict.objectForKey("identifier") as NSString
        // calculate view's center for activity indicator
        var centerOfView: CGPoint = self.view.center
        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait{
            centerOfView.y = centerOfView.y - 57/2
        }
        else{
            centerOfView.y = centerOfView.y - 41.5/2
        }
        //println(UIApplication.sharedApplication().statusBarOrientation.rawValue)
        // activity indicator
        var activityIndicator = UICustomActivityView()
        activityIndicator.showActivityIndicator(self.view, style: UIActivityIndicatorViewStyle.Gray, shouldHaveContainer: false, centerPoint: centerOfView)
        let postdata: NSDictionary = ["Account": ["ajax": true]]
        println("accounts/delete/\(ID)")
        DataManager.postDataAsyncWithCallback("accounts/delete/\(ID)", data: postdata, json: true) { (data, error) -> Void in
            dispatch_async(dispatch_get_main_queue()){
                let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                activityIndicator.hideActivityIndicator()
                //println(NSString(data: data!, encoding: NSUTF8StringEncoding))
                if error != nil{
                    if error!.code == -1004 || error!.code == -1009{
                        let predicate: NSPredicate = NSPredicate(format: "identifier == '\(identifier)'")!
                        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                        if result.count > 0{
                            let account: Accounts = result.lastObject as Accounts
                            account.isdeleted = true
                            account.modified = DVDateFormatter.currentTimeString
                            account.synced = false
                            var error: NSError?
                            moc.save(&error)
                            if error == nil{
                                self.tableData.removeObjectAtIndex(indexPath.row)
                                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                println("only updated coredata. sync required")
                            }else{
                                println(error!.localizedDescription)
                            }
                        }
                    }else{
                        AlertManager.showAlert(self, title: "Error", message: error!.localizedDescription, buttonNames: nil, completion: nil)
                    }
                }else if data != nil{
                    //println(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    //return
                    
                    if let response: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary{
                        if response.objectForKey("success") as? Bool == true{
                            if let savedData: NSDictionary = response.objectForKey("data") as? NSDictionary{
                                //println(identifier)
                                let predicate: NSPredicate = NSPredicate(format: "identifier == '\(identifier)'")!
                                let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                                if result.count > 0{
                                    //println("here")
                                    let account: Accounts = result.lastObject as Accounts
                                    account.isdeleted = true
                                    account.modified = savedData.objectForKey("modified") as String
                                    account.synced = true
                                    var error: NSError?
                                    moc.save(&error)
                                    if error == nil{
                                        self.tableData.removeObjectAtIndex(indexPath.row)
                                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                        println("posted and updated coredata")
                                    }else{
                                        println(error!.localizedDescription)
                                    }
                                }else{
                                    //println("here2")
                                }
                            }
                        }else{
                            AlertManager.showAlert(self, title: "Error", message: "There was an error. Please try again.", buttonNames: nil, completion: nil)
                        }
                    }
                }
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Load Account Types List from server
    
    func loadDataFromServer(){
        // calculate view's center for activity indicator
        var centerOfView: CGPoint = self.view.center
        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait{
            centerOfView.y = centerOfView.y - 57/2
        }
        else{
            centerOfView.y = centerOfView.y - 41.5/2
        }
        //println(UIApplication.sharedApplication().statusBarOrientation.rawValue)
        // activity indicator
        var activityIndicator = UICustomActivityView()
        activityIndicator.showActivityIndicator(self.view, style: UIActivityIndicatorViewStyle.Gray, shouldHaveContainer: false, centerPoint: centerOfView)
        
        DataManager.loadDataAsyncWithCallback("accounts/list.json", completion: { (data, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                activityIndicator.hideActivityIndicator()
                if error == nil && data != nil{
                    var err: NSError? = nil
                    var json: NSArray? = NSJSONSerialization.JSONObjectWithData(data!,options: NSJSONReadingOptions.AllowFragments,error:&err) as? NSArray
                    if err == nil{
                        if json != nil && json!.count > 0{
                            self.tableData.removeAllObjects()
                            //self.tableData = json!
                            //self.tableView.reloadData()
                            let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
                            var error: NSError?
                            //let userID: NSNumber = self.prefs.objectForKey("userID") as NSNumber
                            //reverse json array
                            var reverseArray: NSMutableArray = NSMutableArray(array: json!)
                            json = reverseArray.reverseObjectEnumerator().allObjects
                            let count: Int = json!.count
                            var added: Int = 0
                            for (index, item) in enumerate(json!){
                                //self.tableData.addObject(item)
                                if let dict: NSDictionary = item as? NSDictionary{
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
                                            account.amount = NSDecimalNumber(string: amount)
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
                                        
                                        account.details = dict.objectForKey("description") as NSString
                                        account.modified = dict.objectForKey("modified") as NSString
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
                                            println("saved identifier: \(account.identifier)")
                                        }
                                    }
                                }
                            }
                            println("count: \(count), added: \(added)")
                            println("load server done")
                            self.loadLocalData()
                        }
                    }
                }
            })
        })
    }
    
    // MARK: - loadLocalData
    func loadLocalData(){
        let userID: NSNumber = (prefs.objectForKey("userID") as NSString).integerValue
        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
        let predicate: NSPredicate = NSPredicate(format: "user_id == '\(userID)' AND isdeleted = NO")!
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "identifier", ascending: false)
        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: [sorter], managedObjectContext: moc, limit: nil)
        if result.count > 0{
            println("load from coredata. count: \(result.count)")
            var dict: NSMutableDictionary = NSMutableDictionary()
            tableData.removeAllObjects()
            for (index, item) in enumerate(result){
                if let account: Accounts = item as? Accounts{
                    dict = NSMutableDictionary()
                    dict.setObject(account.identifier, forKey: "identifier")
                    dict.setObject(account.id.stringValue, forKey: "id")
                    dict.setObject(account.user_id.stringValue, forKey: "user_id")
                    dict.setObject(account.accounttype_id.stringValue, forKey: "accounttype_id")
                    dict.setObject(account.details, forKey: "details")
                    dict.setObject(account.amount.stringValue, forKey: "amount")
                    dict.setObject(account.modified, forKey: "modified")
                    //println(accounttype.modified)
                    dict.setObject(account.synced, forKey: "synced")
                    dict.setObject(account.url, forKey: "url")
                    tableData.addObject(dict)
                    
                    //if accounttype.id >
                }
            }
            tableView.reloadData()
        }else{
            println("load from server")
            //self.loadDataFromServer()
        }
        
    }
    
    // MARK: - synchronizeWithServer
    func synchronizeWithServer(){
        
    }
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
