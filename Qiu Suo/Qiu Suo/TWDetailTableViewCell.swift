//
//  TWDetailTableViewCell.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/13.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit

class TWDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userIsHost: UILabel!
    
    @IBOutlet weak var postText: UILabel!
    
    @IBOutlet weak var postTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let blue = self.userIsHost.backgroundColor
        self.userIsHost.backgroundColor = UIColor.whiteColor()
        self.userIsHost.textColor = blue
        
        self.userIsHost.layer.cornerRadius = 5
        self.userIsHost.layer.borderWidth = 1
        self.userIsHost.layer.borderColor = blue?.CGColor
        
        let caLayer = self.userAvatar.layer
        caLayer.cornerRadius = 12;
        self.userAvatar.clipsToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
