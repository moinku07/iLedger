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
    
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var usernameTextfield: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    var scrollViewDefaultContentSize: CGSize!
    
    @IBOutlet var scrollContainerView: UIView!
    
    var containerTopBottomConstraintPort: NSArray!
    var containerTopBottomConstraintLand: NSArray!
    
    var isEditing:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextfield.delegate = self
        usernameTextfield.delegate = self
        
        // style containerView
        containerView.layer.cornerRadius = 8
        
        // style textInputs
        usernameTextfield.layer.cornerRadius = 8
        usernameTextfield.layer.borderWidth = 1
        usernameTextfield.layer.borderColor = UIColor(red: 172/255, green: 172/255, blue: 172/255, alpha: 1.0).CGColor
        usernameTextfield.leftViewMode = UITextFieldViewMode.Always
        usernameTextfield.leftView = UIView(frame: CGRectMake(0, 0, 10, 10))
        
        passwordTextfield.layer.cornerRadius = 8
        passwordTextfield.layer.borderWidth = 1
        passwordTextfield.layer.borderColor = UIColor(red: 172/255, green: 172/255, blue: 172/255, alpha: 1.0).CGColor
        passwordTextfield.leftViewMode = UITextFieldViewMode.Always
        passwordTextfield.leftView = UIView(frame: CGRectMake(0, 0, 10, 10))
        
        
        let containerViewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onContainerViewTap:")
        containerView.addGestureRecognizer(containerViewTapGesture)
        
        
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
    
    func onContainerViewTap(sender: UIView){
        passwordTextfield.resignFirstResponder()
        usernameTextfield.resignFirstResponder()
        if self.isEditing == true{
            let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 300 * Int64(NSEC_PER_MSEC))
            let dispatchAfter: Void = dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
                self.isEditing = false
                self.scrollView.contentSize = self.scrollViewDefaultContentSize
                self.scrollView.setContentOffset(CGPointZero, animated: true)
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if scrollViewDefaultContentSize == nil{
            scrollViewDefaultContentSize = self.scrollView.contentSize
        }
        if (self.view.frame.height - (textField.frame.origin.y + textField.frame.size.height) < 285) && (isEditing == false){
            isEditing = true
            
            let yPoint = 285 - (self.view.frame.height - (textField.frame.origin.y + textField.frame.size.height))
            let scrollPoint: CGPoint = CGPointMake(0, yPoint)
            self.scrollView.setContentOffset(scrollPoint, animated: true)
            
            let newContentSize: CGSize = CGSizeMake(scrollViewDefaultContentSize.width, scrollViewDefaultContentSize.height + 280)
            println(newContentSize)
            self.scrollView.contentSize = newContentSize

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
