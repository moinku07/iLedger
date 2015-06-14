//
//  AccountDatePickerViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 4/3/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

class AccountDatePickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var identifier: String?
    @IBOutlet var tableView: UITableView!
    
    var nameTextField: UITextField?
    
    var tableData: NSMutableArray = [["title": "Start Date", "type": "date"],["title": "End Date", "type": "date"],["title": "Type", "type": "picker"]]
    
    var dateFormatter: NSDateFormatter?
    var pickerCellRowHeight: CGFloat?
    
    let datePickerTag:Int = 99
    let pickerTag:Int = 98
    
    var datePickerIndexPath: NSIndexPath?
    
    // keep track of which rows have date cells
    var datePickerRows: NSMutableArray = NSMutableArray()
    var pickerRows: NSMutableArray = NSMutableArray()
    
    var pickerDataValues: NSMutableArray = [1, 2]
    var pickerDataTitles: NSMutableArray = ["Add", "Sub"]
    var selectedPickerValue: Int?
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add Account Type"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter?.dateFormat = "dd/MM/yyyy"
        //self.dateFormatter?.dateStyle = NSDateFormatterStyle.FullStyle
        //self.dateFormatter?.timeStyle = NSDateFormatterStyle.NoStyle
        
        pickerCellRowHeight = 216.0
        //println("self.tableView.rowHeight: \(self.tableView.rowHeight)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let userID: NSNumber = (prefs.objectForKey("userID") as! NSString).integerValue
        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
        let predicate: NSPredicate = NSPredicate(format: "user_id == '\(userID)' AND isdeleted = NO")
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
                    pickerDataValues.addObject(accounttype.id.integerValue)
                    pickerDataTitles.addObject(accounttype.name)
                }
            }
        }
        
        //println(pickerDataValues)
        //println(pickerDataTitles)
        
        println(tableData)
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
                    if selectedPickerValue != nil{
                        picker.selectRow(pickerDataValues.indexOfObject(selectedPickerValue!), inComponent: 0, animated: false)
                    }
                }
            }
            --modelRow
        }
        
        if cellID != "uiPicker" || cellID != "datePicker"{
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
                    if let label1: UILabel = cell.viewWithTag(1) as? UILabel{
                        label1.text = rowData.objectForKey("title") as? String
                    }
                    if let label2: UILabel = cell.viewWithTag(2) as? UILabel{
                        label2.text = "Select Account type"
                    }
                    selectedPickerValue = nil
                }else if type == "date"{
                    if let label1: UILabel = cell.viewWithTag(1) as? UILabel{
                        label1.text = rowData.objectForKey("title") as? String
                    }
                    
                    if let label2: UILabel = cell.viewWithTag(2) as? UILabel{
                        if let date: NSDate = rowData.objectForKey("date") as? NSDate{
                            label2.text = self.dateFormatter?.stringFromDate(date)
                        }else{
                            label2.text = "Select date"
                        }
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
    
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
    */
    func updateDatePicker(){
        if self.datePickerIndexPath != nil{
            let associatedDatePickerCell: UITableViewCell = self.tableView.cellForRowAtIndexPath(self.datePickerIndexPath!) as UITableViewCell!
            let targetedDatePicker: UIDatePicker? = associatedDatePickerCell.viewWithTag(datePickerTag) as? UIDatePicker
            if targetedDatePicker != nil{
                // we found a UIDatePicker in this cell, so update it's date value
                //
                let itemData: NSDictionary = self.tableData.objectAtIndex(self.datePickerIndexPath!.row - 1) as! NSDictionary
                if let date: NSDate = itemData.valueForKey("date") as? NSDate{
                    //println("datePickerDate: \(date)")
                    targetedDatePicker?.setDate(itemData.valueForKey("date") as! NSDate, animated: false)
                }else{
                    targetedDatePicker?.setDate(NSDate(), animated: false)
                }
            }
        }
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
        
        // inform our date picker of the current date to match the current cell
        self.updateDatePicker()
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
    
    // MARK: - DatePicker Action
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        var targetedCellIndexPath: NSIndexPath? = nil
        
        if self.hasInlineDatePicker(){
            // inline date picker: update the cell's date "above" the date picker cell
            //
            targetedCellIndexPath = NSIndexPath(forRow: self.datePickerIndexPath!.row - 1, inSection: self.datePickerIndexPath!.section)
            
            let cell: UITableViewCell = self.tableView.cellForRowAtIndexPath(targetedCellIndexPath!) as UITableViewCell!
            let targetedDatePicker: UIDatePicker = sender
            
            // update our data model
            var itemData: NSMutableDictionary = NSMutableDictionary(dictionary: self.tableData.objectAtIndex(targetedCellIndexPath!.row) as! NSDictionary)
            var dict: NSMutableDictionary = NSMutableDictionary(dictionary: itemData)
            dict.setValue(targetedDatePicker.date, forKey: "date")
            self.tableData.replaceObjectAtIndex(targetedCellIndexPath!.row, withObject: dict)
            
            // update the cell's date string
            if let label2: UILabel = cell.viewWithTag(2) as? UILabel{
                if let date: NSDate = dict.objectForKey("date") as? NSDate{
                    //println("here")
                    label2.text = self.dateFormatter?.stringFromDate(date)
                }else{
                    label2.text = "Select date"
                }
            }
        }else{
            
        }
    }
    
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    @IBAction func onSubmitTap(sender: UIButton) {
        let vc: AccountSummaryViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AccountSummaryViewController") as! AccountSummaryViewController
        let dict1: NSDictionary = tableData.objectAtIndex(0) as! NSDictionary
        let dict2: NSDictionary = tableData.objectAtIndex(1) as! NSDictionary
        vc.startDate = dict1.objectForKey("date") as? NSDate
        vc.endDate = dict2.objectForKey("date") as? NSDate
        vc.accounttype_id = selectedPickerValue
        self.navigationController?.pushViewController(vc, animated: true)
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
