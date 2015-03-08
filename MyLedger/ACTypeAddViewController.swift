//
//  ACTypeAddViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 12/1/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

class ACTypeAddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var acTypeId: Int?
    @IBOutlet var tableView: UITableView!
    
    var tableData: NSMutableArray = [/*["title": "Other Cell1"], ["title": "Other Cell2"],*/["title": "Name", "type": "input", "placeHolder": "Name"],["title": "Start Date", "type": "picker", "date": NSDate()],["title": "End Date", "type": "date", "date": NSDate()]]
    
    var dateFormatter: NSDateFormatter?
    var pickerCellRowHeight: CGFloat?
    
    let datePickerTag:Int = 99
    let pickerTag:Int = 98
    
    var datePickerIndexPath: NSIndexPath?
    
    // keep track of which rows have date cells
    var datePickerRows: NSMutableArray = NSMutableArray()
    var pickerRows: NSMutableArray = NSMutableArray()
    
    let pickerData: NSArray = [["title": "Add", "type": 1], ["title": "Sub", "type": 2]]
    
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
            rowData = self.tableData.objectAtIndex(indexPath.row) as NSDictionary
        }
        
        var cellID: NSString = "otherCell"
        if self.indexPathHasPicker(indexPath){
            let prevRowData: NSDictionary = self.tableData.objectAtIndex(indexPath.row - 1) as NSDictionary
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as UITableViewCell
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow: Int = indexPath.row
        if self.datePickerIndexPath != nil && self.datePickerIndexPath?.row <= indexPath.row{
            if cellID == "uiPicker"{
                if let picker: UIPickerView = self.tableView.viewWithTag(pickerTag) as? UIPickerView{
                    picker.delegate = self
                    picker.dataSource = self
                }
            }
            --modelRow
        }
        rowData = self.tableData.objectAtIndex(modelRow) as NSDictionary
        
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
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let rowData: NSDictionary = pickerData.objectAtIndex(row) as NSDictionary
        return rowData.objectForKey("title") as String
    }
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func onLableTap(recognizer: UITapGestureRecognizer){
        let actionSheet: UIActionSheet = UIActionSheet(title: "", delegate: nil, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        //self.presentViewController(actionSheet, animated: true, completion: nil)
        actionSheet.showInView(self.view)
    }
    
    @IBAction func onSubmitTap(sender: UIButton) {
        
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
