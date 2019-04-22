//
//  ViewController.swift
//  LocationManagerAndMap
//
//  Created by Suraj Prasad on 20/02/19.
//  Copyright © 2019 Suraj Prasad. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var MapViewOutlet: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK:- Global Variables
    var locationManager:CLLocationManager!
    var coordinate : CLLocationCoordinate2D!
    
    //MARK:- Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        MapViewOutlet.delegate = self
        MapViewOutlet.mapType = .standard
        MapViewOutlet.showsUserLocation = true
        MapViewOutlet.showsScale = true
        MapViewOutlet.showsCompass = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                print("Authorised Alwayz Location")
                locationManager!.startUpdatingLocation()
            default:
                locationManager!.requestWhenInUseAuthorization()
                print("request for authorisation")
            }
        }
        else {
            print("Location not Authorised, Turn on location services or GPS")
        }
    }
    //MARK:- IBActions
    //Single Tap anywhere in map to add annotation
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended{
            let locationInView = sender.location(in: MapViewOutlet)
            let tappedCoordinate = MapViewOutlet.convert(locationInView, toCoordinateFrom: MapViewOutlet)
            let annotation = MKPointAnnotation()
            annotation.coordinate = tappedCoordinate
            annotation.title = "Marked Point"
            MapViewOutlet.addAnnotation(annotation)
        }
    }
    //Button action to choose source of Image
    @IBAction func chooseImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController.init(title: "Photo Source", message: "Choose a Source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
                
            else {
                print("Camera Not Available")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    //MARK:- LocationManager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse :
            print("Authorised correctly")
        case .denied, .notDetermined, .restricted :
            locationManager!.requestAlwaysAuthorization()
            print("request for authorisation")
        default : print("nothing to show")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        MapViewOutlet.setRegion(region, animated: true)
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        MapViewOutlet.addAnnotation(myAnnotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    //MARK:- mapView delegate Methods
    //Method for creating draggable pin annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.pinTintColor = .purple
            pinAnnotationView.isDraggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            return pinAnnotationView
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
    }
    //MARK:- imagePicker Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
