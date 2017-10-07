//
//  CadastrarViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 01/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import SwiftyJSON







class CadastrarViewController: UIViewController {
        let CREATE_ACCOUNT_URL = "https://openbanking.mybluemix.net/createAccount"
//    let CREATE_ACCOUNT_URL = "https://openbanking.localtunnel.me/createAccount"
    var LOGGED_USER: User = User()
    let indicator = Indicator()
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBAction func register(_ sender: Any) {
        if let email = emailField.text {
            if email == ""{
                present(Alert(title: "Email inválido", message: "Favor informe seu email").getAlert(), animated: true, completion: nil)
            }else{
                if let name = nameField.text {
                    if name == "" {
                        present(Alert(title: "Nome inválido", message: "Favor informe seu nome").getAlert(), animated: true, completion: nil)
                    }else{
                        if let password = passwordField.text{
                            if let confirmPassword = confirmPasswordField.text{
                                if password != confirmPassword || password == "" || confirmPassword == "" {
                                    present(Alert(title: "Senhas inválidas", message: "Favor confirme a sua senha").getAlert(), animated: true, completion: nil)
                                }else{
                                    self.indicator.showActivityIndicator(uiView: self.view)
                                    LOGGED_USER = User(email: email, name: name, password: password, accounts: [])
                                    // Register the user
                                    RestHandler.shared().POST(url: CREATE_ACCOUNT_URL, data: JSON(LOGGED_USER.getDictionary()), completion: { (data, error) in
                                        if !error {
                                            UserDefaults.standard.set(self.LOGGED_USER.getDictionary(), forKey: "LOGGED_USER")
                                            UserDefaults.standard.synchronize()
                                            DispatchQueue.main.async {
                                                self.indicator.hideActivityIndicator(uiView: self.view)
                                                self.performSegue(withIdentifier: "principleSegue", sender: nil)
                                            }
                                        }else{
                                            var title = ""
                                            var msg = ""
                                            if data != nil {
                                                switch data["error_reason"].string! {
                                                case "EMAIL_ALREADY_REGISTERED":
                                                    title = "Email inválido"
                                                    msg = "Email já está cadastrado"
                                                    break
                                                default:
                                                    title = "Erro"
                                                    msg = "Um erro ocorreu, tente mais tarde"
                                                }
                                            }else{
                                                title = "Erro"
                                                msg = "Um erro ocorreu, tente novamente!"
                                            }
                                            DispatchQueue.main.async {
                                                self.indicator.hideActivityIndicator(uiView: self.view)
                                                self.present(Alert(title: title   , message: msg).getAlert(), animated: true, completion: nil)
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        nameField.setBottomBorder()
        emailField.setBottomBorder()
        passwordField.setBottomBorder()
        confirmPasswordField.setBottomBorder()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
