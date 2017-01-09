//
//  MessagesViewController.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 15/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    // Outlets
    
    @IBOutlet weak var newsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageEditor: UITextView!
    @IBOutlet weak var bottomEditor: NSLayoutConstraint!
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        if messageEditor.text.characters.count > 0 {
            let message = messageEditor.text
            SocketIOManager.sharedInstance.sendMessage(message: message!)
            messageEditor.text = ""
            messageEditor.resignFirstResponder()
        }
    }
    
    // Variables
    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardSetup()
        bannerSetup()
        tableView.allowsSelection = false
        tableView.rowHeight = 60
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        self.tabBarController?.navigationItem.title = "Chat"
        messageEditor.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fadeBanner(view: newsLabel, delay: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bannerSetup() {
        newsLabel.layer.cornerRadius = 15.0
        newsLabel.clipsToBounds = true
        newsLabel.alpha = 1.0
        newsLabel.text = "Logged as \(PhoneData.username)"
    }
    
    func fadeBanner(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 0.5
        
        UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
            view.alpha = 0
        },
        completion: nil)
    }
    
    // MARK - Messages Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PhoneData.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCustomCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        
        let currentChatMessage = PhoneData.messagesArray[indexPath.item]
        let current : [String] = currentChatMessage.components(separatedBy: ">>")
        let username = current[0]
        let message = current[1]
        
        if username == PhoneData.username {
            cell.textLabel?.text = "\(username.uppercased()): \(message)"
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.textAlignment = NSTextAlignment.right
        } else {
            cell.textLabel?.text = "\(username.uppercased()): \(message)"
            cell.textLabel?.textColor = UIColor.white
        }
        return cell
    }
    
    // MARK - Keyboard custom functions
    
    func keyboardSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.handleKeyboardDidShowNotification(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.handleKeyboardDidHideNotification(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MessagesViewController.dismissKeyboard))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        swipeGestureRecognizer.delegate = self
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    func handleKeyboardDidShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                bottomEditor.constant = keyboardFrame.size.height - (tabBarController?.tabBar.frame.size.height)!
                view.layoutIfNeeded()
            }
        }
    }
    
    func handleKeyboardDidHideNotification(_ notification: Notification) {
        bottomEditor.constant = 0
        view.layoutIfNeeded()
    }
    
    func dismissKeyboard() {
        if messageEditor.isFirstResponder {
            messageEditor.resignFirstResponder()
        }
    }
}
