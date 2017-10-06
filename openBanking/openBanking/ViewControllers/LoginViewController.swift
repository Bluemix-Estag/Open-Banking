//
//  LoginViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 01/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import SwiftyJSON


class LoginViewController: UIViewController {
    let LOGGIN_URL = "https://openbanking.mybluemix.net/login"
    let indicator = Indicator()
    
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func login(_ sender: Any) {
        if let email = emailField.text {
            if email == ""{
                // Error
                present(Alert(title: "Email inválido", message: "Favor informe seu email").getAlert(), animated: true, completion: nil)
            }else{
                if let password = passwordField.text {
                    if password == "" {
                        present(Alert(title: "Senha inválido", message: "Favor informe sua senha").getAlert(), animated: true, completion: nil)
                    }else{
                        let userDic = ["email": email, "password": password]
                        self.indicator.showActivityIndicator(uiView: self.view)
                        RestHandler.shared().POST(url: self.LOGGIN_URL, data: JSON(userDic), completion: { (data, error) in
                            if !error {
                                UserDefaults.standard.set( data.dictionaryObject , forKey: "LOGGED_USER")
                                UserDefaults.standard.synchronize()
                                DispatchQueue.main.async {
                                    self.indicator.hideActivityIndicator(uiView: self.view)
                                    self.performSegue(withIdentifier: "loginToMainSegue", sender: nil)
                                }
                            }else{
                                var errorMessage = ""
                                var title = ""
                                if data != nil {
                                    switch data["error_reason"].string! {
                                    case "EMAIL_NOT_FOUND" :
                                        title = "Email inválido"
                                        errorMessage = "Email não encontrado."
                                        break
                                    case "WRONG_PASSWORD":
                                        title = "Senha inválida"
                                        errorMessage = "Senha incorreta, tente novamente"
                                        break
                                    default:
                                        title = "Erro"
                                        errorMessage = "Um erro ocorreu, tente novamente!"
                                    }
                                }else{
                                    title = "Erro"
                                    errorMessage = "Um erro ocorreu, tente novamente!"
                                }
                               
                                DispatchQueue.main.async {
                                    self.indicator.hideActivityIndicator(uiView: self.view)
                                    self.present(Alert(title: title , message: errorMessage).getAlert(), animated: true, completion: nil)
                                    UserDefaults.standard.removeObject(forKey: "LOGGED_USER")
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
