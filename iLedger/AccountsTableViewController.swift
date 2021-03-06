//
//  AccountsTableViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 3/28/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit

class AccountsTableViewController: UITableViewController {
    
    let tableData: NSMutableArray = ["Add Account", "See Accounts", "Account Summary"]
    
    var selectedRowIndexPath: NSIndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 102/255, green: 51/255, blue: 0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

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
        if selectedRowIndexPath != nil{
            self.tableView.deselectRowAtIndexPath(selectedRowIndexPath!, animated: true)
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = self.tableData.objectAtIndex(indexPath.row) as? String
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRowIndexPath = indexPath
        let rowTitle: String! = self.tableData.objectAtIndex(indexPath.row) as? String
        if rowTitle == "Add Account"{
            let nextVC: AccountAddViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AccountAddViewController") as! AccountAddViewController
            //let nextVC: ACTypeAddTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ACTypeAddViewController") as ACTypeAddTableViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else if rowTitle == "See Accounts"{
            let nextVC: AccountsListTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AccountsListTableViewController") as! AccountsListTableViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else if rowTitle == "Account Summary"{
            let nextVC: AccountDatePickerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AccountDatePickerViewController") as! AccountDatePickerViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
