//
//  LoggedAsInterfaceController.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 20/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import WatchKit
import Foundation

class LoggedAsInterfaceController: WKInterfaceController {
    
    // Outlets
    
    @IBOutlet var userLabel: WKInterfaceLabel!
    
    // Variables
    
    // Functions
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        print("Logged as \(WatchData.username)")
        userLabel.setText("Logged as\n \(WatchData.username)")
                
        let when = DispatchTime.now() + 2.5 // change to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.dismiss()
            print("Welcome screen dismissed")
        }
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
