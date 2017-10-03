//
//  ChatHandler.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 03/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatHandler {
    
    private let CONVERSATION_URL = "https://demos-node-red.mybluemix.net/openbankingbot"
    private let USER_ID = UUID().uuidString
    // MARK: - Properties
    private static var chatHandler:ChatHandler = {
        let chatHandler = ChatHandler()
        // Configuration
        // ...
        return chatHandler
    }()
    
    // Initialization
    private init() {
     
    }
    func sendMessage(text: String) {
        print("Send message method invoked..")
        var request = URLRequest(url: URL(string: self.CONVERSATION_URL)!)
        request.httpMethod = "POST"
        
        var output = try? JSON(["user": self.USER_ID, "text": text]).rawData(options: [])
        request.httpBody = output
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(JSON(data))
        }
        task.resume()
    }
    // MARK: - Accessors
    class func shared() -> ChatHandler {
        return chatHandler
    }
    
}
