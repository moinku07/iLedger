//
//  MainViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 12/1/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, SideBarDelegate {
    
    var sideBar: SideBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false
        
        sideBar = SideBar(sourceView: self.view, menuItems: ["Logout"])
        sideBar.delegate = self
        
        sideBar.shouldDeselectSelectedRow = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sideBarDidSelectRowAtIndex(index: Int) {
        if index == 0{
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.setObject(nil, forKey: "username")
            prefs.setObject(nil, forKey: "password")
            prefs.synchronize()
            self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func onViewTap(recognizer: UITapGestureRecognizer){
        if sideBar.isSideBarOpen{
            sideBar.showSideBar(false)
        }
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
