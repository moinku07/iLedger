//
//  LoginViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 11/22/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var signupButton: UIButton!
    
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    var containerTopBottomConstraintPort: NSArray!
    var containerTopBottomConstraintLand: NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //textField.delegate = self
        
        // style containerView
        containerView.layer.cornerRadius = 8
        
        
        //style signupButton
        var maskPath: UIBezierPath = UIBezierPath(roundedRect: signupButton.bounds, byRoundingCorners: (UIRectCorner.TopRight | UIRectCorner.BottomLeft), cornerRadii: CGSizeMake(8.0, 8.0))
        var maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = signupButton.bounds
        maskLayer.path = maskPath.CGPath
        signupButton.layer.mask = maskLayer
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if self.view.frame.height - (textField.frame.origin.y + textField.frame.size.height) < 285{
            let yPoint = 285 - (self.view.frame.height - (textField.frame.origin.y + textField.frame.size.height))
            let scrollPoint: CGPoint = CGPointMake(0, yPoint);
            self.scrollView.setContentOffset(scrollPoint, animated: true);
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        println("here")
        self.scrollView.setContentOffset(CGPointZero, animated: true)
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
