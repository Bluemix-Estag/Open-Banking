//
//  AccountDetailsViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 02/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit

class AccountDetailsViewController: UIViewController {
    
    @IBOutlet weak var labelTest: UILabel!
    let LOGGED_USER: User = User()
    var accountIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let user = UserDefaults.standard.value(forKeyPath: "LOGGED_USER"){
            
            if let obUser = user as? [String: Any] {
                self.LOGGED_USER.setValue(userDic: obUser)
                self.labelTest.text = self.LOGGED_USER.accounts[accountIndex]["accountName"] as! String
            }
        }
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
