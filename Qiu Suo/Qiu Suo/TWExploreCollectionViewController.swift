//
//  TWExploreCollectionViewController.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/13.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit

class TWExploreCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var arr: [[[String: String]]] = []
    
    let titleArr: [String] = ["分享与探索", "V2EX", "iOS", "Geek", "游戏", "Apple", "生活", "Internet", "城市", "品牌"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        //init arr
        initArrAndDictionary()
        
        // Register cell classes
        let nib = UINib(nibName: "TWNodeCollectionViewCell", bundle: nil)
        self.collectionView!.registerNib(nib, forCellWithReuseIdentifier: "nodeCell")
        
        self.collectionView?.registerNib(UINib(nibName: "TWHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader")

        // Do any additional setup after loading the view.

        
        
        
    }
    
    func initArrAndDictionary() {
        let path = NSBundle.mainBundle().pathForResource("ExploreThemes", ofType: "plist")
        
        if let filePath = path {
            arr = NSArray(contentsOfFile: filePath) as! [[[String: String]]]
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 80, height: 60)
    }
    
    //header
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                withReuseIdentifier: "sectionHeader",
                forIndexPath: indexPath)
                as! TWHeaderCollectionReusableView
            
            headerView.title.text = titleArr[indexPath.section]
            return headerView
        default:
            return UICollectionReusableView()
            
        }
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showExplorePosts" {
            let destVC = segue.destinationViewController as! TWExplorePostsTableViewController
            let nodeName = (sender as! [String]).last
            let nodeNameForTitle = (sender as! [String]).first
            
            destVC.nodeName = nodeName!
            destVC.nodeNameForTitle = nodeNameForTitle!
        }
        
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return arr.count
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let arrItem = arr[section]
        return arrItem.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("nodeCell", forIndexPath: indexPath) as! TWNodeCollectionViewCell
        
        let arrItem = arr[indexPath.section]
        let dicInArrItem = arrItem[indexPath.row]
        
        for dicItem in dicInArrItem {
            cell.nodeName.text = dicItem.0
        }
        
        
//        cell.contentView.backgroundColor = UIColor.clearColor()
//        cell.contentView.layer.cornerRadius = 10
//        cell.contentView.layer.borderWidth = 3
//        cell.contentView.layer.borderColor = UIColor.greenColor().CGColor
        
        // Configure the cell
        
//        var label = cell.node
////        var label = UILabel(frame: CGRectMake(10, 10, cell.bounds.width-20, cell.bounds.height-20))
////        label.layer.cornerRadius = 15
//        label.layer.borderColor = UIColor.blackColor().CGColor
//        label.layer.backgroundColor = UIColor.blueColor().CGColor
//        label.layer.borderWidth = 3
//        label.backgroundColor = UIColor.clearColor()
//        label.text = String(self.nodeIds[indexPath.row])
//        label.textAlignment = NSTextAlignment.Center
//        label.numberOfLines = 1
//        label.textColor = UIColor.whiteColor()
//        cell.contentView.addSubview(label)
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let dicInArrItem = arr[indexPath.section][indexPath.row]
        
        var sender : [String] = []
        for dicItem in dicInArrItem {
            sender.append(dicItem.0)
            sender.append(dicItem.1)
        }
        self.performSegueWithIdentifier("showExplorePosts", sender: sender)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    

   

}
