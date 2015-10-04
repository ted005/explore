//
//  TWDetailTableViewController.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/13.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import MJRefresh

let detailCellReuseidentifier = "TWDetailCell"

class TWDetailTableViewController: UITableViewController{

    var mainPost: PostItem?
    
    var replies: [PostItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = mainPost?.postTitle
        
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "TWDetailTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: detailCellReuseidentifier)
        
        let lzNib = UINib(nibName: "TWLZTableViewCell", bundle: nil)
        tableView.registerNib(lzNib, forCellReuseIdentifier: "lzCell")
        
//        //pull to refresh
//        let refreshCtrl = UIRefreshControl()
//        refreshCtrl.addTarget(self, action:"refreshData", forControlEvents: UIControlEvents.ValueChanged)
//        self.refreshControl = refreshCtrl
//        
//        //pull up to load more data
//        self.tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
        
        
        Alamofire.request(.GET, "https://www.v2ex.com/api/topics/show.json?id=" + String(self.mainPost!.postId!))
        .responseJSON { (req, res, json, error)in
            if(error != nil) {
                NSLog("Fail to load LZ data.")
            }
            else {
                let json = JSON(json!)
                for (index: String, subJson: JSON) in json {
                    let content = subJson["content"].stringValue
                    let created = subJson["created"].doubleValue
                    
                    self.mainPost?.postFullText = content
                    self.mainPost?.time = String(stringInterpolationSegment: created)
                }
                
                self.tableView.reloadData()
                
            }
        }
        
        
        //Http request
        Alamofire.request(.GET, "https://www.v2ex.com/api/replies/show.json?topic_id=" + String(self.mainPost!.postId!))
            .responseJSON { (req, res, json, error)in
                if(error != nil) {
                    NSLog("Fail to load data.")
                }
                else {
                    NSLog("Success!")
                    let json = JSON(json!)
                    for (index: String, subJson: JSON) in json {
                        let reply: PostItem = self.constructPostItem(subJson)
                        self.replies.append(reply)
                    }
                    
                    self.tableView.reloadData()
                
                }
        }
        
        
    }
    
    func constructPostItem(json: JSON) -> PostItem {
    
        let content = json["content"].stringValue
        let username = json["member"]["username"].stringValue
        
        let url: String = "http:" + json["member"]["avatar_normal"].stringValue
        let postItem = PostItem(userName: username, title: content, avatar: NSURL(string: url)!, id: json["id"].stringValue, fullText: content)
        
        return postItem
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if section == 0 {//LZ cell
            return 1
        }
        else {//reply cells
            return self.replies.count
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        }
        else {
            return 100
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("lzCell", forIndexPath: indexPath) as! TWLZTableViewCell
            
            cell.title.text = mainPost!.postTitle
            cell.userName.text = mainPost!.userName
            cell.avatar.kf_setImageWithURL(mainPost!.userAvatar!)
            cell.content.text = mainPost?.postFullText
            cell.time.text = mainPost?.time
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(detailCellReuseidentifier, forIndexPath: indexPath) as! TWDetailTableViewCell
            
            //fix LZ table bug when user is not LZ
            cell.userIsHost.hidden = true
            
            cell.userName.text = replies[indexPath.row].userName
            cell.postText.text = replies[indexPath.row].postFullText
            cell.userAvatar.kf_setImageWithURL(replies[indexPath.row].userAvatar!)
            
            //LZ label hidden or not
            if cell.userName.text == mainPost?.userName {
                cell.userIsHost.hidden = false
            }
            
            return cell
        }
        
    }

}
