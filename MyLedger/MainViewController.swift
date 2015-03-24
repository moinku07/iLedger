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
    
    // MARK: - synchronizeAccountTypes
    func synchronizeAccountTypes(){
        DVSync.synchronizeAccountTypes()
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
