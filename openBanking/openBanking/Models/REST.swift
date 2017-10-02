//
//  REST.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 01/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON



class REST  {
    

    static func POST(url: String, body: JSON, completion: @escaping (JSON) -> Void){
    
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 2000
        do {
            request.httpBody = try body.rawData()
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                        completion(JSON(data))
                }else{
                    // Error
                    var err = ["error": true, "error_reason": "UNKNOWN_ERROR"] as [String : Any]
                    completion(JSON(err))
                }
            }
            task.resume()
            
            
        } catch  {
            print("error")
        }
    }
}
