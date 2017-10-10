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
    
    private let CONVERSATION_URL = RestHandler.shared().ENDPOINT_URL + "/conversation"
    var CONTEXT: [String: Any] = [:]
    
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
    func sendMessage(body: [String: Any], completion: @escaping (JSON, Bool) -> ()) {
        print("Send message method invoked..")
        var outputData = body
        var request = URLRequest(url: URL(string: self.CONVERSATION_URL)!)
        request.httpMethod = "POST"
        outputData["context"] = self.CONTEXT
        let output = try? JSON(outputData).rawData(options: [])
        request.httpBody = output
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("received conversation data \(JSON(data))")
            print("conversation response: \(response)")
            print("conversation error: \(error)")
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                if error == nil && statusCode == 200 {
                    self.CONTEXT = JSON(data)["context"].dictionaryObject!
                    completion(JSON(data), false)
                }else{
                    print(error?.localizedDescription)
                    completion( data != nil ? JSON(data): JSON.null, true)
                }
                
            }else{
                print(error?.localizedDescription)
                completion(JSON.null, true)
            }
            
            
            
            
            
        }
        task.resume()
    }
    // MARK: - Accessors
    class func shared() -> ChatHandler {
        return chatHandler
    }
    
}
