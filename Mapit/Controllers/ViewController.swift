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
    
    private var documentRef: DocumentReference?
    private(set) var mapits = [Mapit]()
    
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
        configureObservers()
    }
    
    private func configureObservers() {
        
        db.collection("mapits").addSnapshotListener {  [weak self] snapshot, error in
            
            guard let snapshot = snapshot, error == nil else {
                print("error fetching document")
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                
                if diff.type == .added {
                    if let mapit = Mapit(diff.document) {
                        self?.mapits.append(mapit)
                        self?.updateAnnotations()
                    }
                } else if diff.type == .removed {
                    if let mapit = Mapit(diff.document) {
                        if let mapitsList = self?.mapits {
                            self?.mapits = mapitsList.filter { $0.documentId != mapit.documentId }
                            self?.updateAnnotations()
                        }
                        
                    }
                }
            }
        }
    }
    
    
    private func setupUI() {
        
        mapitButton.layer.cornerRadius = 6.0
        mapitButton.layer.masksToBounds = true
    }


    @IBAction func mapitButtonPressed(_ sender: Any) {
        savePinToFirebase()
    }
    
    private func updateAnnotations() {
        
        DispatchQueue.main.async {
            self.mapits.forEach {
                self.addMapitToMap(mapit: $0)
            }
        }
        
    }
    
    private func addMapitToMap(mapit: Mapit) {
        
        let annotation = MKPointAnnotation()
            annotation.title = "Here"
            annotation.subtitle = mapit.reportedDate.formatAsString()
            annotation.coordinate =  CLLocationCoordinate2D(latitude: mapit.latitude, longitude: mapit.longitude)
        
        self.mapView.addAnnotation(annotation)
        
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        self.mapView.setRegion(region, animated: true)
    }
    
    
    private func savePinToFirebase() {
        
        guard let location = self.locationManager.location else {
            return
        }
        
        var mapit = Mapit(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        documentRef = db.collection("mapits").addDocument(data: mapit.toDictionary()) { [weak self] error in
            
            if let error = error {
                print(error)
               
            } else {
                mapit.documentId = self?.documentRef?.documentID
                print("location saved")
                self?.addMapitToMap(mapit: mapit)
            }
        }
    }
}

