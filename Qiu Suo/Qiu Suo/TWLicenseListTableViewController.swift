//
//  TWLicenseListTableViewController.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/14.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit

class TWLicenseListTableViewController: UITableViewController {
    
    let showAlamofireLicense = "showAlamofireLicense"
    let showKingfisherLicense = "showKingfisherLicense"
    let showMJRefreshLicense = "showMJRefreshLicense"
    let showSwiftyJSONLicense = "showSwiftyJSONLicense"
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
//        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //MARK: delegate methods
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        let destinationVC = segue.destinationViewController as! TWLicenseDetailViewController
        
        var row = 0

        //licenseLabel is nil
        // let licenseLabel: UILabel = destinationVC.licenseLabel
        
        if let identifier = segue.identifier {
            switch identifier {
                case showAlamofireLicense:
                    destinationVC.licenseName = "Alamofire"
                    row = 0
                    break
                case showKingfisherLicense:
                    destinationVC.licenseName = "Kingfisher"
                    row = 0
                    break
                case showMJRefreshLicense:
                    destinationVC.licenseName = "MJRefresh"
                    row = 0
                    break
                case showSwiftyJSONLicense:
                    destinationVC.licenseName = "SwiftyJSON"
                    row = 0
                    break
                default:
                    destinationVC.licenseName = "Alamofire"
            }
        }
        
        tableView.deselectRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0), animated: true)
        
    }


}
