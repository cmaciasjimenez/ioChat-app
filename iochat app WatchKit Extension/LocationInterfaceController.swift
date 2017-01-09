//
//  LocationInterfaceController.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 08/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class LocationInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    // Outlets
    
    @IBOutlet var sendLocationButtonLabel: WKInterfaceLabel!
    @IBOutlet var map: WKInterfaceMap!
    
    @IBAction func sendLocationButtonPressed() {
        locationManager.requestLocation()
        sendLocationButtonLabel.setText("Sending...")
    }
    
    @IBAction func removePinsMenuItem() {
        map.removeAllAnnotations()
        print("Annotations removed")
    }
    
    // Variables
    
    let locationManager = CLLocationManager()
    var locationCoordinates = (latitude: 0.0, longitude: 0.0)
    
    // Functions
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.setTitle("Map")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LocationInterfaceController.updateMap(notification:)), name: NSNotification.Name(rawValue: "sendLatAndLong"),  object: nil)
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        sendLocationButtonLabel.setText("Send location")
    }
    
    func updateMap(notification: NSNotification) {
        
        if let message = notification.userInfo?["latAndLong"] as? String {
            
            let fullLocArr : [String] = message.components(separatedBy: ">> ")
            let latString = fullLocArr[0]
            let longString = fullLocArr[1]
            
            let lat = Double(latString)
            let long = Double(longString)
                        
            let mapLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, long!)
            
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(mapLocation, span)
            self.map.setRegion(region)
            self.map.addAnnotation(mapLocation, with: .red)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (CLLocationManager.locationServicesEnabled()) {
            print("Location Services enabled")
        } else {
            print("Location Services not enabled")
        }
        
        let a = CLLocationManager.authorizationStatus()
        print("Authorization status: ", a.rawValue)
        
        if let location = locations.first {
            
            //print("Found user's location: \(location)")
            //print("Latitude: \(location.coordinate.latitude)")
            //print("Longitude: \(location.coordinate.longitude)")
            
            let coordinates = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendCoords"), object: nil, userInfo: coordinates)
            sendLocationButtonLabel.setText("Location Sent")
            self.dismiss()
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
