//
//  ACTypeAddViewController.swift
//  MyLedger
//
//  Created by Moin Uddin on 12/1/14.
//  Copyright (c) 2014 Moin Uddin. All rights reserved.
//

import UIKit

class ACTypeAddViewController: UIViewController {

    @IBOutlet var acTypeName: UITextField!
    @IBOutlet var acTypeLabel: UILabel!
    
    var acTypeId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add Account Type"
        
        // adding tap gesture to acTypeLabel
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onLableTap:")
        tapGesture.numberOfTapsRequired = 1
        self.acTypeLabel.addGestureRecognizer(tapGesture)
        self.acTypeLabel.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StatusBar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func onLableTap(recognizer: UITapGestureRecognizer){
        let actionSheet: UIActionSheet = UIActionSheet(title: "", delegate: nil, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        //self.presentViewController(actionSheet, animated: true, completion: nil)
        actionSheet.showInView(self.view)
    }
    
    @IBAction func onSubmitTap(sender: UIButton) {
        if let actypeid = self.acTypeId{
            if acTypeName.text.isEmpty{
                AlertManager.showAlert(self, title: "Warning", message: "Please enter account type name", buttonNames: nil, completion: nil)
            }else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }else{
            AlertManager.showAlert(self, title: "Warning", message: "Please select account type", buttonNames: nil, completion: nil)
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
