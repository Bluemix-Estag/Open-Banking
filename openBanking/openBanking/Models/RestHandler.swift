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
    
    private var task: URLSessionDataTask!
    weak var delegate:RestHandlerDelegate?{
        didSet{
            if delegate == nil && task != nil {
                self.task.cancel()
            }
        }}
    private init(){
        
    }
     let ENDPOINT_URL = "https://openbanking.mybluemix.net"
//    let ENDPOINT_URL = "https://openbanking.localtunnel.me"
    
    static let shared = RestHandler()
    
    
    func POST(url: String, data: JSON) -> () {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = try? data.rawData()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            print("POST DATA: \(JSON(data))")
            print("POST response: \(urlResponse)")
            print("POST error: \(error)")
            if let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode {
                if error == nil && statusCode == 200 {
                    self.delegate?.completion(result: JSON(data!), error: false)
                    
                }else{
//                    print(error?.localizedDescription)
                    self.delegate?.completion(result: data != nil ? JSON(data!): JSON.null, error: true)
                }
            }else{
//                print(error?.localizedDescription)
                self.delegate?.completion(result: JSON.null, error: true)
            }
           
        }
        task.resume()
    }
    
}
