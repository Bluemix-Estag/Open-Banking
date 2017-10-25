//
//  RestHandlerDelegate.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 25/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import  SwiftyJSON

protocol RestHandlerDelegate:class {
    
    func completion(result: JSON ,error: Bool) 
    
}
