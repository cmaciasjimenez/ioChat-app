//
//  SocketIOManager.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 06/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    
    // Use here your IP (local) or URL
    var socket: SocketIOClient = SocketIOClient(socketURL: Foundation.URL(string: "https://your-url")!)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }

    func connectToServerWithUsername(username: String) {
        socket.emit("new user", username)
    }
    
    func sendMessage(message: String) {
        socket.emit("send message", message)
    }
    
    func sendLocation(location: String) {
        socket.emit("send location", location)
    }
    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
        socket.on("new message") { (info, msg) -> Void in
            
            var messageDictionary = [String: AnyObject]()
            
            var string = info[0] as! String
            string = string.replacingOccurrences(of: "[", with: "")
            string = string.replacingOccurrences(of: "]", with: "")
            let result = self.convertStringToDictionary(string)
            
            let user = result!["user"]
            let message = result!["data"]
            
            messageDictionary["username"] = user
            messageDictionary["message"] = message
            
            completionHandler(messageDictionary)
        }
    }
    
    func getLocations(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
        socket.on("new location") { (info, msg) -> Void in
            
            var locationDictionary = [String: AnyObject]()
            
            var string = info[0] as! String
            string = string.replacingOccurrences(of: "[", with: "")
            string = string.replacingOccurrences(of: "]", with: "")
            let result = self.convertStringToDictionary(string)
            
            let latitude = result!["lat"]
            let longitude = result!["long"]
            
            locationDictionary["latitude"] = latitude
            locationDictionary["longitude"] = longitude
            
            completionHandler(locationDictionary)
        }
    }
    
    func getUsers(completionHandler: @escaping (_ messageInfo: [String]) -> Void) {
        socket.on("user list") { (info, msg) -> Void in
            
            var users = info[0] as! String
            
            users = users.replacingOccurrences(of: "[", with: "")
            users = users.replacingOccurrences(of: "]", with: "")
            users = users.replacingOccurrences(of: "\"", with: "")
            
            let usersArray : [String] = users.components(separatedBy: ",")
            
            completionHandler(usersArray)
            
            PhoneData.usersArray = usersArray
            print("User List updated: \(PhoneData.usersArray)")
        }
    }
    
    private func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
