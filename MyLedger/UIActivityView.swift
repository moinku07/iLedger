//
//  UIActivityView.swift
//  MyLedger
//
//  Created by Moin Uddin on 11/25/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import Foundation
import UIKit

class UICustomActivityView {
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    /*
    Show customized activity indicator,
    actually add activity indicator to passing view
    
    @param uiView - add activity indicator to this view
    */
    func showActivityIndicator(uiView: UIView, style: UIActivityIndicatorViewStyle? = nil, shouldHaveContainer: Bool? = true, centerPoint: CGPoint? = nil) {
        var newCenter: CGPoint = uiView.center
        if centerPoint != nil{
            newCenter = centerPoint!
        }
        container.frame = uiView.frame
        container.center = newCenter
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = newCenter
        loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0)
        var activitStyle: UIActivityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        
        if style != nil{
            activitStyle = style!
        }
        //println(activitStyle.rawValue)
        activityIndicator.activityIndicatorViewStyle = activitStyle
        
        if shouldHaveContainer == true{
            activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2, loadingView.frame.size.height / 2);
            loadingView.addSubview(activityIndicator)
            container.addSubview(loadingView)
        }else{
            activityIndicator.center = container.center
            container.addSubview(activityIndicator)
        }
        
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    /*
    Hide activity indicator
    Actually remove activity indicator from its super view
    
    @param uiView - remove activity indicator from this view
    */
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}