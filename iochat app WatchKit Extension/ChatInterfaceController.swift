//
//  ChatInterfaceController.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 08/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import WatchKit
import Foundation

class ChatInterfaceController: WKInterfaceController {
    
    // Outlets
    
    @IBOutlet var chatTable: WKInterfaceTable!
    
    @IBAction func audioButtonPressed() {
        self.presentTextInputController(withSuggestions: nil, allowedInputMode: .plain, completion:{(message) -> Void in
            
            let textMessage = message?[0] as? String
            if textMessage?.isEmpty == false {
                let textMessageToSend = ["MessageToSend": textMessage]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendAudioToText"), object: nil, userInfo: textMessageToSend)
            }
        })
    }
    
    @IBAction func emojiButtonPressed() {
        
        self.presentTextInputController(withSuggestions: ["👍🏻", "🙂"], allowedInputMode: .allowEmoji, completion:{(message) -> Void in
            
            let textMessage = message?[0] as? String
            if textMessage?.isEmpty == false {
                let textMessageToSend = ["MessageToSend": textMessage]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendAudioToText"), object: nil, userInfo: textMessageToSend)
            }
        })
    }
    
    @IBAction func clearMessagesMenuItem() {
        WatchData.messagesArray.removeAll()
        print("Messages cleared")
        reloadTable()
    }

    // Variables
    
    // Functions
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.setTitle("Chat")
        
        // Reload Table live
        NotificationCenter.default.addObserver(self, selector: #selector(ChatInterfaceController.reloadTable), name: NSNotification.Name(rawValue: "newMessages"),  object: nil)
    }
    
    override func willActivate() {
        super.willActivate()
        
        fillMessagesTable()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func fillMessagesTable() {
        
        chatTable.setNumberOfRows(WatchData.messagesArray.count, withRowType: "MessageRowType")
        
        for (index, element) in WatchData.messagesArray.enumerated() {
            
            let controller = chatTable.rowController(at: index) as! MessageRowController
            
            let current : [String] = element.components(separatedBy: ">>")
            let username = current[0]
            let message = current[1]
            
            if username == WatchData.username {
                controller.usernameLabel.setHorizontalAlignment(.right)
                controller.messageLabel.setHorizontalAlignment(.right)
                controller.usernameLabel.setText(username)
                controller.messageLabel.setText(message)
            } else {
                controller.usernameLabel.setText(username)
                controller.messageLabel.setText(message)
            }
        }
    }
    
    func reloadTable() {
        fillMessagesTable()
    }
}
