//
//  ACTypesListTableViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 12/2/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

class ACTypesListTableViewController: UITableViewController {
    
    var tableData: NSMutableArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Account Types List"
        
        self.loadDataFromServer()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        
        if let data = self.tableData.objectAtIndex(indexPath.row) as? NSDictionary{
            cell.textLabel.text = data["name"] as? String
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let nextVC: ACTypeAddViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ACTypeAddViewController") as ACTypeAddViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
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
    
    // MARK: - Load Account Types List from server
    
    func loadDataFromServer(){
        // activity indicator
        var activityIndicator = UICustomActivityView()
        activityIndicator.showActivityIndicator(self.view, style: UIActivityIndicatorViewStyle.Gray, shouldHaveContainer: false)
        
        DataManager.loadDataAsyncWithCallback("accounttypes/list.json", completion: { (data, error) -> Void in
            activityIndicator.hideActivityIndicator()
            if error == nil && data != nil{
                var err: NSError? = nil
                var json: NSMutableArray? = NSJSONSerialization.JSONObjectWithData(data!,options: NSJSONReadingOptions.AllowFragments,error:&err) as? NSMutableArray
                if err == nil{
                    if let data = json{
                        self.tableData = data as NSMutableArray
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        })
    }
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
