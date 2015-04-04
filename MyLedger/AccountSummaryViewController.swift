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
    let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webview.scrollView.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = "Summary"
        
        if startDate == nil{
            startDate = DVDateFormatter.getDate(date: nil, years: nil, months: nil, days: -7, hours: 0, minutes: 0, seconds: 0)
        }else{
            startDate = DVDateFormatter.getDate(date: startDate!, years: nil, months: nil, days: nil, hours: 0, minutes: 0, seconds: 0)
        }
        if endDate == nil{
            endDate = DVDateFormatter.getDate(date: nil, years: nil, months: nil, days: nil, hours: 23, minutes: 59, seconds: 59)
        }else{
            endDate = DVDateFormatter.getDate(date: endDate!, years: nil, months: nil, days: nil, hours: 23, minutes: 59, seconds: 59)
        }
        
        println(startDate)
        println(endDate)
        
        self.createSummaryTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - getPreviousCredit
    func getPreviousCredit() -> Double{
        var credit: Double = 0.0
        var debit: Double = 0.0
        let userID: Int = (prefs.objectForKey("userID") as NSString).integerValue
        
        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
        
        var expression: NSExpressionDescription = NSExpressionDescription()
        expression.name = "sumOfAmmount"
        //expression.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        expression.expression = NSExpression(forKeyPath: "@sum.amount")
        expression.expressionResultType = NSAttributeType.DecimalAttributeType
        
        var predicate: NSPredicate = NSPredicate(format: "(modified < %@) AND accounttype.type = 1 AND (user_id = %d) AND isdeleted = FALSE", startDate!, userID)!
        var result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: nil, expressions: [expression])
        
        if result.count > 0{
            let resultdict: NSDictionary = result.lastObject as NSDictionary
            credit = resultdict.objectForKey("sumOfAmmount") as Double
        }
        
        //println(credit)
        
        expression = NSExpressionDescription()
        expression.name = "sumOfAmmount"
        //expression.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        expression.expression = NSExpression(forKeyPath: "@sum.amount")
        expression.expressionResultType = NSAttributeType.DecimalAttributeType
        
        predicate = NSPredicate(format: "(modified < %@) AND accounttype.type = 2 AND (user_id = %d) AND isdeleted = FALSE", startDate!, userID)!
        result = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: nil, expressions: [expression])
        
        if result.count > 0{
            let resultdict: NSDictionary = result.lastObject as NSDictionary
            debit = resultdict.objectForKey("sumOfAmmount") as Double
        }
        
        //println(debit)
        
        return credit - debit
    }
    
    // MARK: - createSummaryTable
    func createSummaryTable(){
        let prevTotal: Double = self.getPreviousCredit()
        println(prevTotal)
        
        let userID: Int = (prefs.objectForKey("userID") as NSString).integerValue
        
        let moc: NSManagedObjectContext = CoreDataHelper.managedObjectContext(dataBaseFilename: nil)
        
        var predicate: NSPredicate = NSPredicate(format: "(modified >= %@) AND (modified <= %@) AND (user_id = %d) AND isdeleted = FALSE", startDate!, endDate!,userID)!
        
        if accounttype_id != nil{
            predicate = NSPredicate(format: "(modified >= %@) AND (modified <= %@) AND (user_id = %d) AND (accounttype_id = %d) AND isdeleted = FALSE", startDate!, endDate!,userID, accounttype_id!)!
        }
        
        var result: NSArray = CoreDataHelper.fetchEntities(NSStringFromClass(Accounts), withPredicate: predicate, andSorter: nil, managedObjectContext: moc, limit: nil, expressions: nil)
        
        var balance: Double = 0,
        income: Double = 0,
        expense: Double = 0,
        table: String = "<table border=\"1\" cellspacing=\"0\"><tr style = \"height:40px;\"><th>Date</th><th>Accounttype</th><th>Description</th><th>Income</th><th>Expense</th><th>Balance</th></tr>"
        
        table += "<tr ><td colspan=\"5\" style=\"padding:5px\">Opening Balance</td><td>\(prevTotal)</td></tr>"
        balance = prevTotal
        
        if result.count > 0{
            for item in result{
                let account: Accounts = item as Accounts
                table += "<tr>"
                table += "<td>\(DVDateFormatter.getTimeString(account.modified, format: nil))</td>"
                table += "<td>\(account.accounttype.name)</td>";
                table += "<td>\(account.details)</td>"
                if account.accounttype.type == 1{
                    balance += Double(account.amount)
                    income += Double(account.amount)
                    table += "<td style=\"text-align:right\">\(Double(account.amount))</td>"
                    table += "<td style=\"text-align:right\">0</td>"
                }else if account.accounttype.type == 2{
                    balance -= Double(account.amount)
                    expense += Double(account.amount)
                    table += "<td style=\"text-align:right\">0</td>"
                    table += "<td style=\"text-align:right\">\(Double(account.amount))</td>"
                }
                table += "<td style=\"text-align:right\">\(Double(balance))</td>"
                table += "</tr>"
            }
        }
        table += "<tr style = \"height:40px;\"><td colspan=\"3\" style=\"text-align:right;padding-right: 10px;\">Total</td><td style=\"text-align:right\">\(income)</td><td style=\"text-align:right\">\(expense)</td><td style=\"text-align:right\">\(balance)</td></tr>"
        table += "</table>"
        
        var html: String = "<!doctype html><html><head><meta charset=\"UTF-8\"><title>Summary</title><style type=\"text/css\">table tr:nth-child(even){background:#f9f9f9}</style></head><body>" + table + "</body></html>"
        
        self.webview.loadHTMLString(table, baseURL: nil)
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
