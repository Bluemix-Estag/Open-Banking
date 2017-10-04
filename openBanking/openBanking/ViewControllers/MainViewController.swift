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
    
    
    let sections = ["Contas"," "]
    
    let LOGGED_USER: User = User()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ChatHandler.shared().sendMessage(text: "Oi")
        
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
