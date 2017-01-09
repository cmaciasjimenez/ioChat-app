//
//  UsersViewController.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 06/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    
    @IBOutlet weak var enterUserLabel: UILabel!
    @IBOutlet weak var userTextField: UITextField!
    
    @IBAction func enterButtonPressed(_ sender: Any) {
    }
    
    @IBAction func userTextField(_ sender: Any) {
    }
    
    // Variables
    
    var user: String!
    
    // Functions
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Login"
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (userTextField.text?.isEmpty)! {
            print("Username is empty")
            return false
        } else {
            user = userTextField.text
            PhoneData.username = user
            SocketIOManager.sharedInstance.connectToServerWithUsername(username: user)
            
            let usernameToSend = ["username": user]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendUsername"), object: nil, userInfo: usernameToSend)
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Logout"
        navigationItem.backBarButtonItem = backItem
    }
    
    // Hide keyboard when toching anywhere outside the textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userTextField.endEditing(true)
    }
}
