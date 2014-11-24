//
//  LoginViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 11/22/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var signupButton: UIButton!
    
    var containerTopBottomConstraintPort: NSArray!
    var containerTopBottomConstraintLand: NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // style containerView
        containerView.layer.cornerRadius = 8
        
        
        //style signupButton
        var maskPath: UIBezierPath = UIBezierPath(roundedRect: signupButton.bounds, byRoundingCorners: (UIRectCorner.TopRight | UIRectCorner.BottomLeft), cornerRadii: CGSizeMake(8.0, 8.0))
        var maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = signupButton.bounds
        maskLayer.path = maskPath.CGPath
        signupButton.layer.mask = maskLayer
        signupButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
