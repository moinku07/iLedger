//
//  ACTypeAddViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 12/1/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

class ACTypeAddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    var isEdit: Bool = false
    var acTypeID: Int?
    var identifier: String?
    @IBOutlet var tableView: UITableView!
    
    var nameTextField: UITextField?
    
    var tableData: NSMutableArray = [/*["title": "Other Cell1"], ["title": "Other Cell2"],*/["title": "Name", "type": "input", "placeHolder": "Name"],["title": "Type", "type": "picker"/*, "value": 2*/]/*,["title": "End Date", "type": "date", "date": NSDate()]*/]
    
    var dateFormatter: NSDateFormatter?
    var pickerCellRowHeight: CGFloat?
    
    let datePickerTag:Int = 99
    let pickerTag:Int = 98
    
    var datePickerIndexPath: NSIndexPath?
    
    // keep track of which rows have date cells
    var datePickerRows: NSMutableArray = NSMutableArray()
    var pickerRows: NSMutableArray = NSMutableArray()
    
    let pickerDataValues: NSArray = [1, 2]
    let pickerDataTitles: NSArray = ["Add", "Sub"]
    var selectedPickerValue: Int?
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add Account Type"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter?.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateFormatter?.timeStyle = NSDateFormatterStyle.NoStyle
        
        pickerCellRowHeight = 216.0
        //println("self.tableView.rowHeight: \(self.tableView.rowHeight)")
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
        println("persistentStoreDidChange")
        self.tableView.reloadData()
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
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView Datasource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.datePickerIndexPath != nil{
            // we have a date picker, so allow for it in the number of rows in this section
            var numRows: Int = tableData.count
            return ++numRows
        }
        return tableData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (self.indexPathHasPicker(indexPath) ? self.pickerCellRowHeight! : self.tableView.rowHeight)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var rowData: NSDictionary = NSDictionary()
        
        if indexPath.row < self.tableData.count{
            rowData = self.tableData.objectAtIndex(indexPath.row) as! NSDictionary
        }
        
        var cellID: NSString = "otherCell"
        if self.indexPathHasPicker(indexPath){
            let prevRowData: NSDictionary = self.tableData.objectAtIndex(indexPath.row - 1) as! NSDictionary
            if let type: String = prevRowData["type"] as? String{
                if type == "date"{
                    cellID = "datePicker"
                }else if type == "picker"{
                    cellID = "uiPicker"
                }
            }
        }else if let type: String = rowData["type"] as? String{
            if type  == "input"{
                cellID = "inputCell"
            }else if type == "date"{
                cellID = "pickerCell"
                //datePickerRows.addObject(indexPath.row)
            }else if type == "picker"{
                cellID = "pickerCell"
                //datePickerRows.addObject(indexPath.row)
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID as String, forIndexPath: indexPath) as! UITableViewCell
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow: Int = indexPath.row
        if self.datePickerIndexPath != nil && self.datePickerIndexPath?.row <= indexPath.row{
            if cellID == "uiPicker"{
                if let picker: UIPickerView = self.tableView.viewWithTag(pickerTag) as? UIPickerView{
                    picker.delegate = self
                    picker.dataSource = self
                    picker.selectRow(pickerDataValues.indexOfObject(selectedPickerValue!), inComponent: 0, animated: false)
                }
            }
            --modelRow
        }
        
        if cellID != "uiPicker" || cellID == "date"{
            rowData = self.tableData.objectAtIndex(modelRow) as! NSDictionary
            //println(rowData)
            if let type: String = rowData["type"] as? String{
                if type  == "input"{
                    let label1: UILabel = cell.viewWithTag(1) as! UILabel
                    label1.text = rowData.objectForKey("title") as? String
                    
                    let input: UITextField = cell.viewWithTag(2) as! UITextField
                    input.placeholder = rowData.objectForKey("title") as? String
                    input.text = rowData.objectForKey("value") as? String
                    input.delegate = self
                    nameTextField = input
                }else if type == "picker"{
                    let label1: UILabel = cell.viewWithTag(1) as! UILabel
                    label1.text = rowData.objectForKey("title") as? String
                    
                    if let pickerValue: Int = rowData.objectForKey("value") as? Int{
                        selectedPickerValue = pickerValue
                        let label2: UILabel = cell.viewWithTag(2) as! UILabel
                        label2.text = pickerDataTitles.objectAtIndex(pickerDataValues.indexOfObject(selectedPickerValue!)) as? String
                    }else if selectedPickerValue == nil{
                        selectedPickerValue = 1
                    }
                }
            }
        }
        
        return cell
    }
    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
    */
    func hasInlineDatePicker()->Bool{
        //println("self.datePickerIndexPath: \(self.datePickerIndexPath)")
        //println("self.datePickerIndexPath != nil: \(self.datePickerIndexPath != nil)")
        return (self.datePickerIndexPath != nil)
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
    
    @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
    */
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool{
        let hasPicker: Bool = (self.hasInlineDatePicker() && self.datePickerIndexPath!.row == indexPath.row)
        //println("indexPathHasPicker: \(hasPicker)")
        return hasPicker
    }
    
    func displayInlinePickerForRowAtIndexPath(indexPath: NSIndexPath){
        self.tableView.beginUpdates()
        
        var shouldShowPicker: Bool = true
        //check if previously displayed picker is above selected indexPath
        var before: Bool = false
        // check for previusly displayed picker
        if self.datePickerIndexPath != nil{
            before = self.datePickerIndexPath!.row < indexPath.row
            
            self.tableView.beginUpdates()
            
            //println("before picker delete")
            let nIndexPath: NSIndexPath = NSIndexPath(forRow: self.datePickerIndexPath!.row, inSection: self.datePickerIndexPath!.section)
            // if previously selected row match with current row
            if self.datePickerIndexPath!.row - 1 == indexPath.row{
                shouldShowPicker = false
                //println("before same picker delete")
                self.tableView.deleteRowsAtIndexPaths([nIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }else{
                println("before different picker delete")
                self.tableView.deleteRowsAtIndexPaths([nIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            self.tableView.endUpdates()
            self.datePickerIndexPath = nil
            
           // println("after picker delete")
        }
        
        //println("before picker add")
        
        if shouldShowPicker{
            var nIndexPath: NSIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
            self.datePickerIndexPath = nIndexPath
            
            if before{
               nIndexPath = indexPath
               self.datePickerIndexPath = indexPath
            }
            
            self.tableView.insertRowsAtIndexPaths([nIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        
        if cell.reuseIdentifier == "pickerCell"{
            self.displayInlinePickerForRowAtIndexPath(indexPath)
        }else{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataValues.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataTitles.objectAtIndex(row) as! String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerValue = pickerDataValues.objectAtIndex(row) as? Int
        let indexPath: NSIndexPath = NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: datePickerIndexPath!.section)
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath){
            let label2: UILabel = cell.viewWithTag(2) as! UILabel
            label2.text = pickerDataTitles.objectAtIndex(pickerDataValues.indexOfObject(selectedPickerValue!)) as? String
        }
    }
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    @IBAction func onSubmitTap(sender: UIButton) {
        if nameTextField != nil && nameTextField!.text != ""{
            if self.identifier != nil{
                let predicate: NSPredicate = NSPredicate(format: "identifier == '\(self.identifier!)'")
                let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                if result.count > 0{
                    let accounttype: Accounttypes = result.lastObject as! Accounttypes
                    accounttype.name = "\(self.nameTextField!.text)"
                    accounttype.type = self.selectedPickerValue! as NSNumber
                    //accounttype.url = accounttype.id > 0 ? url : "accounttypes/add"
                    accounttype.modified = DVDateFormatter.currentDate
                    //accounttype.synced = false
                    var error: NSError?
                    moc.save(&error)
                    if error == nil{
                        println("only updated coredata. sync required")
                        self.navigationController?.popViewControllerAnimated(true)
                    }else{
                        AlertManager.showAlert(self, title: "Error", message: "There was an error. Please try again.", buttonNames: nil, completion: nil)
                        println(error!.localizedDescription)
                    }
                }
            }else if let accounttype: Accounttypes = CoreDataHelper.insertManagedObject(NSStringFromClass(Accounttypes), managedObjectContext: moc) as? Accounttypes{
                accounttype.identifier = DVDateFormatter.currentTimestamp
                println(accounttype.identifier)
                //accounttype.id = -1
                //accounttype.user_id = userID.integerValue
                accounttype.name = "\(self.nameTextField!.text)"
                accounttype.type = self.selectedPickerValue! as NSNumber
                accounttype.modified = DVDateFormatter.currentDate
                accounttype.created = DVDateFormatter.currentDate
                //accounttype.url = url
                //accounttype.synced = false
                let success: Bool = CoreDataHelper.saveManagedObjectContext(moc)
                if success == false{
                    AlertManager.showAlert(self, title: "Error", message: "There was an error. Please try again.", buttonNames: nil, completion: nil)
                    println("failed to save in coredata. accounttype.id: \(accounttype.id)")
                }else{
                    println("Saved to coredata. sync required")
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }else{
                AlertManager.showAlert(self, title: "Error", message: "There was an error. Please try again.", buttonNames: nil, completion: nil)
            }
        }else{
            AlertManager.showAlert(self, title: "Warning", message: "Please enter account type name", buttonNames: nil, completion: nil)
        }
        
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
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
