//
//  UserChatCell.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 04/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit

class UserChatCell: UITableViewCell {

    
    
    @IBOutlet weak var userBubbleHolder: UIView!
    @IBOutlet weak var userTextLabel: UILabel!
    
    @IBOutlet weak var leftChat: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        userBubbleHolder.layer.cornerRadius = 10
        
        leftChat.tintColor = userBubbleHolder.backgroundColor
    }

}
