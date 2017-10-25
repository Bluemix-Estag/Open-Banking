//
//  MainViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 01/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON




class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,RestHandlerDelegate  {
    
    // Completion method invoked when rest request is done!
    func completion(result: JSON, error: Bool) {
        if error {
            DispatchQueue.main.async(execute: {
                self.present(Alert(title: "Error", message: "Erro ao atualizar os dados, tente novamente.").getAlert(),animated: true, completion: nil)
                self.refreshControl.endRefreshing()
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }else{
            self.LOGGED_USER.setValue(userDic: result.dictionaryObject!)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
    }
    
    
    let UPDATE_USER_INFO_URL = RestHandler.shared.ENDPOINT_URL + "/updateInfo"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var homeTabBarItem: UITabBarItem!
    
    
    let LOGGED_USER: User = User()
    var refreshControl : UIRefreshControl!
    
    
    @objc func refreshUserDetails() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        RestHandler.shared.delegate = self
        RestHandler.shared.POST(url: UPDATE_USER_INFO_URL, data: JSON(LOGGED_USER.getDictionary()))
    }
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "LOGGED_USER")
        UserDefaults.standard.removeObject(forKey: "pendingMessages")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if checkUser() {
            restoreUser()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refreshUserDetails), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = refreshControl
        
        if checkUser() {
            restoreUser()
            callWatsonConversation()
        }
    }
    
    func checkUser() -> Bool {
        if let user = UserDefaults.standard.value(forKeyPath: "LOGGED_USER"){
            if user is [String: Any] {
                return true
            }
        }
        return false
    }
    
    func restoreUser() -> Void {
        if let user = UserDefaults.standard.value(forKeyPath: "LOGGED_USER"){
            if let obUser = user as? [String: Any] {
                self.LOGGED_USER.setValue(userDic: obUser)
            }
        }
    }
    
    
    func callWatsonConversation() -> Void {
        
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        let body: [String: Any] = [
            "text": "",
            "user": self.LOGGED_USER.getDictionary()
        ]
        ChatHandler.shared().CONTEXT = [:]
        ChatHandler.shared().sendMessage(body: body, completion: ({ (result, error) in
            if !error {
                DispatchQueue.main.async(execute: {
                    if let action = result["output"]["action"].string {
                        if action == "notifyUser" {
                            var messages: [String] = []
                            if let pendingMessages = UserDefaults.standard.object(forKey: "pendingMessages") as? Array<String>{
                                messages = pendingMessages
                            }
                            if let message = result["output"]["text"][0].string {
                                messages.append(message)
                                UserDefaults.standard.setValue( messages , forKey: "pendingMesssages")
                                UserDefaults.standard.synchronize()
                                if let chatVC = self.tabBarController?.viewControllers![1] as? ChatViewController {
                                    chatVC.chatBarTab.badgeValue = String(messages.count)
                                }
                            }
                        }
                    }
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }else{
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }
            
            
        }))
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if LOGGED_USER.accounts.count == 0 {
            return 1
        }else{
            return LOGGED_USER.accounts.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if LOGGED_USER.accounts.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bankCell", for: indexPath) as! BankCell
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.locale = Locale(identifier: "pt_BR")
            cell.bankImage.image = #imageLiteral(resourceName: "safebox")
            cell.bankName.text = (LOGGED_USER.accounts[indexPath.row]["name"] as! String)
            let balanceNumber = LOGGED_USER.accounts[indexPath.row]["balance"]
            cell.bankBalance.text = "R$ "+nf.string(from: balanceNumber as! NSNumber)!
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "blankCell",for: indexPath) as! BlankBankCell
            cell.messageLabel?.text = "Nenhuma conta cadastrada"
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        RestHandler.shared.delegate = nil // ele faz magicamente :)
        
    }
}
