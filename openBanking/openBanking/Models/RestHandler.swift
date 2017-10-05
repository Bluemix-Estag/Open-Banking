//
//  RestHandler.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 05/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import SwiftyJSON

class RestHandler {
    
    private static let restHandler: RestHandler = {
        let restHandler = RestHandler()
        return restHandler
    }()
    
    private init(){
        
    }
    
    class func shared() -> RestHandler{
        return restHandler
    }
    
    
    func POST(url: String, data: JSON, completion : @escaping ( JSON , Bool) -> Void ) -> () {
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = try? data.rawData()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            
            print("data \(data)")
            print("response \(urlResponse)")
            print("error \(error)")
            if error == nil{
                
            }else{
                completion(JSON.null, true)
            }
     
            
        }
        
        task.resume()
    }
    
    
    
    
}
