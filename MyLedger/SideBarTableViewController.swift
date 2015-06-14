//
//  SideBarTableViewController.swift
//  BlurrySideBar
//
//  Created by Moin Uddin on 11/13/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

protocol SideBarTableViewControllerDelegate{
    func sideBarControlDidSelectRow(indexPath: NSIndexPath)
}

class SideBarTableViewController: UITableViewController {
    
    var delegate: SideBarTableViewControllerDelegate?
    var tableData: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        self.tableView.scrollEnabled = false
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
        return self.tableData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            // Configure the cell
            
            cell?.backgroundColor = UIColor.clearColor();
            cell?.textLabel?.textColor = UIColor.whiteColor()
            
            let selectedView: UIView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
            
            cell!.selectedBackgroundView = selectedView
        }
        //cell?.backgroundColor = UIColor.redColor()
        let cellData: NSDictionary = self.tableData.objectAtIndex(indexPath.row) as! NSDictionary
        
        cell?.textLabel?.text = cellData.objectForKey("title") as? String
        
        if let imageName: String = cellData.objectForKey("icon") as? String{
            if !imageName.isEmpty || imageName != ""{
                cell?.imageView?.image = UIImage(named: imageName)
            }
        }

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.sideBarControlDidSelectRow(indexPath)
    }

}
