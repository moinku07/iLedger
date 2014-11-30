//
//  AlertManager.swift
//  MyLedger
//
//  Created by Moin Uddin on 11/30/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

class AlertManager: NSObject {
    //custom alert function
    class func showAlert(viewController: UIViewController,alertTitle: String? = nil, alertMessage: String? = nil, okayButtonTitle: String? = nil){
        let alertTitle1 = (alertTitle == nil || alertTitle!.isEmpty) ? "Alert" : alertTitle!;
        let alertMsg = (alertMessage == nil || alertMessage!.isEmpty) ? alertTitle1 : alertMessage!;
        let okayBtnTitle = (okayButtonTitle == nil || okayButtonTitle!.isEmpty) ? "Okay" : okayButtonTitle!;
        if(AlertManager.isIOS8() == true){
            let alertController: UIAlertController = UIAlertController(title: alertTitle1, message: alertMsg, preferredStyle: UIAlertControllerStyle.Alert);
            alertController.addAction(UIAlertAction(title: okayBtnTitle, style: UIAlertActionStyle.Default, handler: nil));
            viewController.presentViewController(alertController, animated: true, completion: nil)
        }else{
            let alertView: UIAlertView = UIAlertView(title: alertTitle1, message: alertMsg, delegate: nil, cancelButtonTitle: okayBtnTitle);
            alertView.show();
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
