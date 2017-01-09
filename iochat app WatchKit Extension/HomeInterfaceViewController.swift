//
//  HomeInterfaceViewController.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 08/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import WatchKit
import Foundation


class HomeInterfaceController: WKInterfaceController {
    
    // Outlets
    
    @IBAction func chatButtonPressed() {
        // -> ChatInterfaceController
    }
    
    @IBAction func locationButtonPressed() {
        // -> LocationInterfaceController
    }
    
    @IBAction func userButtonPressed() {
        // -> To UserListInterfaceController
    }
    
    // Variables
    
    // Functions
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.setTitle("Send.it")
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeInterfaceController.welcomeUsername(notification:)), name: NSNotification.Name(rawValue: "sendUsername"),  object: nil)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func welcomeUsername(notification: NSNotification) {
        presentController(withName: "welcomeInterface", context: nil)
    }
}
