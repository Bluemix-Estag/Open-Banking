//
//  RegisterViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 31/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterViewController: UIViewController, RestHandlerDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var cpfField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    func completion(result: JSON, error: Bool) {
        if !error {
            UserDefaults.standard.set(result["user"].dictionaryObject, forKey: "LOGGED_USER")
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async {
                self.indicator.hideActivityIndicator(uiView: self.view)
                self.performSegue(withIdentifier: "principleSegue", sender: nil)
            }
        }else{
            var title = ""
            var msg = ""
            if result != JSON.null {
                switch result["error_reason"].string! {
                case "EMAIL_ALREADY_REGISTERED":
                    title = "Email inválido"
                    msg = "Email já está cadastrado"
                    break
                case "CPF_ALREADY_REGISTERED":
                    title = "CPF inválido"
                    msg = "CPF já está cadastrado"
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
    }
    
    let CREATE_ACCOUNT_URL = RestHandler.shared.ENDPOINT_URL + "/createAccount"
    var LOGGED_USER: User = User()
    let indicator = Indicator()
    
    
    
    
    
    @IBAction func register(_ sender: Any) {
        if let email = emailField.text?.trimmingCharacters(in: .whitespaces) {
            if email == ""{
                present(Alert(title: "Email inválido", message: "Favor informe seu email").getAlert(), animated: true, completion: nil)
            }else{
                if let name = nameField.text?.trimmingCharacters(in: .whitespaces) {
                    if name == "" {
                        present(Alert(title: "Nome inválido", message: "Favor informe seu nome").getAlert(), animated: true, completion: nil)
                    }else{
                        if let cpf = cpfField.text?.trimmingCharacters(in: .whitespaces) {
                            if cpf == "" {
                                present(Alert(title: "CPF inválido", message: "Favor informe seu cpf").getAlert(), animated: true, completion: nil)
                            }else{
                                if let password = passwordField.text?.trimmingCharacters(in: .whitespaces){
                                    if let confirmPassword = confirmPasswordField.text?.trimmingCharacters(in: .whitespaces){
                                        if password != confirmPassword || password == "" || confirmPassword == "" {
                                            present(Alert(title: "Senhas inválidas", message: "Favor confirme a sua senha").getAlert(), animated: true, completion: nil)
                                        }else{
                                            // Show the indicator on the screen
                                            self.indicator.showActivityIndicator(uiView: self.view)
                                            LOGGED_USER = User(email: email, name: name,password: password, cpf: cpf, accounts: [], payments: [])
                                            // Register the user
                                            RestHandler.shared.delegate = self
                                            RestHandler.shared.POST(url: CREATE_ACCOUNT_URL, data :JSON(LOGGED_USER.getDictionary()))
                                        }
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }

    override func viewDidLayoutSubviews() {
        self.nameField.setBottomBorder()
        self.emailField.setBottomBorder()
        self.cpfField.setBottomBorder()
        self.passwordField.setBottomBorder()
        self.confirmPasswordField.setBottomBorder()
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
