//
//  SideBar.swift
//  BlurrySideBar
//
//  Created by Moin Uddin on 11/13/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

@objc protocol SideBarDelegate{
    func sideBarDidSelectRowAtIndex(index: Int, dict: NSDictionary)
    optional func sideBarWillClose()
    optional func sideBarWillOpen()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
    
    let barWidth: CGFloat = 250.0
    let sideBarTableViewTopInset: CGFloat = 64.0
    let sideBarContainerView: UIView = UIView()
    let sideBarTableViewController: SideBarTableViewController = SideBarTableViewController()
    let originView: UIView!
    var animator: UIDynamicAnimator!
    var delegate: SideBarDelegate?
    var isSideBarOpen: Bool = false
    var shouldCloseOnSelection = false
    var shouldDeselectSelectedRow = false
    var shouldHandleSwipe: Bool = true
    var navIcon: String?{
        didSet{
            self.setupNavButton()
        }
    }
    var navTitle: String?{
        didSet{
            self.setupNavTitle()
        }
    }
    
    var navTitleView: UILabel?
    
    var tag: Int?{
        didSet{
            
        }
    }
    
    var menuItems: NSMutableArray?{
        didSet{
            self.sideBarTableViewController.tableData = self.menuItems!
            self.sideBarTableViewController.tableView.reloadData()
        }
    }
    
    override init() {
        super.init()
    }
    
    init(sourceView: UIView, menuItems: NSMutableArray) {
        super.init()
        originView = sourceView
        self.menuItems = menuItems
        
        setupSideBar()
        
        animator = UIDynamicAnimator(referenceView: originView)
        
        let showGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        showGestureRecognizer.direction = .Right
        originView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        originView.addGestureRecognizer(hideGestureRecognizer)
    }
    
    func setupSideBar(){
        sideBarContainerView.frame = CGRectMake(-barWidth-1, originView.frame.origin.y, barWidth, originView.frame.size.height)
        sideBarContainerView.backgroundColor = UIColor.clearColor()
        sideBarContainerView.clipsToBounds = false
        
        originView.addSubview(sideBarContainerView)
        
        /*if self.isIOS8(){
            let blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
            blurView.frame = sideBarContainerView.bounds
            sideBarContainerView.addSubview(blurView)
        }else{*/
            sideBarContainerView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        //}
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
        sideBarTableViewController.tableView.scrollsToTop = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        if self.menuItems != nil{
            self.sideBarTableViewController.tableData = self.menuItems!
        }
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
    }
    
    func setupNavButton(){
        let leftnavButton: UIImageView = UIImageView(image: UIImage(named: self.navIcon!))
        leftnavButton.frame = CGRectMake(15, 27.0, 30.0, 30.0)
        leftnavButton.contentMode = .ScaleAspectFit
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onLefnavTap:")
        tapGesture.numberOfTapsRequired = 1
        leftnavButton.userInteractionEnabled = true
        leftnavButton.addGestureRecognizer(tapGesture)
        sideBarContainerView.addSubview(leftnavButton)
    }
    
    func setupNavTitle(){
        if navTitleView == nil{
            navTitleView = UILabel(frame: CGRectMake(70, 27, barWidth - 80, 30))
            navTitleView?.font = UIFont(name: navTitleView!.font.fontName, size: 22)
            navTitleView?.textColor = UIColor.whiteColor()
            sideBarContainerView.addSubview(navTitleView!)
        }
        if self.navTitle != nil{
            navTitleView?.text = self.navTitle!
        }
    }
    
    func handleSwipe(recognizer: UISwipeGestureRecognizer){
        if self.shouldHandleSwipe == false{
            return
        }
        
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left{
            showSideBar(false)
            delegate?.sideBarWillClose?()
        }else if recognizer.direction == UISwipeGestureRecognizerDirection.Right{
            showSideBar(true)
            delegate?.sideBarWillOpen?()
        }
    }
    
    func showSideBar(shouldOpen: Bool){
        animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        
        let gravityX: CGFloat = shouldOpen ? 2.5 : -2.5
        let magnitude: CGFloat = shouldOpen ? 20 : -20
        let boundaryX: CGFloat = shouldOpen ? barWidth : -barWidth - 1
        
        let gravityBehavior: UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection = CGVector(dx: gravityX, dy: 0)
        animator.addBehavior(gravityBehavior)
        
        let collisionBehavior: UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        collisionBehavior.addBoundaryWithIdentifier("sideBarBoundary", fromPoint: CGPointMake(boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
        animator.addBehavior(collisionBehavior)
        
        let pushBehavior: UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        let sideBarBehavior: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        sideBarBehavior.elasticity = 0.3
        animator.addBehavior(sideBarBehavior)
        
    }
    
    func sideBarControlDidSelectRow(indexPath: NSIndexPath) {
        if shouldCloseOnSelection{
            showSideBar(!isSideBarOpen)
        }
        delegate?.sideBarDidSelectRowAtIndex(indexPath.row, dict: self.menuItems?.objectAtIndex(indexPath.row) as NSDictionary)
        if shouldDeselectSelectedRow{
            sideBarTableViewController.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func removeFromSuperview(){
        sideBarContainerView.removeFromSuperview()
    }
    
    func onLefnavTap(gesture: UITapGestureRecognizer){
        if self.isSideBarOpen{
            self.showSideBar(false)
        }else{
            self.showSideBar(true)
        }
    }
    
    func reloadSidebar(){
        if let newTitle: String = navTitle{
            navTitle = newTitle
        }
        self.sideBarTableViewController.tableView.reloadData()
    }
    
    func isIOS8()->Bool{
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
