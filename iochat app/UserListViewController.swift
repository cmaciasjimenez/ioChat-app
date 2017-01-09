//
//  UserListViewController.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 19/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate  {
    
    // Outlets
    
    @IBOutlet weak var userTable: UITableView!
    
    // Variables
    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTable.allowsSelection = false
        userTable.rowHeight = 80
        
        SocketIOManager.sharedInstance.getUsers(completionHandler: { (userList) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.userTable.reloadData()
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "Users Online"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - Messages Table
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PhoneData.usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCustomCell", for: indexPath)
        cell.textLabel?.text = PhoneData.usersArray[indexPath.item]
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
}
