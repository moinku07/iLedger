//
//  SignUpViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 11/30/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var signupButton: UIButton!
    
    
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var usernameTextfield: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    var scrollViewDefaultContentSize: CGSize!
    
    @IBOutlet var scrollContainerView: UIView!
    
    var viewsDict: NSMutableDictionary!
    
    var isEditing:Bool = false
    
    var textFields: Array<UITextField>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // style containerView
        containerView.layer.cornerRadius = 8
        
        // textFields array
        textFields = [firstName, lastName, usernameTextfield, passwordTextfield]
        
        for input in textFields{
            let textField: UITextField = input as UITextField
            
            // textField delegate
            textField.delegate = self
            
            // style textInputs
            textField.layer.cornerRadius = 8
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor(red: 172/255, green: 172/255, blue: 172/255, alpha: 1.0).CGColor
            textField.leftViewMode = UITextFieldViewMode.Always
            textField.leftView = UIView(frame: CGRectMake(0, 0, 10, 10))
        }
        
        let containerViewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onContainerViewTap:")
        containerView.addGestureRecognizer(containerViewTapGesture)
        
        
        // style signupButton
        let loginButtonImageView = UIImageView()
        loginButtonImageView.image = UIImage(named: "tick_white")
        loginButtonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        signupButton.addSubview(loginButtonImageView)
        loginButtonImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        viewsDict = ["loginButtonImageView": loginButtonImageView, "loginButton": signupButton]
        signupButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[loginButton]-(<=0)-[loginButtonImageView(28)]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDict))
        signupButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[loginButton]-(<=0)-[loginButtonImageView(21.5)]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDict))
        //loginButton.setBackgroundImage(<#image: UIImage?#>, forState: <#UIControlState#>)

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        // setting initial scrollView content height
        let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 1000 * Int64(NSEC_PER_MSEC))
        dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
            if self.scrollViewDefaultContentSize == nil{
                self.scrollViewDefaultContentSize = self.scrollView.contentSize
            }
            self.scrollView.setContentOffset(CGPointZero, animated: true)
            let newContentSize: CGSize = CGSizeMake(self.scrollViewDefaultContentSize.width, self.scrollContainerView.bounds.size.height)
            self.scrollView.contentSize = newContentSize
            println(self.scrollView.contentSize)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> Int {
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad){
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - ContainerView tap handle
    
    func onContainerViewTap(sender: UIView){
        for input in textFields{
            let textField: UITextField = input as UITextField
            textField.resignFirstResponder()
        }
        
        if self.isEditing == true{
            self.isEditing = false
            self.scrollView.setContentOffset(CGPointZero, animated: true)
            let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 300 * Int64(NSEC_PER_MSEC))
            let dispatchAfter: Void = dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
                self.scrollView.contentSize = self.scrollViewDefaultContentSize
                
            }
        }
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // capture scrollView contentSize for the first time
        if scrollViewDefaultContentSize == nil{
            scrollViewDefaultContentSize = self.scrollView.contentSize
        }
        
        // calculation to auto scroll up scroll view when textfield hides behind keyboard
        let yPoint = 285 - (self.view.frame.height - (textField.frame.origin.y + textField.frame.size.height))
        if (self.view.frame.height - (textField.frame.origin.y + textField.frame.size.height) < 285) && (self.scrollView.contentOffset.y < yPoint){
            let scrollPoint: CGPoint = CGPointMake(0, yPoint)
            self.scrollView.setContentOffset(scrollPoint, animated: true)
        }
        
        // check if textField is editing and set new contentSize so user can scroll all inputs
        if isEditing == false{
            isEditing = true
            
            let newContentSize: CGSize = CGSizeMake(scrollViewDefaultContentSize.width, scrollViewDefaultContentSize.height + (280 - yPoint))
            self.scrollView.contentSize = newContentSize
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1
        
        if let nextResponder: UIResponder = textField.superview?.viewWithTag(nextTag)?{
            nextResponder.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            self.onContainerViewTap(self.containerView)
        }
        
        if textField.tag == 4{
            self.signupButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }
        
        return false
    }
    
    
    // MARK: - Signup Button Action
    
    @IBAction func onSignupButtonTap(sender: UIButton) {
        // auto scroll to default
        self.onContainerViewTap(self.containerView)
        
        let userName = self.usernameTextfield.text
        let passWord = self.passwordTextfield.text
        
        if(userName.isEmpty){
            AlertManager.showAlert(self, alertTitle: "Warning", alertMessage: "Please enter username", okayButtonTitle: "Okay")
        }else if passWord.isEmpty{
            AlertManager.showAlert(self, alertTitle: "Warning", alertMessage: "Please enter password", okayButtonTitle: "Okay")
        }else{
            var params = ["User": ["username":userName, "password": passWord, "ajax" : true]]
            
            // activity indicator
            var activityIndicator = UICustomActivityView()
            activityIndicator.showActivityIndicator(self.view, style: UIActivityIndicatorViewStyle.Gray, shouldHaveContainer: false)
            
            DataManager.postDataWithCallback("http://10.0.0.10/ledger/admin/users/sign", jsonData: params) { (data, error) -> Void in
                activityIndicator.hideActivityIndicator()
                if let posterror = error{
                    println(posterror.code)
                    println(posterror.localizedDescription)
                }else{
                    let json = JSON(data: data!)
                    println(json)
                }
            }
        }
    }
    
    @IBAction func onCancelButtonTap(sender: AnyObject) {
        /*
        UIView.beginAnimations("flipview", context: nil)
        UIView.setAnimationDuration(1)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: self.view.superview!, cache: true)
        self.view.removeFromSuperview()
        UIView.commitAnimations()
        */
        self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        
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
