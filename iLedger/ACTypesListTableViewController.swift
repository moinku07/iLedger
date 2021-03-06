//
//  ACTypesListTableViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 12/2/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

class ACTypesListTableViewController: UITableViewController {
    
    var tableData: NSMutableArray = NSMutableArray()
    var dataToSynch: NSMutableArray = NSMutableArray()
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Account Types List"
        
        //self.loadDataFromServer()
        //self.loadLocalData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        moc = CoreDataHelper.managedObjectContext(dataBaseFilename: "MyLedger")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("persistentStoreDidChange"), name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("persistentStoreWillChange:"), name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("retrieveICloudChanges:"), name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
        
        loadLocalData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
    }
    
    func persistentStoreDidChange(){
        println("persistentStoreDidChange")
        loadLocalData()
    }
    
    func persistentStoreWillChange(notification: NSNotification){
        println("persistentStoreWillChange")
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
        println("retrieveICloudChanges")
        moc.performBlock { () -> Void in
            self.moc.mergeChangesFromContextDidSaveNotification(notification)
            self.loadLocalData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        
        if let data = self.tableData.objectAtIndex(indexPath.row) as? NSDictionary{
            cell.textLabel?.text = data["name"] as? String
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let nextVC: ACTypeAddViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ACTypeAddViewController") as! ACTypeAddViewController
        
        if let cellData = self.tableData.objectAtIndex(indexPath.row) as? NSDictionary{
            nextVC.isEdit = true
            //nextVC.acTypeID = (cellData.objectForKey("id") as! NSString).integerValue
            nextVC.identifier = cellData.objectForKey("identifier") as! NSString as String
            nextVC.tableData = [["title": "Name", "type": "input", "placeHolder": "Name", "value": cellData.objectForKey("name") as! NSString],["title": "Type", "type": "picker", "value": (cellData.objectForKey("type") as! NSString).integerValue]]
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
        let dict: NSDictionary = tableData.objectAtIndex(indexPath.row) as! NSDictionary
        let identifier: NSString = dict.objectForKey("identifier") as! NSString
        // calculate view's center for activity indicator
        var centerOfView: CGPoint = self.view.center
        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait{
            centerOfView.y = centerOfView.y - 57/2
        }
        else{
            centerOfView.y = centerOfView.y - 41.5/2
        }
        //println(UIApplication.sharedApplication().statusBarOrientation.rawValue)
        
        let predicate: NSPredicate = NSPredicate(format: "identifier == '\(identifier)'")
        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
        if result.count > 0{
            let accounttype: Accounttypes = result.lastObject as! Accounttypes
            accounttype.isdeleted = true
            accounttype.modified = DVDateFormatter.currentDate
            //accounttype.synced = false
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
    
    
    // MARK: - loadLocalData
    func loadLocalData(){
        let predicate: NSPredicate = NSPredicate(format: "isdeleted = NO")
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "identifier", ascending: false)
        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: [sorter], managedObjectContext: moc, limit: nil)
        if result.count > 0{
            println("load from coredata. count: \(result.count)")
            var dict: NSMutableDictionary = NSMutableDictionary()
            tableData.removeAllObjects()
            for (index, item) in enumerate(result){
                if let accounttype: Accounttypes = item as? Accounttypes{
                    dict = NSMutableDictionary()
                    dict.setObject(accounttype.identifier, forKey: "identifier")
                    //dict.setObject(accounttype.id.stringValue, forKey: "id")
                    //dict.setObject(accounttype.user_id.stringValue, forKey: "user_id")
                    dict.setObject(accounttype.name, forKey: "name")
                    dict.setObject(accounttype.type.stringValue, forKey: "type")
                    dict.setObject(accounttype.modified, forKey: "modified")
                    //println(accounttype.modified)
                    //dict.setObject(accounttype.synced, forKey: "synced")
                    //dict.setObject(accounttype.url, forKey: "url")
                    tableData.addObject(dict)
                    
                    //if accounttype.id >
                }
            }
            tableView.reloadData()
        }
        
    }
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
