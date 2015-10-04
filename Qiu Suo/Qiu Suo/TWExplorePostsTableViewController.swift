//
//  TWExplorePostsTableViewController.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/19.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import MJRefresh

class TWExplorePostsTableViewController: UITableViewController, MBProgressHUDDelegate {

    var nextPage = 2
    
    var postItems: [PostItem] = []
    
    var nodeName = ""
    
    var nodeNameForTitle = ""
    
    let urlPrefix = "https://www.v2ex.com/go/"

    var hud: MBProgressHUD?
    
    var footer: MJRefreshAutoNormalFooter?
    
    var topicsNumber = Int.max
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.title = nodeNameForTitle

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //hud
        hud = MBProgressHUD(view: self.tableView)
        hud?.delegate = self
        self.tableView.insertSubview(hud!, atIndex: 0)
        hud?.show(true)
        
        tableView.registerNib(UINib(nibName: "TWTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.rowHeight = 100
        
        //pull to refresh
        let refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action:"pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshCtrl
        
        //load more
        footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: Selector("loadMore"))
        footer!.automaticallyRefresh = false
        
        self.tableView.tableFooterView = footer
    
        
        //retrieve topicsNumber
        retrieveTopicsNumber(nodeName)
        
        parseHtml(nodeName)
    
    }
    
    func retrieveTopicsNumber(nodeName: String) {
        let url = "https://www.v2ex.com/api/nodes/show.json?name=" + nodeName
        Alamofire.request(.GET, url)
            .responseJSON { _, _, result in
                
                if(result.isFailure) {
                    NSLog("Fail retrieve topics number.")
                }
                else {
                    let json = JSON(result.value!)
                    self.topicsNumber = json["topics"].intValue
                }
        }
    }
    
    func pullToRefresh() -> Void {
        print("Refreshing......")
        
        parseHtml(nodeName)
        
    }
    
    func loadMore() {
        
        //check whether reach the max topicsNumber
        if postItems.count == topicsNumber {
            self.footer!.noticeNoMoreData()
            return
        }
        
        let url = urlPrefix + nodeName + "?p=" + String(nextPage++)
        Alamofire.request(.GET, url)
            .responseString { _, _, result in
                
                if(result.isFailure) {
                    NSLog("Fail to load more data.")
                    
                    self.footer!.endRefreshing()
                    self.nextPage--
                }
                else {
                    let data = result.value?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                    
                    let doc = TFHpple(HTMLData: data)
                    //        let topicNodes = doc.searchWithXPathQuery("//div[@id='TopicsNode']/*")
                    let topicNodes = doc.searchWithXPathQuery("/html/body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[2]/div[@id='TopicsNode']/*")
                    
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
                        
                        self.postItems.append(post)
                    }
                    
                    self.tableView.reloadData()
                    
                    self.footer!.endRefreshing()
                }
        }
    }
    
    func parseHtml(nodeName: String) -> Void {
        
            let url = urlPrefix + nodeName

            Alamofire.request(.GET, url)
                .responseString { _, _, result in
                    
                    if(result.isFailure) {
                        NSLog("Fail to load data.")
                        self.refreshControl?.endRefreshing()
                        self.hud?.hide(true)
                    }
                    else {
                        
                        self.postItems.removeAll(keepCapacity: true)
                        
                        let data = result.value?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                        
                        let doc = TFHpple(HTMLData: data)
                        //        let topicNodes = doc.searchWithXPathQuery("//div[@id='TopicsNode']/*")
                        let topicNodes = doc.searchWithXPathQuery("/html/body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[2]/div[@id='TopicsNode']/*")
                        
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
                            
                            self.postItems.append(post)
                        }
                        
                        self.tableView.reloadData()
                        if topicNodes.count == 0 {
                            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                        }
                        else {
                            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                        }
                        
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! TWTableViewCell

        // Configure the cell...
        let post = postItems[indexPath.row]
//        NSLog("\(post.userName) .... \(post.postTitle)")
        cell.userName.text = post.userName
        cell.userPost.text = post.postTitle
        
        let avatarUrl = post.userAvatar!
        var s = avatarUrl.URLString
        s.insert("s", atIndex: s.startIndex.advancedBy(4))
        
        cell.userAvatar.kf_setImageWithURL(NSURL(string: s)!)

        return cell
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let sender = postItems[indexPath.row]
        self.performSegueWithIdentifier("showExplorePostDetail", sender: sender)
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        let destVC = segue.destinationViewController as! TWDetailTableViewController
        destVC.mainPost = sender as? PostItem
    }
    
    func hudWasHidden(hud: MBProgressHUD!) {
        hud.removeFromSuperview()
    }
    

}
