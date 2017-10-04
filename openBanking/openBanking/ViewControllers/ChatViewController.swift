//
//  ChatViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 03/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var messages: [String] = [ "Ola, como posso te ajudar ? "]
    
    
    @IBOutlet weak var chatBarTab: UITabBarItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textMessageField: UITextField!
    
    @IBOutlet weak var optionsBottomConstraint: NSLayoutConstraint!
    
    @IBAction func sendMessage(_ sender: Any) {
        
        if let text = textMessageField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if text != "" {
                // Send message and add a bubble to table view
                messages.append(text)
                self.tableView.reloadData()
                textMessageField.text = ""
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.isUserInteractionEnabled = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)) , name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }

    @objc fileprivate  func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            var tabBarHeight = 0
            if ((self.tabBarController?.tabBar.frame.size.height) != nil) {
                tabBarHeight = Int(self.tabBarController!.tabBar.frame.size.height)
            }
            var height =  -Float(keyboardHeight) + Float(tabBarHeight)
            self.optionsBottomConstraint.constant =  CGFloat(height)
            UIView.animate(withDuration: 1000, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc fileprivate  func keyboardWillHide(notification: NSNotification) {
        self.optionsBottomConstraint.constant = 0
        UIView.animate(withDuration: 1000, animations: {
            self.view.layoutIfNeeded()
        })
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            let keyboardHeight = keyboardSize.height
//            print(keyboardHeight)
//
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "chatBubbleCell", for: indexPath) as! WatsonChatCell
        
        cell.labelText.text =  messages[indexPath.row]
        print(cell.labelText.frame.size.width)
        print("modificacao")
        print(cell.frame.size.width)
        
        
        return cell
    }

}
