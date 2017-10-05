//
//  MainViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 01/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import SDWebImage



class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var homeTabBarItem: UITabBarItem!
    
    let sections = ["Contas"," "]
    
    let LOGGED_USER: User = User()
    var refreshControl : UIRefreshControl!
    
    
    @objc func activityMethod() {
        
        print("refresh control method invoked...")
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "LOGGED_USER")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(activityMethod), for: UIControlEvents.valueChanged)
        self.tableView.refreshControl = refreshControl
        
        if let chatVC = self.tabBarController?.viewControllers![1] as? ChatViewController {
              chatVC.chatBarTab.badgeValue = "1"
        }
        
        ChatHandler.shared().sendMessage(text: "Oi", completion: ({ (result, error) in
            if !error {
                DispatchQueue.main.async(execute: {
                UserDefaults.standard.setValue(result["output"]["text"][0].string! , forKey: "pendingMesssage")
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "bankAccountCell", for: indexPath) as! BankAccountCell
            if LOGGED_USER.accounts.count > 0 {
                let nf = NumberFormatter()
                nf.numberStyle = .decimal
                nf.locale = Locale(identifier: "pt_BR")
                cell.bankIcon.image = #imageLiteral(resourceName: "safebox")
                cell.accountName.text = LOGGED_USER.accounts[indexPath.row]["accountName"] as! String
                var balanceNumber = LOGGED_USER.accounts[indexPath.row]["accountBalance"]
                cell.accountBalance.text = "R$ "+nf.string(from: balanceNumber as! NSNumber)!
            }else{
                cell.accountName.text = "Nenhuma conta cadastrada"
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell",for: indexPath) as! OptionCell
            cell.optionLabel.text = "Adicionar uma nova conta"
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            performSegue(withIdentifier: "bankAccountDetailSegue", sender: indexPath.row)
        }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bankAccountDetailSegue" {
            let destinationVC = segue.destination as! AccountDetailsViewController
            destinationVC.accountIndex = sender as! Int
            
            
        }
    }
    
    
    
}
