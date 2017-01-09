//
//  tfg.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 22/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import Foundation
import WatchConnectivity
import CoreLocation

// All the messages contain:
// key type = "message"
//     value = message
//
// key type = "position"
//     value = (long, lat)

class TFG: NSObject {
    
    static var shared = TFG()
    
    var messageTasks = [String : ([String : Any]) -> Void]()
    
    var locationTasks = [(CLLocation) -> Void]()
    
    var locationManager: CLLocationManager!
    
    private override init() {
        super.init()
        
        setupWatchConnectivity()
        setupLocation()
    }
    
    func addReceptionTask(type: String, handler: @escaping ([String : Any]) -> Void) {
        messageTasks[type] = handler
        print("messageTasks: \(messageTasks)")
    }
    
    func addLocationTask(_ task: @escaping (CLLocation) -> Void) {
        locationTasks.append(task)
        print("locationTasks: \(locationTasks)")
    }
    
    // Send files to Apple Watch through WatchConnectivity
    func sendToWatch(_ userInfo: [String : Any]) {
        
        if WCSession.isSupported() {
            print("Session supported")
            WCSession.default().transferUserInfo(userInfo)
        }
    }
}

// MARK - WatchConnectivity
extension TFG: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        
        if let type = userInfo["type"] as? String {
            let handler = self.messageTasks[type]
            handler!(userInfo)
        }
    }

    // Setup
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WC Session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WC Session did deactivate")
        WCSession.default().activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith
        activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: " + "\(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: " + "\(activationState.rawValue)")
    }
}

// MARK - Location
extension TFG: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (CLLocationManager.locationServicesEnabled()) {
            print("Location Services enabled")
        } else {
            print("Location Services not enabled")
        }
        
        let a = CLLocationManager.authorizationStatus()
        print("Authorization status: ", a.rawValue)
        
        if let location = locations.first {
            
            for task  in locationTasks {
                task(location)
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
    // Setup
    func setupLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
}
