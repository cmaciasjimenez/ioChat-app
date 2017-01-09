//
//  UserListInterfaceController.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 19/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import WatchKit
import Foundation

class UserListInterfaceController: WKInterfaceController {
    
    // Outlets
    
    @IBOutlet var userListTable: WKInterfaceTable!
    
    // Variables
    
    
    // Functions
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.setTitle("Users")
        
        // Reload Table live
        NotificationCenter.default.addObserver(self, selector: #selector(UserListInterfaceController.reloadTable), name: NSNotification.Name(rawValue: "newUsers"),  object: nil)
    }
    
    override func willActivate() {
        super.willActivate()
        
        fillUserListTable()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func fillUserListTable() {
        
        userListTable.setNumberOfRows(WatchData.usersWatchArray.count, withRowType: "UserRowType")
        
        for (index, element) in WatchData.usersWatchArray.enumerated() {
            
            let controller = userListTable.rowController(at: index) as! UserRowController
            controller.userLabel.setText(element)
        }
    }
    
    func reloadTable() {
        fillUserListTable()
    }
}
