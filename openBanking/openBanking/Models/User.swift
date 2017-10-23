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
    var cpf: String
    var password: String
    var accounts: [ [String: Any] ]
    var payments: [ [String: Any] ]
    init() {
        self.email = ""
        self.name = ""
        self.password = ""
        self.cpf = ""
        self.accounts = [[:]]
        self.payments = [[:]]
    }
    
    init(email: String, name: String, password: String,cpf:String, accounts: [ [String: Any] ], payments: [[String: Any]]) {
        self.email = email
        self.name = name
        self.cpf = cpf
        self.password =  password
        self.accounts = accounts
        self.payments = payments
    }
    
    func getDictionary() -> NSDictionary {
        return  ["email": self.email, "name": self.name, "cpf": self.cpf , "password": self.password, "accounts": self.accounts, "payments": self.payments]
    }
    
    func setValue(userDic: [String: Any]){
        self.email = userDic["email"]! as! String
        self.name = userDic["name"]! as! String
        self.cpf = userDic["cpf"]! as! String
        self.password = userDic["password"]! as! String
        self.accounts = userDic["accounts"] as! [[String : Any]]
        self.payments = userDic["payments"] as! [[String: Any]]
    }
}
