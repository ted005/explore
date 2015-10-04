//
//  TWLZTableViewCell.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/15.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit

class TWLZTableViewCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var content: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let caLayer = self.avatar.layer
        caLayer.cornerRadius = 24;
        self.avatar.clipsToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
