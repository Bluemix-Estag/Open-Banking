//
//  CadastrarViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 01/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit

class CadastrarViewController: UIViewController {
    
    let CREATE_ACCOUNT_URL = "https://openbanking.mybluemix.net/createAccount"
    var LOGGED_USER: User = User()
    
    let indicator = Indicator()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
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
                                    var request = URLRequest(url: URL(string: CREATE_ACCOUNT_URL)!)
                                    request.httpMethod = "POST"
                                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                    
                                    if let jsonData = try? JSONSerialization.data(withJSONObject: LOGGED_USER.getDictionary() , options: []) {
                                        print("Trying to make a post call")
                                        request.httpBody = jsonData
                                        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                                            if let returnedData = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]{
                                                
                                                if error == nil && returnedData!["statusCode"] as! Int == 200 {
                                                    // User registered successfully!
                                                    print("Nao tem erro")
                                                    UserDefaults.standard.set( self.LOGGED_USER.getDictionary() , forKey: "LOGGED_USER")
                                                    UserDefaults.standard.synchronize()
                                                    DispatchQueue.main.async {
                                                        self.performSegue(withIdentifier: "principleSegue", sender: nil)
                                                    }
                                                }else{
                                                    var title = ""
                                                    var msg = ""
                                                    switch returnedData?["error_reason"] as! String {
                                                    case "EMAIL_ALREADY_REGISTERED":
                                                        title = "Email inválido"
                                                        msg = "Email já está cadastrado"
                                                        break
                                                    default:
                                                        title = "Erro"
                                                        msg = "Um erro ocorreu, tente mais tarde"
                                                    }
                                                    DispatchQueue.main.async {
                                                        self.indicator.hideActivityIndicator(uiView: self.view)
                                                        self.present(Alert(title: title   , message: msg).getAlert(), animated: true, completion: nil)
                                                    }
                                                }
                                            }else{
                                                
                                            }
                                        })
                                        
                                        task.resume()
                                    }else{
                                        print("Erro")
                                    }
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
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
