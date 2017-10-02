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
    var accounts: [ [String: Any] ]
    init() {
        self.email = ""
        self.name = ""
        self.password = ""
        self.accounts = [[:]]
    }
    
    init(email: String, name: String, password: String, accounts: [ [String: Any] ]) {
        self.email = email
        self.name = name
        self.password =  password
        self.accounts = accounts
    }
    
    func getDictionary() -> NSDictionary {
        return  ["email": self.email, "name": self.name, "password": self.password, "accounts": self.accounts]
    }
    
    func setValue(userDic: [String: Any]){
        self.email = userDic["email"]! as! String
        self.name = userDic["name"]! as! String
        self.password = userDic["password"]! as! String
        self.accounts = userDic["accounts"] as! [[String : Any]]
    }
}
