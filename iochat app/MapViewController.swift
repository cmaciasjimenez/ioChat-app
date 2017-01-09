//
//  MapViewController.swift
//  iochat app
//
//  Created by Carlos Macias Jimenez on 09/12/2016.
//  Copyright © 2016 Carlos Macias Jimenez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func sendLocationButtonPressed(_ sender: Any) {
        print("pressed")
        locationManager.requestLocation()
        SocketIOManager.sharedInstance.sendMessage(message: "Has shared his iPhone location")
    }
    
    // Variables
    
    var locationManager: CLLocationManager!
    
    // Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "Map"
        
        if let coordinates = UserDefaults.standard.value(forKey: "Coordinates") {
            locateCoordinates(coordinates: coordinates as! [CLLocationDegrees])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locateCoordinates(coordinates: [CLLocationDegrees]) {
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let position = CLLocationCoordinate2DMake(coordinates[0], coordinates[1])
        let region = MKCoordinateRegionMake(position, span)
        mapView.setRegion(region, animated: true)
        
        // Add pin
        let annotation = MKPointAnnotation()
        annotation.title = "\(coordinates[0]), \(coordinates[1])"
        annotation.coordinate = position
        mapView.addAnnotation(annotation)        
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
            
            let position = [location.coordinate.latitude, location.coordinate.longitude]
            locateCoordinates(coordinates: position)
            
            // -> To web
            let latitude = location.coordinate.latitude as Double
            let longitude = location.coordinate.longitude as Double
            let loc = "\(latitude), \(longitude)"
            SocketIOManager.sharedInstance.sendLocation(location: loc)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
