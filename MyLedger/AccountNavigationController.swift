//
//  AccountNavigationController.swift
//  MyLedger
//
//  Created by Moin Uddin on 3/28/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit

class AccountNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StatusBar Style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.viewControllers.last!.preferredStatusBarStyle()
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
