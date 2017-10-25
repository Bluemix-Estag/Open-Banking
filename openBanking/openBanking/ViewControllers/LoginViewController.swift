//
//  LoginViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 01/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit
import SwiftyJSON


extension UITextField {
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
    
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.masksToBounds = false
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.width + 1 ,height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        self.borderStyle = UITextBorderStyle.none
        self.layer.addSublayer(bottomLine)

        
    }
}

class LoginViewController: UIViewController,RestHandlerDelegate {
    
    
    func completion(result: JSON, error: Bool) {
        
        if !error {
            UserDefaults.standard.set( result.dictionaryObject , forKey: "LOGGED_USER")
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async {
                self.indicator.hideActivityIndicator(uiView: self.view)
                self.performSegue(withIdentifier: "loginToMainSegue", sender: nil)
            }
        }else{
            var errorMessage = ""
            var title = ""
            if result != nil {
                switch result["error_reason"].string! {
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
        
        
    }
    
    
    let LOGGIN_URL = RestHandler.shared.ENDPOINT_URL + "/login"
    let indicator = Indicator()
    
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func login(_ sender: Any) {
        if let email = emailField.text?.trimmingCharacters(in: .whitespaces) {
            if email == ""{
                // Error
                present(Alert(title: "Email inválido", message: "Favor informe seu email").getAlert(), animated: true, completion: nil)
            }else{
                if let password = passwordField.text?.trimmingCharacters(in: .whitespaces) {
                    if password == "" {
                        present(Alert(title: "Senha inválido", message: "Favor informe sua senha").getAlert(), animated: true, completion: nil)
                    }else{
                        let userDic = ["email": email, "password": password]
                        self.indicator.showActivityIndicator(uiView: self.view)
                        RestHandler.shared.delegate = self
                        RestHandler.shared.POST(url: self.LOGGIN_URL, data: JSON(userDic))
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        
    }
    
    override func viewDidLayoutSubviews() {
        self.emailField.setBottomBorder()
        self.passwordField.setBottomBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.322, green: 0.678, blue: 0.647, alpha: 0)
//        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.322, green: 0.678, blue: 0.647, alpha: 0)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        
        RestHandler.shared.delegate = nil // ele faz magicamente :) 
        
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
