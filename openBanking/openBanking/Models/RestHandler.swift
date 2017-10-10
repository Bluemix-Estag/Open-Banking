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
     let ENDPOINT_URL = "https://openbanking.mybluemix.net"
//    let ENDPOINT_URL = "https://openbanking.localtunnel.me"
    
    class func shared() -> RestHandler{
        return restHandler
    }
    
    
    func POST(url: String, data: JSON, completion : @escaping ( JSON , Bool) -> Void ) -> () {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = try? data.rawData()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            print("POST DATA: \(JSON(data))")
            print("POST response: \(urlResponse)")
            print("POST error: \(error)")
            if var statusCode = (urlResponse as? HTTPURLResponse)?.statusCode {
                if error == nil && statusCode == 200 {
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
    
}
