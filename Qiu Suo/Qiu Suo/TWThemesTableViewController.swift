//
//  TWThemesTableViewController.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/16.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit

class TWThemesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationVC = segue.destinationViewController as! TWThemesPostsTableViewController
        
        if let identifier = segue.identifier {
            destinationVC.theme = identifier
        }
        
        
    }
    

}
