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
    let dateFormatter = DateFormatter()
    
    
    @IBOutlet weak var chatBarTab: UITabBarItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textMessageField: UITextField!
    
    @IBOutlet weak var optionsBottomConstraint: NSLayoutConstraint!
    
    @IBAction func sendMessage(_ sender: Any) {
        
        if let text = textMessageField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if text != "" {
                // Send message and add a bubble to table view
                let userDictionary = ["user": text, "date": dateFormatter.string(from: Date())]
                self.messages.append(userDictionary)
                self.textMessageField.text = ""
                self.customReloadTable()
                let body: [String: Any] = ["text": text]
                ChatHandler.shared().sendMessage(body: body , completion: { (result,error) in
                    print(result)
                    if !error {
                        
                        DispatchQueue.main.async(execute: {
                            
                            result["output"]["text"].array?.forEach({ (text) in
                                self.messages.append(["watson": text.string!, "date": self.dateFormatter.string(from: Date())])
                            })
                            
                            self.customReloadTable()
                        })
                        
                    }else{
                        DispatchQueue.main.async(execute: {
                            let watsonDic = ["watson": "Um erro ocorreu, tente novamente.", "date": self.dateFormatter.string(from: Date())]
                            self.messages.append(watsonDic)
                            self.customReloadTable()
                        })
                    }
                })
            }
        }
    }
    
    func customReloadTable(){
        self.tableView.reloadData()
        if messages.count > 0 {
            let lastRowIndex = self.tableView!.numberOfRows(inSection: 0) - 1
            let pathToLastRow = NSIndexPath(row: lastRowIndex, section: 0)
            self.tableView?.scrollToRow(at: pathToLastRow as IndexPath, at: UITableViewScrollPosition.top, animated: true)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        dateFormatter.dateFormat = "hh:mm"
     
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let pendingMessages = UserDefaults.standard.value(forKey: "pendingMesssages") as? Array<String> {
            for msg in pendingMessages {
                self.messages.append(["watson": msg, "date": self.dateFormatter.string(from: Date())])
            }
            UserDefaults.standard.removeObject(forKey: "pendingMesssages")
            self.chatBarTab.badgeValue = nil
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)) , name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        print(messages)
        self.customReloadTable()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Remove observers!
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)

    }
    @objc fileprivate  func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            var tabBarHeight = 0
            if ((self.tabBarController?.tabBar.frame.size.height) != nil) {
                tabBarHeight = Int(self.tabBarController!.tabBar.frame.size.height)
            }
            let height =  -Float(keyboardHeight) + Float(tabBarHeight)
            self.optionsBottomConstraint.constant =  CGFloat(height)
            
            UIView.animate(withDuration: 1000, animations: {
                self.view.layoutIfNeeded()
                self.customReloadTable()
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
            let message = messages[indexPath.row]

        
            
            if Array(message.keys)[0] == "watson" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "chatBubbleCell", for: indexPath) as! WatsonChatCell
                cell.labelText.text =  messages[indexPath.row]["watson"]
                cell.dateLabel.text = messages[indexPath.row]["date"]
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserBubbleIdentifier", for: indexPath) as! UserChatCell
                cell.userTextLabel.text =  messages[indexPath.row]["user"]
                cell.dateLabel.text =  messages[indexPath.row]["date"]
                return cell
            }
            
            
            
        }else{
            return UITableViewCell()
        }
        
    }
}
