//
//  AccountAddViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 3/29/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

class AccountAddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var isEdit: Bool = false
    var identifier: String?
    @IBOutlet var tableView: UITableView!
    
    var nameTextField: UITextField?
    var nameTextView: UITextView?
    
    var tableData: NSMutableArray = [["title": "Type", "type": "picker"/*, "value": 2*/],["title": "Details", "type": "textview"],["title": "Amount", "type": "input"]]
    
    var dateFormatter: NSDateFormatter?
    var pickerCellRowHeight: CGFloat?
    var textviewCellRowHeight: CGFloat = 150
    
    let datePickerTag:Int = 99
    let pickerTag:Int = 98
    
    var datePickerIndexPath: NSIndexPath?
    var textviewIndexPath: NSIndexPath?
    var selectedIndexPath: NSIndexPath?
    
    // keep track of which rows have date cells
    var datePickerRows: NSMutableArray = NSMutableArray()
    var pickerRows: NSMutableArray = NSMutableArray()
    
    var pickerDataValues: NSMutableArray = [1, 2]
    var pickerDataTitles: NSMutableArray = ["Add", "Sub"]
    var selectedPickerValue: Double?
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    var originalTableVeiwContentSize: CGSize!
    var originalTableVeiwContentOffset: CGPoint!
    
    var moc: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Add Account"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter?.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateFormatter?.timeStyle = NSDateFormatterStyle.NoStyle
        
        //self.tableView.rowHeight = 44
        pickerCellRowHeight = 216.0
        //println("self.tableView.rowHeight: \(self.tableView.rowHeight)")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        moc = CoreDataHelper.managedObjectContext(dataBaseFilename: "MyLedger")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("persistentStoreDidChange"), name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("persistentStoreWillChange:"), name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("retrieveICloudChanges:"), name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
        
        loadAccountTypes()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
    }
    
    func persistentStoreDidChange(){
        println("persistentStoreDidChange")
        loadAccountTypes()
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
            self.loadAccountTypes()
        }
    }
    
    func loadAccountTypes(){
        let predicate: NSPredicate = NSPredicate(format: "isdeleted = NO")
        //let sorter: NSSortDescriptor = NSSortDescriptor(key: "identifier", ascending: false)
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: [sorter], managedObjectContext: moc, limit: nil)
        if result.count > 0{
            println("load from coredata. count: \(result.count)")
            var dict: NSMutableDictionary = NSMutableDictionary()
            pickerDataValues.removeAllObjects()
            pickerDataTitles.removeAllObjects()
            for (index, item) in enumerate(result){
                if let accounttype: Accounttypes = item as? Accounttypes{
                    pickerDataValues.addObject((accounttype.identifier as NSString).doubleValue)
                    pickerDataTitles.addObject(accounttype.name)
                }
            }
        }
        
        self.tableView.reloadData()
        
        //println(pickerDataValues)
        //println(pickerDataTitles)
        
        //println(tableData)
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
        return self.datePickerIndexPath == nil ? tableData.count : tableData.count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat = (self.indexPathHasPicker(indexPath) ? self.pickerCellRowHeight! : self.tableView.rowHeight)
        height = (self.indexPathHasTextView(indexPath) ? self.textviewCellRowHeight : height)
        //println(self.indexPathHasTextView(indexPath) ? self.textviewCellRowHeight : height)
        return height
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
            }else if type  == "textview"{
                cellID = "textviewCell"
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
            //println("datePickerIndexPath.row: \(datePickerIndexPath!.row)")
            if cellID == "uiPicker"{
                if let picker: UIPickerView = self.tableView.viewWithTag(pickerTag) as? UIPickerView{
                    picker.delegate = self
                    picker.dataSource = self
                    picker.selectRow(pickerDataValues.indexOfObject(selectedPickerValue!), inComponent: 0, animated: false)
                }
            }
            --modelRow
        }
        
        if cellID != "uiPicker" || cellID == "date" || self.datePickerIndexPath?.compare(indexPath) != NSComparisonResult.OrderedSame{
            //println("indexPath.row: \(indexPath.row)")
            //println("modelRow: \(modelRow)")
            rowData = self.tableData.objectAtIndex(modelRow) as! NSDictionary
            //println(rowData)
            if let type: String = rowData["type"] as? String{
                //println(rowData)
                if type  == "input"{
                    if let label1: UILabel = cell.viewWithTag(1) as? UILabel{
                        label1.text = rowData.objectForKey("title") as? String
                    }
                    
                    if let input: UITextField = cell.viewWithTag(2) as? UITextField{
                        input.placeholder = rowData.objectForKey("title") as? String
                        input.text = rowData.objectForKey("value") as? String
                        input.delegate = self
                        input.keyboardType = UIKeyboardType.DecimalPad
                        nameTextField = input
                    }
                }else if type  == "textview"{
                    if let label1: UILabel = cell.viewWithTag(1) as? UILabel{
                        label1.text = rowData.objectForKey("title") as? String
                    }
                    
                    if let input: UITextView = cell.viewWithTag(2) as? UITextView{
                        //input.text = rowData.objectForKey("title") as? String
                        input.text = rowData.objectForKey("value") as? String
                        println(rowData.objectForKey("value"))
                        
                        input.delegate = self
                        nameTextView = input
                        
                        textviewIndexPath = indexPath
                    }
                }else if type == "picker"{
                    if let label1: UILabel = cell.viewWithTag(1) as? UILabel{
                        label1.text = rowData.objectForKey("title") as? String
                    }
                    //println(rowData.objectForKey("value"))
                    if let pickerValue: Double = rowData.objectForKey("value") as? Double{
                        selectedPickerValue = pickerValue
                        let label2: UILabel = cell.viewWithTag(2) as! UILabel
                        label2.text = pickerDataTitles.objectAtIndex(pickerDataValues.indexOfObject(selectedPickerValue!)) as? String
                    }else if selectedPickerValue == nil{
                        selectedPickerValue = pickerDataValues.objectAtIndex(0) as? Double
                        let label2: UILabel = cell.viewWithTag(2) as! UILabel
                        label2.text = pickerDataTitles.objectAtIndex(pickerDataValues.indexOfObject(selectedPickerValue!)) as? String
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
    
    func indexPathHasTextView(indexPath: NSIndexPath) -> Bool{
        if textviewIndexPath != nil{
            var nIndexPath: NSIndexPath!
            if self.datePickerIndexPath != nil{
                nIndexPath = NSIndexPath(forRow: self.datePickerIndexPath!.row + 1, inSection: self.datePickerIndexPath!.section)
            }else{
                nIndexPath = self.textviewIndexPath!
            }
            if indexPath.compare(nIndexPath) == NSComparisonResult.OrderedSame{
                return true
            }
        }else{
            let rowData: NSDictionary = self.tableData.objectAtIndex(indexPath.row) as! NSDictionary
            if rowData.objectForKey("type") as? String == "textview"{
                return true
            }
        }
        return false
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
        selectedPickerValue = pickerDataValues.objectAtIndex(row) as? Double
        let indexPath: NSIndexPath = NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: datePickerIndexPath!.section)
        if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath){
            let label2: UILabel = cell.viewWithTag(2) as! UILabel
            //println(pickerDataValues)
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
                let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                if result.count > 0{
                    let account: Accounts = result.lastObject as! Accounts
                    account.details = "\(self.nameTextView!.text)"
                    println(self.selectedPickerValue!)
                    account.accounttype_id = self.selectedPickerValue! as Double
                    println(account.accounttype_id)
                    account.amount = NSDecimalNumber(string: self.nameTextField!.text)
                    account.modified = DVDateFormatter.currentDate
                    //account.synced = false
                    
                    // accounttype for account
                    let predicate: NSPredicate = NSPredicate(format: "identifier == \(account.accounttype_id)")
                    println(predicate)
                    let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                    println(result)
                    if result.count > 0{
                        let accounttype: Accounttypes = result.lastObject as! Accounttypes
                        account.accounttype = accounttype
                    }
                    //end
                    
                    var error: NSError?
                    moc.save(&error)
                    if error == nil{
                        self.navigationController?.popViewControllerAnimated(true)
                        println("only updated coredata. sync required")
                    }else{
                        AlertManager.showAlert(self, title: "Error", message: "There was an error. Please try again", buttonNames: nil, completion: nil)
                        println(error!.localizedDescription)
                    }
                }
            }else{
                if let account: Accounts = CoreDataHelper.insertManagedObject(NSStringFromClass(Accounts), managedObjectContext: moc) as? Accounts{
                    account.identifier = DVDateFormatter.currentTimestamp
                    account.details = "\(self.nameTextView!.text)"
                    println(self.selectedPickerValue!)
                    account.accounttype_id = self.selectedPickerValue! as Double
                    println(account.accounttype_id)
                    account.amount = NSDecimalNumber(string: self.nameTextField!.text)
                    account.modified = DVDateFormatter.currentDate
                    account.created = DVDateFormatter.currentDate
                    //account.synced = false
                    
                    // accounttype for account
                    let predicate: NSPredicate = NSPredicate(format: "identifier == \(account.accounttype_id)")
                    println(predicate)
                    let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounttypes), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: 1)
                    println(result)
                    if result.count > 0{
                        let accounttype: Accounttypes = result.lastObject as! Accounttypes
                        account.accounttype = accounttype
                    }
                    //end
                    
                    let success: Bool = CoreDataHelper.saveManagedObjectContext(moc)
                    if success == false{
                        AlertManager.showAlert(self, title: "Error", message: "There was an error. Please try again", buttonNames: nil, completion: nil)
                        println("failed to save in coredata. account.id: \(account.id)")
                    }else{
                        self.navigationController?.popViewControllerAnimated(true)
                        println("Saved to coredata. sync required")
                    }
                }
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
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // Create a button bar for the number pad
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        
        // Setup the buttons to be put in the system.
        var item: UIBarButtonItem = UIBarButtonItem()
        item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("onTextViewDoneTap") )
        
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var toolbarButtons = [flexSpace,item]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: true)
        textField.inputAccessoryView = keyboardDoneButtonView
        
        nameTextField = textField
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        originalTableVeiwContentSize = tableView.contentSize
        originalTableVeiwContentOffset = tableView.contentOffset
        if originalTableVeiwContentSize.height + 300 >= self.tableView.frame.size.height{
            println("originalTableVeiwContentSize")
            self.tableView.contentSize = CGSizeMake(self.originalTableVeiwContentSize.width, self.originalTableVeiwContentSize.height + 300)
        }
        
        if let cell: UITableViewCell = textField.superview?.superview as? UITableViewCell{
            println(self.tableView.indexPathForCell(cell))
            self.selectedIndexPath = self.tableView.indexPathForCell(cell)
        }
        
        if let cell: UITableViewCell = textField.superview?.superview?.superview as? UITableViewCell{
            self.selectedIndexPath = tableView.indexPathForCell(cell)
        }else if let cell: UITableViewCell = textField.superview?.superview as? UITableViewCell{
            self.selectedIndexPath = tableView.indexPathForCell(cell)
        }
        if self.selectedIndexPath != nil{
            println("before scroll")
            println(self.selectedIndexPath)
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5000 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                self.tableView.scrollToRowAtIndexPath(self.selectedIndexPath!, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                println("after scroll")
            //})
            let cellPosition: CGRect = tableView.rectForRowAtIndexPath(self.selectedIndexPath!)
            if cellPosition.origin.y + 64 + 280 > self.view.bounds.size.height{
                let offsetY: CGFloat = 280 - (tableView.frame.size.height - cellPosition.origin.y - 64)
                //println(offsetY)
                tableView.setContentOffset(CGPointMake(0, offsetY), animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tableView.setContentOffset(originalTableVeiwContentOffset, animated: true)
        if originalTableVeiwContentSize != nil && self.tableView != nil{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 250 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue()){
                self.tableView.contentSize = self.originalTableVeiwContentSize
                self.originalTableVeiwContentSize = nil
            }
        }
        self.selectedIndexPath = nil
    }
    
    // MARK: - UITextViewDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        // Create a button bar for the number pad
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        
        // Setup the buttons to be put in the system.
        var item: UIBarButtonItem = UIBarButtonItem()
        item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("onTextViewDoneTap") )
        
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var toolbarButtons = [flexSpace,item]
        
        //Put the buttons into the ToolBar and display the tool bar
        keyboardDoneButtonView.setItems(toolbarButtons, animated: true)
        textView.inputAccessoryView = keyboardDoneButtonView
        nameTextView = textView
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        originalTableVeiwContentSize = tableView.contentSize
        if originalTableVeiwContentSize.height + 300 >= self.tableView.frame.size.height{
            self.tableView.contentSize = CGSizeMake(self.originalTableVeiwContentSize.width, self.originalTableVeiwContentSize.height + 300)
        }
        if let cell: UITableViewCell = textView.superview?.superview as? UITableViewCell{
            self.selectedIndexPath = self.tableView.indexPathForCell(cell)
        }
        if self.selectedIndexPath != nil{
            self.tableView.scrollToRowAtIndexPath(self.selectedIndexPath!, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if originalTableVeiwContentSize != nil && self.tableView != nil{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 250 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue()){
                self.tableView.contentSize = self.originalTableVeiwContentSize
                self.originalTableVeiwContentSize = nil
            }
        }
        self.selectedIndexPath = nil
    }
    
    // MARK: - onTextViewDoneTap
    func onTextViewDoneTap(){
        nameTextView?.resignFirstResponder()
        nameTextField?.resignFirstResponder()
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
