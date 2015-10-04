//
//  TWSettingsTableViewController.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/12.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit
import MessageUI

class TWSettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate{
    
    @IBAction func standOnTheShouldersOfGiants(sender: UIButton) {
        NSLog("Stand on the shoulds of giants.")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true

        //license label
        let standOnTheGiants = UILabel(frame: CGRectMake(0, 400, tableView.bounds.width, 50))
        standOnTheGiants.text = "站在巨人的肩膀上"
        standOnTheGiants.textAlignment = .Center
        standOnTheGiants.textColor = UIColor.lightGrayColor()
        
        //double tap
        standOnTheGiants.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("showLicences"))
        tapGesture.numberOfTapsRequired = 2
        
        standOnTheGiants.addGestureRecognizer(tapGesture)
        
        tableView.addSubview(standOnTheGiants)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        NSLog("Selecting \(indexPath.section)->\(indexPath.row)......")
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {//contact us
            displayComposerSheet()
        }
        else if row == 0 {//qna
            
        }
        else if row == 1 {//rate us
            
        }
        else if row == 2{//homepage
            let url = NSURL(string: "https://ted005.github.io")
            UIApplication.sharedApplication().openURL(url!)
        }
        
        //clear selection
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func displayComposerSheet(){
        let canSendEmail = MFMailComposeViewController.canSendMail()
        
        if canSendEmail {
            let mailVC = MFMailComposeViewController()
        
            mailVC.mailComposeDelegate = self
    
            mailVC.setSubject("问题反馈")
            mailVC.setToRecipients(["witwiky@me.com"])
            mailVC.setMessageBody("你好，我现在遇到了一些问题：", isHTML: true)
            
            self.presentViewController(mailVC, animated: true, completion: nil)
        }
        else {
            //Alert
            
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch (result.rawValue) {
        case MFMailComposeResultSent.rawValue:
            dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultCancelled.rawValue:
            dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultFailed.rawValue:
            //alert
            dismissViewControllerAnimated(true, completion: nil)
        case MFMailComposeResultSaved.rawValue:
            dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        NSLog("Showing licenses......")
    }
    
    func showLicences() {
        self.performSegueWithIdentifier("showLicenses", sender: nil)
    }
    

}
