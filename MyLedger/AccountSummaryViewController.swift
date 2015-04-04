//
//  AccountSummaryViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 4/4/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import CoreData

class AccountSummaryViewController: UIViewController {
    
    @IBOutlet var webview: UIWebView!
    
    var accounttype_id: Int?
    var startDate: NSDate?
    var endDate: NSDate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webview.scrollView.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = "Summary"
        
        if startDate == nil{
            
        }

        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
        let expression: NSExpressionDescription = NSExpressionDescription()
        expression.name = "sumOfAmmount"
        //expression.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        expression.expression = NSExpression(forKeyPath: "@sum.amount")
        expression.expressionResultType = NSAttributeType.DecimalAttributeType
        
        let result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: nil, andSorter: nil, managedObjectContext: moc, limit: nil, expressions: [expression])
        
        println(result)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
