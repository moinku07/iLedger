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
    @IBOutlet var loginButton: UIButton!
    
    var viewsDict: NSMutableDictionary!
    
    var isEditing:Bool = false
    
    var currentOrientation: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add keyboard disappear observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
        
        println("Name : \(UIDevice.currentDevice().name)")
        println("Model : \(UIDevice.currentDevice().model)")
        
        // textField delegate
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
        
        // style loginButton
        let loginButtonImageView = UIImageView()
        loginButtonImageView.image = UIImage(named: "tick_white")
        loginButtonImageView.contentMode = UIViewContentMode.ScaleAspectFit
        loginButton.addSubview(loginButtonImageView)
        loginButtonImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        viewsDict = ["loginButtonImageView": loginButtonImageView, "loginButton": loginButton]
        loginButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[loginButton]-(<=0)-[loginButtonImageView(28)]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDict))
        loginButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[loginButton]-(<=0)-[loginButtonImageView(21.5)]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDict))
        //loginButton.setBackgroundImage(<#image: UIImage?#>, forState: <#UIControlState#>)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
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
        passwordTextfield.resignFirstResponder()
        usernameTextfield.resignFirstResponder()
        if self.isEditing == true{
            self.isEditing = false
            self.scrollView.setContentOffset(CGPointZero, animated: true)
            let delay: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 300 * Int64(NSEC_PER_MSEC))
            let dispatchAfter: Void = dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
                if self.currentOrientation == UIDevice.currentDevice().orientation.rawValue{
                    self.scrollView.contentSize = self.scrollViewDefaultContentSize
                }
            
            }
        }
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // capture scrollView contentSize for the first time
        if scrollViewDefaultContentSize == nil{
            scrollViewDefaultContentSize = self.scrollView.contentSize
        }
        
        currentOrientation = UIDevice.currentDevice().orientation.rawValue
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone{
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
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad && (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight)){
            // calculation to auto scroll up scroll view when textfield hides behind keyboard
            let yPoint = textField.frame.origin.y + textField.frame.size.height + 25
            let keyboardYpoint = self.view.frame.height - 352
            let scrollY = yPoint - keyboardYpoint
            if (yPoint > keyboardYpoint) && (self.scrollView.contentOffset.y < scrollY){
                println("here")
                let scrollPoint: CGPoint = CGPointMake(0, scrollY)
                self.scrollView.setContentOffset(scrollPoint, animated: true)
            }
            
            // check if textField is editing and set new contentSize so user can scroll all inputs
            if isEditing == false{
                isEditing = true
                
                let newContentSize: CGSize = CGSizeMake(scrollViewDefaultContentSize.width, scrollViewDefaultContentSize.height + 120)
                self.scrollView.contentSize = newContentSize
            }
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
        
        if textField.tag == 2{
            self.loginButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }
        
        return false
    }
    
    // MARK: - Keyboard Disappear Observer
    func keyboardWillDisappear(notification: NSNotification){
        self.onContainerViewTap(self.containerView)
    }
    
    
    // MARK: - Login Button Action
    
    @IBAction func onLoginButtonTap(sender: UIButton) {
        // auto scroll to default
        self.onContainerViewTap(self.containerView)
        
        let userName = self.usernameTextfield.text
        let passWord = self.passwordTextfield.text
        
        if(userName.isEmpty){
            AlertManager.showAlert(self, title: "Warning", message: "Please enter username", buttonNames: nil)
        }else if passWord.isEmpty{
            AlertManager.showAlert(self, title: "Warning", message: "Please enter password", buttonNames: nil)
        }else{
            var params = ["User": ["username":userName, "password": passWord, "ajax" : true]]
            
            // activity indicator
            var activityIndicator = UICustomActivityView()
            activityIndicator.showActivityIndicator(self.view, style: UIActivityIndicatorViewStyle.Gray, shouldHaveContainer: false)
            
            DataManager.postDataWithCallback("http://10.0.0.10/ledger/admin/users/login", jsonData: params) { (data, error) -> Void in
                activityIndicator.hideActivityIndicator()
                if let posterror = error{
                    println(posterror.code)
                    println(posterror.localizedDescription)
                }else{
                    let json = JSON(data: data!)
                    let message = json["message"]
                    if json["success"] == false{
                        AlertManager.showAlert(self, title: "Login Failed!", message: "\(message)", buttonNames: ["OK"], completion: nil)
                    }else{
                        println(json)
                        println("login successful")
                    }
                }
            }
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
