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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        labelText.layer.cornerRadius = 10
        labelViewHolder.layer.cornerRadius = 10
    }
    
    
}

