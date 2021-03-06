//
//  AlertManager.swift
//  MyLedger
//
//  Created by Moin Uddin on 11/30/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

var alertManagerCompletion : ((index: Int) -> Void)?

class AlertManager: NSObject, UIAlertViewDelegate {
    
    convenience init(viewController: UIViewController?,title: String? = nil, message: String? = nil, buttonNames: Array<String>? = nil, completion: ((index: Int) -> Void)? = nil) {
        self.init()
        let alertTitle1 = (title == nil || title!.isEmpty) ? "Alert" : title!;
        let alertMsg = (message == nil || message!.isEmpty) ? alertTitle1 : message!;
        
        if(AlertManager.isIOS8() == true && viewController != nil){
            let alertController: UIAlertController = UIAlertController(title: alertTitle1, message: alertMsg, preferredStyle: UIAlertControllerStyle.Alert);
            if buttonNames == nil{
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
                    if completion != nil{
                        completion!(index: 0)
                    }
                }));
            }else{
                for (index,name) in enumerate(buttonNames!){
                    alertController.addAction(UIAlertAction(title: name, style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
                        if completion != nil{
                            completion!(index: index)
                        }
                    }))
                }
            }
            
            viewController!.presentViewController(alertController, animated: true, completion: nil)
        }else{
            let alertView: UIAlertView = UIAlertView(title: alertTitle1, message: alertMsg, delegate: AlertManager.self, cancelButtonTitle: nil)
            /*let alertView: UIAlertView = UIAlertView()
            alertView.title = alertTitle1
            alertView.message = alertMsg
            alertView.delegate = AlertManager.self*/
            
            alertManagerCompletion = completion
            
            if buttonNames == nil{
                alertView.addButtonWithTitle("Okay")
            }else{
                for (index,name) in enumerate(buttonNames!){
                    alertView.addButtonWithTitle(name)
                }
            }
            alertView.show();
        }
    }
    
    //custom alert function
    class func showAlert(viewController: UIViewController?,title: String? = nil, message: String? = nil, buttonNames: Array<String>? = nil, completion: ((index: Int) -> Void)? = nil){
        AlertManager(viewController: viewController, title: title, message: message, buttonNames: buttonNames, completion: completion)
    }
    
    class func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertManagerCompletion != nil{
            alertManagerCompletion!(index: buttonIndex)
        }
    }
    
    //check if iOS version >= 8
    class func isIOS8()->Bool{
        var result: Bool = false;
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            result = true;
        default:
            result = false;
        }
        return result
    }
    
}
