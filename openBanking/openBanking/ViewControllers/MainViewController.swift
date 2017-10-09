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




class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
//    let UPDATE_USER_INFO_URL = "https://openbanking.mybluemix.net/updateInfo"
    let UPDATE_USER_INFO_URL = "https://openbanking.localtunnel.me/updateInfo"
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var homeTabBarItem: UITabBarItem!
    
    
    let LOGGED_USER: User = User()
    var refreshControl : UIRefreshControl!
    
    
    @objc func refreshUserDetails() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        RestHandler.shared().POST(url: UPDATE_USER_INFO_URL, data: JSON(LOGGED_USER.getDictionary())) { (data, error) in
            print(data)
            if error {
                DispatchQueue.main.async(execute: {
                    self.present(Alert(title: "Error", message: "Erro ao atualizar os dados, tente novamente.").getAlert(),animated: true, completion: nil)
                    self.refreshControl.endRefreshing()
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }else{
                self.LOGGED_USER.setValue(userDic: data.dictionaryObject!)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }
            
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "LOGGED_USER")
        UserDefaults.standard.removeObject(forKey: "pendingMessages")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        ChatHandler.shared().sendMessage(text: "Oi", completion: ({ (result, error) in
       
            
            if !error {
                
                DispatchQueue.main.async(execute: {
                    var messages: [String] = []
                    if var pendingMessages = UserDefaults.standard.object(forKey: "pendingMessages") as? Array<String>{
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
                    UIApplication.shared.endIgnoringInteractionEvents()
                    //                    }
                    //              let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    //              let fvc = storyboard.instantiateViewController(withIdentifier: "ChatStoryBoard") as! ChatViewController
                    //              fvc.watsonReceivedMessage(text: result["output"]["text"][0].string!)
                })
            }else{
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
            }
            
           
        }))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let user = UserDefaults.standard.value(forKeyPath: "LOGGED_USER"){
            if let obUser = user as? [String: Any] {
                self.LOGGED_USER.setValue(userDic: obUser)
                
                print(self.LOGGED_USER.getDictionary())
            }
        }
        
        print(LOGGED_USER.accounts)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refreshUserDetails), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            cell.bankName.text = LOGGED_USER.accounts[indexPath.row]["accountName"] as! String
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
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "bankAccountDetailSegue" {
    //            let destinationVC = segue.destination as! AccountDetailsViewController
    //            destinationVC.accountIndex = sender as! Int
    //
    //
    //        }
    //    }
    
    
    
}
