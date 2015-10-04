//
//  TWTableViewCell.swift
//  V2EX Explorer
//
//  Created by Robbie on 15/8/10.
//  Copyright (c) 2015年 Ted Wei. All rights reserved.
//

import UIKit

class TWTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userPost: UILabel!
    
    @IBOutlet weak var userAvatar: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let caLayer = self.userAvatar.layer
        caLayer.cornerRadius = 24;
        self.userAvatar.clipsToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
