//
//  TWThemesPostsTableViewController.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/16.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit
import Alamofire

class TWThemesPostsTableViewController: UITableViewController, MBProgressHUDDelegate {

    var postItems: [PostItem] = []
    
    let urlPrefix = "http://www.v2ex.com/?tab="
    
    var theme = ""
    
    var hud: MBProgressHUD?
    
    let themesDic: [String: String] = ["tech": "技术", "creative": "创意", "play": "好玩", "apple": "Apple", "jobs": "酷工作", "deals": "交易", "city": "城市", "qna": "问与答", "r2": "R2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        
        self.navigationItem.title = themesDic[theme]
        
        let nib = UINib(nibName: "TWTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.rowHeight = 100
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //hud
        hud = MBProgressHUD(view: self.tableView)
        hud?.delegate = self
        self.tableView.insertSubview(hud!, atIndex: 0)
        hud?.show(true)
        
        //pull to refresh
        let refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action:"pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshCtrl
        
        //load and parse html
        parseHtml(theme)
    

    }
    
    func pullToRefresh() -> Void {
        println("Refreshing......")
        
        parseHtml(theme)
        
    }

    
    func parseHtml(theme: String) -> Void {
        let url = urlPrefix + theme
        
        Alamofire.request(.GET, url)
            .responseString { _, _, string, error in
                
                if(error != nil) {
                    NSLog("Fail to load data.")
                    self.refreshControl?.endRefreshing()
                    self.hud?.hide(true)
                }
                else {
                    self.postItems.removeAll(keepCapacity: true)
                    
                    let data = string?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                    
                    let doc = TFHpple(HTMLData: data)
                    let topicNodes = doc.searchWithXPathQuery("//div[@class='cell item']")
                    
                    NSLog("\(topicNodes.count)")
                    
                    for topic in topicNodes {
                        //construct model
                        var post = PostItem()
                        
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
                        
                        self.postItems.append(post)
                    }
                    
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                    
                    //update refresh control state
                    self.refreshControl?.endRefreshing()
                    
                    //update hude state
                    self.hud?.hide(true)
                }
            }

    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! TWTableViewCell
        
        cell.userName.text = postItems[indexPath.row].userName
        cell.userPost.text = postItems[indexPath.row].postTitle
        cell.userAvatar.kf_setImageWithURL(postItems[indexPath.row].userAvatar!)
        
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showDetailFromThemePost", sender: postItems[indexPath.row])
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let mainPost = sender as! PostItem
        let destinationVC = segue.destinationViewController as! TWDetailTableViewController
        destinationVC.mainPost = mainPost
        
    }

    
    func hudWasHidden(hud: MBProgressHUD!) {
        hud.removeFromSuperview()
    }

}
