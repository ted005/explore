//
//  TWNodeSearchTableViewController.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/23.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class TWNodeSearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate{
    
    var searchController: UISearchController?
    
    var nodes: [TWNode] = []
    
    var filteredNodes: [TWNode] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "seachCell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //search
        searchController = UISearchController(searchResultsController: nil)
        self.searchController!.searchResultsUpdater = self
        self.navigationItem.titleView = searchController?.searchBar
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.barStyle = UIBarStyle.Default
        self.searchController?.hidesNavigationBarDuringPresentation = false
        
        self.searchController?.searchBar.delegate = self
    
        //load all nodes
        Alamofire.request(.GET, "https://www.v2ex.com/api/nodes/all.json")
            .responseJSON { (req, res, result)in
                if(result.isFailure) {
                    NSLog("Fail to load data.")
                }
                else {
                    let json = JSON(result.value!)
                    for subJson in json {
                        let node: TWNode = TWNode()
                        
                        node.title = subJson.1["title"].stringValue
                        node.name = subJson.1["name"].stringValue
                        node.header = subJson.1["header"].stringValue
                        node.topics = subJson.1["topics"].intValue
                        node.url = subJson.1["url"].stringValue
                        
                        self.nodes.append(node)
                    }
                    self.filteredNodes = self.nodes
                    
                    //dont show all nodes
//                    self.tableView.reloadData()
                }
        }
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        filteredNodes.removeAll(keepCapacity: true)
        
        let searchText = searchController.searchBar.text
        
        for node in nodes {
            if (node.title?.lowercaseString.rangeOfString(searchText!.lowercaseString) != nil) {
                filteredNodes.append(node)
            }
        }
        tableView.reloadData()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNodes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) 
        
        cell.textLabel?.text = filteredNodes[indexPath.row].title
        cell.detailTextLabel?.text = filteredNodes[indexPath.row].header
        
        return cell
    }


    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //placeholder
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        //placeholder
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //wrong, will trigger receiver has no segue with identifier '***' error
//        let destVC = TWExplorePostsTableViewController()
        
        //init vc with storyboard, it has segue configured
        let destVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("topicsInNodeVC") as! TWExplorePostsTableViewController
        destVC.nodeName = filteredNodes[indexPath.row].name!
        destVC.nodeNameForTitle = filteredNodes[indexPath.row].title!
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    //fix select back to Explore showing black screen
    override func viewWillDisappear(animated: Bool) {
        NSLog("will dispappear......")
        super.viewWillDisappear(true)
        self.searchController?.active = false
    }

}
