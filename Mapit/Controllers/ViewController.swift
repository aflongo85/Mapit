//
//  ViewController.swift
//  Mapit
//
//  Created by Andrea on 18/03/2019.
//  Copyright © 2019 AFL. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    private lazy var db: Firestore = {
        
        let firestoreDB = Firestore.firestore()
        let settings = firestoreDB.settings
        settings.areTimestampsInSnapshotsEnabled = true
        firestoreDB.settings = settings
        
        return firestoreDB
        }()
    
    private lazy var locationManager: CLLocationManager = {
        
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    
    @IBOutlet weak var mapitButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        setupUI()
    }
    
    
    private func setupUI() {
        
        mapitButton.layer.cornerRadius = 6.0
        mapitButton.layer.masksToBounds = true
    }


    @IBAction func mapitButtonPressed(_ sender: Any) {
        
        guard let location = self.locationManager.location else {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.title = "Here"
        annotation.subtitle = "nownownownownownownow"
        annotation.coordinate =  location.coordinate
        
        self.mapView.addAnnotation(annotation);
        
        savePinToFirebase(coordinates: location.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        self.mapView.setRegion(region, animated: true)
    }
    
    private func savePinToFirebase(coordinates: CLLocationCoordinate2D) {
        db.collection("mapits").addDocument(data: ["latitude": coordinates.latitude, "longitude": coordinates.longitude]) { error in
            
            if let error = error {
                print(error)
            } else {
                print("location saved")
            }
        }
    }
}

