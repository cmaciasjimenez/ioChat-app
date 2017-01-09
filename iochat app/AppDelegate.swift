//
//  AppDelegate.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 06/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        application.statusBarStyle = UIStatusBarStyle.lightContent
        setupNotificationCenter()
        
        let tfg = TFG.shared
        
        tfg.addReceptionTask(type: "message") { (userInfo) in
        
            // Message from watch
            if let value = userInfo["message"] as? String {
                
                print("Message received on iPhone from Watch: \(value)")
                
                // -> To web
                SocketIOManager.sharedInstance.sendMessage(message: value)
            }
        }
        
        tfg.addReceptionTask(type: "position") { (userInfo) in
            
            // Position from watch
            if let latitude = userInfo["latitude"] as? Double,
                let longitude = userInfo["longitude"] as? Double {
                
                print("Watch coordinates received on iPhone from Watch: \(latitude), \(longitude)")
                let coordinates: [CLLocationDegrees] = [latitude, longitude]
                UserDefaults.standard.set(coordinates, forKey: "Coordinates")
                
                // -> To web
                let position = "\(latitude), \(longitude)"
                SocketIOManager.sharedInstance.sendLocation(location: position)
                SocketIOManager.sharedInstance.sendMessage(message: "Has shared his Apple Watch location")
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SocketIOManager.sharedInstance.closeConnection()
        UserDefaults.standard.removeObject(forKey: "Coordinates")
        PhoneData.usersArray.removeAll()
        PhoneData.messagesArray.removeAll()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SocketIOManager.sharedInstance.establishConnection()
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                let username = messageInfo["username"] as! String
                let message = messageInfo["message"] as! String
                let messageString =  username + ">>" + message
                
                // -> To Phone
                PhoneData.messagesArray.append(messageString)
                print("Messages Array: \(PhoneData.messagesArray)")
                
                // -> To Watch
                let tfg = TFG.shared
                let userInfo = ["type": "message",
                                "value": messageString]
                tfg.sendToWatch(userInfo)
            })
        }
        
        SocketIOManager.sharedInstance.getUsers(completionHandler: { (userList) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                if PhoneData.username.isEmpty == false {
                    for (index, element) in PhoneData.usersArray.enumerated() {
                        if PhoneData.username == PhoneData.usersArray[index] {
                            let temp = element + " (you)"
                            PhoneData.usersArray.remove(at: index)
                            PhoneData.usersArray.insert(temp, at: index)
                        }
                    }
                }
                
                // -> To Watch
                let tfg = TFG.shared
                let userInfo = ["type": "userList",
                                "value": PhoneData.usersArray] as [String : Any]
                tfg.sendToWatch(userInfo)
            })
        })
        
        SocketIOManager.sharedInstance.getLocations { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                
                // -> To watch
                let lat = messageInfo["latitude"] as! String
                let long = messageInfo["longitude"] as! String
                let position = lat + ">>" + long
                
                let tfg = TFG.shared
                let userInfo = ["type": "position",
                                "value": position]
                tfg.sendToWatch(userInfo)
            })
        }
    }
    
    // MARK - Notification Center
    
    private func setupNotificationCenter() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.sendUsername(notification:)), name: NSNotification.Name(rawValue: "sendUsername"),  object: nil)
    }
    
    // -> To watch
    func sendUsername(notification: NSNotification) {
        
        let username = (notification.userInfo?["username"]) as! String
        
        let tfg = TFG.shared
        let userInfo = ["type": "username",
                        "value": username]
        tfg.sendToWatch(userInfo)
    }
}
