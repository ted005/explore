//
//  ComprehensiveTableViewController.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/15.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import MBProgressHUD
import MJRefresh

let cellReuseIdentifier = "TWCell"

class ComprehensiveTableViewController: UITableViewController, MBProgressHUDDelegate {
    
    var segmentIndex = 0
    
    var latestPostItems = [PostItem]()
    var hotPostItems = [PostItem]()
    var recentPostItems = [PostItem]()
    
    
    var tableView1: UITableView?
    var tableView2: UITableView?
    var tableView3: UITableView?
    
    var hud: MBProgressHUD?
    
    @IBAction func toggleMenu(sender: UISegmentedControl) {
        
        let index = sender.selectedSegmentIndex
        segmentIndex = index
        
        //resolve error: 
        //Attempting to change the refresh control while it is not idle is strongly discouraged and probably won't work properly.
        let refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action:"pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshCtrl
        
        if index == 0 {
            self.tableView = tableView1
        }
        else if index == 1{
            self.tableView = tableView2
        }
        else if index == 2{
            self.tableView = tableView3
        }
        
        self.tableView.reloadData()
        
        hud?.hide(true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //nearest ancestor navigaionVC
        self.navigationController?.navigationBar.translucent = false
        
        self.clearsSelectionOnViewWillAppear = true
        
        //pull to refresh
        let refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action:"pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshCtrl
        
        //configure separate tableview
        tableView1 = UITableView(frame: self.tableView.frame, style: UITableViewStyle.Plain)
        tableView1!.dataSource = self
        tableView1!.delegate = self
        tableView1!.rowHeight = 100
        tableView1!.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView1!.registerNib(UINib(nibName: "TWTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
       
        tableView2 = UITableView(frame: self.tableView.frame, style: UITableViewStyle.Plain)
        tableView2!.dataSource = self
        tableView2!.delegate = self
        tableView2!.rowHeight = 100
        tableView2!.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView2!.registerNib(UINib(nibName: "TWTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView3 = UITableView(frame: self.tableView.frame, style: UITableViewStyle.Plain)
        tableView3!.dataSource = self
        tableView3!.delegate = self
        tableView3!.rowHeight = 100
        tableView3!.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView3!.registerNib(UINib(nibName: "TWTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
     
        self.tableView = tableView1
        
        
        //hud
        hud = MBProgressHUD(view: self.tableView)
        hud?.delegate = self
        self.tableView.insertSubview(hud!, atIndex: 0)
        hud?.show(true)
        
        
        //latest
        Alamofire.request(.GET, "https://www.v2ex.com/api/topics/latest.json")
            .responseJSON { (req, res, result)in
                if(result.isFailure) {
                    NSLog("Fail to load data.")
                    //need to clear cause maybe the data is not integrate
//                    self.latestPostItems.removeAll(keepCapacity: true)
                    
                    self.hud?.hide(true)
                }
                else {
                    let json = JSON(result.value!)
                    for subJson in json {
                        let postItem: PostItem = self.constructPostItem(subJson.1)
                        
                        //
                        self.latestPostItems.append(postItem)
                        
                    }
                    
                    self.tableView1!.reloadData()
                    self.tableView1!.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                    
                    self.hud?.hide(true)
                }
        }
        
        //hot
        Alamofire.request(.GET, "https://www.v2ex.com/api/topics/hot.json")
            .responseJSON { (req, res, result)in
                if(result.isFailure) {
                    NSLog("Fail to load data.")
                    self.hud?.hide(true)
                }
                else {
                    let json = JSON(result.value!)
                    for subJson in json {
                        let postItem: PostItem = self.constructPostItem(subJson.1)
                        self.hotPostItems.append(postItem)
                    }
                    //no need to reload, cause toggle segment control will reload
                    self.tableView2!.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                }
        }
        
        //recent
        Alamofire.request(.GET, "https://www.v2ex.com/recent")
            .responseString { (req, res, result)in
                if(result.isFailure) {
                    NSLog("Fail to load data.")
                    self.hud?.hide(true)
                }
                else {
                    
                    self.parseHtmlString(result.value)
                    
                    //no need to reload, cause toggle segment control will reload
                    self.tableView3!.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                }
        }
        
        //recent
        //MARK: TODO
    }
    
    // MARK: Model
    func constructPostItem(json: JSON) -> PostItem {
        
        let title = json["title"].stringValue
        let username = json["member"]["username"].stringValue
        
        let url: String = "http:" + json["member"]["avatar_normal"].stringValue
        let postItem = PostItem(userName: username, title: title, avatar: NSURL(string: url)!, id: json["id"].stringValue, fullText: "")
        
        return postItem
    }
    
    func pullToRefresh() -> Void {
        print("Refreshing......")
        
        var url = ""
        
        switch (segmentIndex) {
        case 0:
            url = "https://www.v2ex.com/api/topics/latest.json"
            break;
        case 1:
            url = "https://www.v2ex.com/api/topics/hot.json"
            break;
        case 2:
            url = "https://www.v2ex.com/recent"
            break;
        default:
            break;
        }
        
        Alamofire.request(.GET, url)
            //for latest and hot tab
            .responseJSON { (req, res, result) in
                if(result.isFailure) {
                    NSLog("Fail to refresh data.")
                    self.refreshControl?.endRefreshing()
                    //no need to set line separator to none, cause keep current ones
                }
                else {
                    NSLog("Success!")
                    
                    //update postItem array according to current segmentIndex
                    if self.segmentIndex == 0 {
                        self.latestPostItems.removeAll(keepCapacity: true)
        
                        let json = JSON(result.value!)
                        for subJson in json {
                            let postItem: PostItem = self.constructPostItem(subJson.1)
        
                            self.latestPostItems.append(postItem)
                        }
                    }
                    else if self.segmentIndex == 1{
                        self.hotPostItems.removeAll(keepCapacity: true)
        
                        let json = JSON(result.value!)
                        for subJson in json {
                            let postItem: PostItem = self.constructPostItem(subJson.1)
        
                            self.hotPostItems.append(postItem)
                        }
                    }
        
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                    self.refreshControl?.endRefreshing()
                    
                }
            }
            //for recent tab
            .responseString{ (_, _, result) -> Void in
                if(result.isFailure) {
                    NSLog("Fail to refresh data.")
                    self.refreshControl?.endRefreshing()
                    //no need to set line separator to none, cause keep current ones
                }
                else {
                    NSLog("Success!")
                    if self.segmentIndex == 2 {
                        
                        self.recentPostItems.removeAll(keepCapacity: true)
                        self.parseHtmlString(result.value)
                        
                        self.tableView.reloadData()
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if segmentIndex == 0 {
                return latestPostItems.count
            }
            else if segmentIndex == 1{
                return hotPostItems.count
            }
            else if segmentIndex == 2 {
                return recentPostItems.count
            }
            else {
                return 0
            }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! TWTableViewCell
            
            if self.segmentIndex == 0 {
                cell.userName.text = latestPostItems[indexPath.row].userName
                cell.userPost.text = latestPostItems[indexPath.row].postTitle
                
                //use https to load avatar
                let avatarUrl = latestPostItems[indexPath.row].userAvatar!
                var s = avatarUrl.URLString
                s.insert("s", atIndex: s.startIndex.advancedBy(4))
                cell.userAvatar.kf_setImageWithURL(NSURL(string: s)!)
            }
            else if self.segmentIndex == 1 {
                cell.userName.text = hotPostItems[indexPath.row].userName
                cell.userPost.text = hotPostItems[indexPath.row].postTitle
                
                let avatarUrl = hotPostItems[indexPath.row].userAvatar!
                var s = avatarUrl.URLString
                s.insert("s", atIndex: s.startIndex.advancedBy(4))
                cell.userAvatar.kf_setImageWithURL(NSURL(string: s)!)
            }
            else if self.segmentIndex == 2 {
                cell.userName.text = recentPostItems[indexPath.row].userName
                cell.userPost.text = recentPostItems[indexPath.row].postTitle
                
                let avatarUrl = recentPostItems[indexPath.row].userAvatar!
                var s = avatarUrl.URLString
                s.insert("s", atIndex: s.startIndex.advancedBy(4))
                cell.userAvatar.kf_setImageWithURL(NSURL(string: s)!)
            }
            
            return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let sender: PostItem
        switch (segmentIndex) {
        case 0:
            sender = latestPostItems[indexPath.row]
            break;
        case 1:
            sender = hotPostItems[indexPath.row]
            break;
        case 2:
            sender = recentPostItems[indexPath.row]
            break;

        default:
            sender = latestPostItems[indexPath.row]
            break;
        }
        
        
        //1
        self.performSegueWithIdentifier("showDetailFromLHR", sender: sender)
        
        //clear selection when pop
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let mainPost = sender as! PostItem
        let destinationVC = segue.destinationViewController as! TWDetailTableViewController
        destinationVC.mainPost = mainPost
        
    }

    
    func hudWasHidden(hud: MBProgressHUD!) {
        hud.removeFromSuperview()
    }
    
    func parseHtmlString(string: String?) {
        let data = string?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let doc = TFHpple(HTMLData: data)
        let topicNodes = doc.searchWithXPathQuery("//div[@class='cell item']")
        
        NSLog("\(topicNodes.count)")
        
        for topic in topicNodes {
            //construct model
            let post = PostItem()
            
            //post title
            let itemTitleSpan: [AnyObject] = topic.searchWithXPathQuery("//span[@class='item_title']/a")
            var aUnderSpan = itemTitleSpan.first as! TFHppleElement
            let title = aUnderSpan.text()
            
            //post id
            let hrefVal = aUnderSpan.objectForKey("href")
            let range1 = (hrefVal as NSString) .rangeOfString("/t/")
            let range2 = (hrefVal as NSString) .rangeOfString("#")
            let idRange = NSRange(location: range1.length, length: range2.location - range1.location - range1.length)
            let id = (hrefVal as NSString) .substringWithRange(idRange)
            
            //user name
            let smallFadeSpan: [AnyObject] = topic.searchWithXPathQuery("//span[@class='small fade']/strong/a")
            aUnderSpan = smallFadeSpan.first as! TFHppleElement
            let userName = aUnderSpan.text()
            
            //user avatar
            let imgNode: [AnyObject] = topic.searchWithXPathQuery("//img[@class='avatar']")
            aUnderSpan = imgNode.first as! TFHppleElement
            let imgUrl = "http:" + aUnderSpan.objectForKey("src")
            
            post.postTitle = title
            post.userName = userName
            post.postId = id
            post.userAvatar = NSURL(string: imgUrl)
            // TO set more
            
            self.recentPostItems.append(post)
            
        }
    }

}
