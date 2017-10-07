//
//  WatsonChatCell.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 04/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit

class WatsonChatCell: UITableViewCell {
    
    
    @IBOutlet weak var labelText: UILabel!
    
    @IBOutlet weak var labelViewHolder: UIView!
    
    @IBOutlet weak var rightChat: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        labelViewHolder.layer.cornerRadius = 10
//        rightChat.tintColor = UIColor(red: 0.678 , green: 0.839, blue: 1, alpha: 1)
        rightChat.tintColor = labelViewHolder.backgroundColor
    }
    
    
}

