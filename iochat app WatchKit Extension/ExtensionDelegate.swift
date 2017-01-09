//
//  ExtensionDelegate.swift
//  iochat app WatchKit Extension
//
//  Created by Carlos Macias Jimenez on 06/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        
        setupWatchConnectivity()
        setupNotificationCenter()
    }

    func applicationDidBecomeActive() {
    }

    func applicationWillResignActive() {
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    // MARK - Notification Center
    
    private func setupNotificationCenter() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(ExtensionDelegate.sendCoordinates(notification:)), name: NSNotification.Name(rawValue: "sendCoords"),  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ExtensionDelegate.sendAudioToTextMessage(notification:)), name: NSNotification.Name(rawValue: "sendAudioToText"),  object: nil)
    }
    
    // Send message watch -> phone
    func sendAudioToTextMessage(notification: NSNotification) {
        
        let message = notification.userInfo?["MessageToSend"] as! String
        
        if WCSession.isSupported() {
            print("Session supported")
            let userInfo = ["type": "message", "message": message]
            WCSession.default().transferUserInfo(userInfo)
        }
    }
    
    // Send position watch -> phone
    func sendCoordinates(notification: NSNotification) {
        
        let latitude = notification.userInfo?["latitude"]
        let longitude = notification.userInfo?["longitude"]
        let position = CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
        
        if WCSession.isSupported() {
            print("Session supported")
            let userInfo = ["type": "position", "latitude": position.latitude, "longitude": position.longitude] as [String : Any]
            WCSession.default().transferUserInfo(userInfo)
        }
    }
}

// MARK - Watch Connectivity
extension ExtensionDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        print("User Info Received")
        
        if let type = userInfo["type"] as? String {
            
            print("Type: \(type)")
            
            // Username for Home
            if type == "username" {
                if let username = userInfo["value"] as? String {
                    print("Username received on Watch from iPhone: \(username)")
                    WatchData.username = username
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendUsername"), object: nil, userInfo: nil)
                }
            }
            
            // Message for Chat
            if type == "message" {
                if let msg = userInfo["value"] as? String {
                    print("Message received on Watch from iPhone: \(msg)")
                    WatchData.messagesArray.insert(msg, at: 0)
                    print(WatchData.messagesArray)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newMessages"), object: nil, userInfo: nil)
                }
            }
            
            // Username for UserList
            if type == "userList" {
                if let usersArray = userInfo["value"] as? [String] {
                    print("UserList received on Watch from iPhone: \(usersArray)")
                    WatchData.usersWatchArray = usersArray
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newUsers"), object: nil, userInfo: nil)
                }
            }
            
            // Position for Map
            if type == "position" {
                if let pos = userInfo["value"] as? String {
                    print("Position received on Watch from iPhone: \(pos)")
                    let landAndLong = ["latAndLong": pos]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendLatAndLong"), object: nil, userInfo: landAndLong)
                }
            }
        }
    }
    
    // Setup
    
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session  = WCSession.default()
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith
        activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: " +
                "\(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: " + "\(activationState.rawValue)")
    }
}
