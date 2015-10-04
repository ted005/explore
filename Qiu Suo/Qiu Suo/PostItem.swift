//
//  PostItem.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/10.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit

class PostItem: NSObject {
    var userName: String?
    var postTitle: String?
    var userAvatar: NSURL?
    var postId: String?
    var postFullText: String?
    var time: String?
    
    init(userName: String, title: String, avatar: NSURL, id: String, fullText: String){
        self.userName = userName
        self.postTitle = title
        self.userAvatar = avatar
        self.postId = id
        self.postFullText = fullText
    }
    
    override init(){
        super.init()
    }
    
    
    
}
