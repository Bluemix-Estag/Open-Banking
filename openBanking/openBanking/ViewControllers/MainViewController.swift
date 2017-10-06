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
    
    let UPDATE_USER_INFO_URL = "https://openbanking.mybluemix.net/updateInfo"
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var homeTabBarItem: UITabBarItem!
    
    let sections = ["Contas"," "]
    
    let LOGGED_USER: User = User()
    var refreshControl : UIRefreshControl!
    
    
    @objc func refreshUserDetails() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        RestHandler.shared().POST(url: UPDATE_USER_INFO_URL, data: JSON(LOGGED_USER.getDictionary())) { (data, error) in
            UIApplication.shared.endIgnoringInteractionEvents()
            if error {
                DispatchQueue.main.async(execute: {
                    self.present(Alert(title: "Error", message: "Erro ao atualizar os dados, tente novamente.").getAlert(),animated: true, completion: nil)
                    self.refreshControl.endRefreshing()
                })
            }else{
                self.LOGGED_USER.setValue(userDic: data.dictionaryObject!)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
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
//        UserDefaults.standard.set("MainPage", forKey: "currentUserPage")
//        UserDefaults.standard.synchronize()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        ChatHandler.shared().sendMessage(text: "Oi", completion: ({ (result, error) in
            if !error {
                DispatchQueue.main.async(execute: {
                    var messages: [String] = []
                    if var pendingMessages = UserDefaults.standard.object(forKey: "pendingMessages") as? Array<String>{
                        messages = pendingMessages
                    }
                    messages.append(result["output"]["text"][0].string!)
                    UserDefaults.standard.setValue( messages , forKey: "pendingMesssages")
                    UserDefaults.standard.synchronize()
                    
                    
//                    if UserDefaults.standard.object(forKey: "currentUserPage") as! String != "ChatPage"{
                        if let chatVC = self.tabBarController?.viewControllers![1] as? ChatViewController {
                            chatVC.chatBarTab.badgeValue = String(messages.count)
                        }
                    
                        UIApplication.shared.endIgnoringInteractionEvents()
//                    }
                    //              let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    //              let fvc = storyboard.instantiateViewController(withIdentifier: "ChatStoryBoard") as! ChatViewController
                    //              fvc.watsonReceivedMessage(text: result["output"]["text"][0].string!)
                })
            }
        }))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let user = UserDefaults.standard.value(forKeyPath: "LOGGED_USER"){
            if let obUser = user as? [String: Any] {
                self.LOGGED_USER.setValue(userDic: obUser)
                
            }
        }
        
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
        return sections.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if LOGGED_USER.accounts.count == 0 {
                return 1
            }else{
                return LOGGED_USER.accounts.count
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat(integerLiteral: 40)
        }else{
            return CGFloat(integerLiteral: 40)
        }
        
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CGFloat(integerLiteral: 70)
        }else{
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if LOGGED_USER.accounts.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "bankAccountCell", for: indexPath) as! BankAccountCell
                let nf = NumberFormatter()
                nf.numberStyle = .decimal
                nf.locale = Locale(identifier: "pt_BR")
                cell.bankIcon.image = #imageLiteral(resourceName: "safebox")
                cell.accountName.text = LOGGED_USER.accounts[indexPath.row]["accountName"] as! String
                let balanceNumber = LOGGED_USER.accounts[indexPath.row]["accountBalance"]
                cell.accountBalance.text = "R$ "+nf.string(from: balanceNumber as! NSNumber)!
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell",for: indexPath) as! OptionCell
                cell.optionLabel.text = "Nenhuma conta cadastrada"
                cell.optionLabel.textColor = .black
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell",for: indexPath) as! OptionCell
            cell.optionLabel.text = "Adicionar uma nova conta"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //        if indexPath.section == 0 {
        //            performSegue(withIdentifier: "bankAccountDetailSegue", sender: indexPath.row)
        //        }
        
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bankAccountDetailSegue" {
            let destinationVC = segue.destination as! AccountDetailsViewController
            destinationVC.accountIndex = sender as! Int
            
            
        }
    }
    
    
    
}
