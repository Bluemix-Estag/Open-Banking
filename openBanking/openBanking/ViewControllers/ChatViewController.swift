//
//  ChatViewController.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 03/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var messages: [[String: String]] = []
    
    
    @IBOutlet weak var chatBarTab: UITabBarItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textMessageField: UITextField!
    
    @IBOutlet weak var optionsBottomConstraint: NSLayoutConstraint!
    
    @IBAction func sendMessage(_ sender: Any) {
        
        if let text = textMessageField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if text != "" {
                // Send message and add a bubble to table view
                self.messages.append(["user": text])
                self.textMessageField.text = ""
                self.customReloadTable()
                
                ChatHandler.shared().sendMessage(text: text, completion: { (result,error) in
                    print(error)
                    if !error {
                        
                        DispatchQueue.main.async(execute: {
                            self.messages.append(["watson":result["output"]["text"][0].string!])
                            self.customReloadTable()
                        })
                        
                    }else{
                        DispatchQueue.main.async(execute: {
                            self.messages.append(["watson": "Um erro ocorreu, tente novamente."])
                                self.customReloadTable()
                        })
                    }
                })
            }
        }
    }
    
    func customReloadTable(){
        self.tableView.reloadData()
        
        let lastRowIndex = self.tableView!.numberOfRows(inSection: 0) - 1
        let pathToLastRow = NSIndexPath(row: lastRowIndex, section: 0)
        self.tableView?.scrollToRow(at: pathToLastRow as IndexPath, at: UITableViewScrollPosition.top, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if let pendingMessage = UserDefaults.standard.value(forKey: "pendingMesssage") {
            messages.append(["watson": pendingMessage as! String])
            UserDefaults.standard.removeObject(forKey: "pendingMesssage")
            self.chatBarTab.badgeValue = nil
        }
        
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
        print(messages)
        //        self.tableView.reloadData()
        
        self.customReloadTable()
        
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
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messages.count > 0{
            var message = messages[indexPath.row]
            if Array(message.keys)[0] == "watson" {
                var cell = tableView.dequeueReusableCell(withIdentifier: "chatBubbleCell", for: indexPath) as! WatsonChatCell
                cell.labelText.text =  messages[indexPath.row]["watson"]
                return cell
            }else{
                var cell = tableView.dequeueReusableCell(withIdentifier: "UserBubbleIdentifier", for: indexPath) as! UserChatCell
                cell.userTextLabel.text =  messages[indexPath.row]["user"]
                return cell
            }
        }else{
            return UITableViewCell()
        }
        
    }
    
    func watsonReceivedMessage(text: String){
        self.messages.append(["watson": text])
        print(messages)
    }
    
    
}
