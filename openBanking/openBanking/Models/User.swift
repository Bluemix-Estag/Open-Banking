//
//  User.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 01/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit

class User {
    
    var email: String
    var name: String
    var password: String
    
    init() {
        self.email = ""
        self.name = ""
        self.password = ""
    }
    
    init(email: String, name: String, password: String) {
        self.email = email
        self.name = name
        self.password =  password
    }
    
    func getDictionary() -> NSDictionary {
        return  ["email": self.email, "name": self.name, "password": self.password]
    }
    
    func setValue(userDic: [String: String]){
        self.email = userDic["email"]!
        self.name = userDic["name"]!
        self.password = userDic["password"]!
    }
}
