//
//  CreateTaskViewController.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/3/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit

class CreateTaskViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationDetail: UILabel!
    var databaseController: DatabaseProtocol?
    var locationManager:CLLocationManager!
    var currentLocationStr = "Current location"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        databaseController = FirebaseController()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func DoneButtonClick(_ sender: Any) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = DateFormatter.Style.short
        timeFormatter.timeStyle = DateFormatter.Style.short

        let dueDate = timeFormatter.string(from: dueDatePicker.date)
        if taskNameTextField.text != "" {
            let name = taskNameTextField.text!
            let abilities = dueDate
            let _ = databaseController?.addSuperHero(name: name, abilities: abilities)
            
            
            navigationController?.popViewController(animated: true)
            return
            
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
            determineCurrentLocation()
	        }

        //MARK:- CLLocationManagerDelegate Methods

    
    

    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(mRegion, animated: true)

        // Get user's Current Location and Drop a pin
    let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
        mkAnnotation.title = self.setUsersClosestLocation(mLattitude: mUserLocation.coordinate.latitude, mLongitude: mUserLocation.coordinate.longitude)
        mapView.addAnnotation(mkAnnotation)
    }
    //MARK:- Intance Methods

    func setUsersClosestLocation(mLattitude: CLLocationDegrees, mLongitude: CLLocationDegrees) -> String {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: mLattitude, longitude: mLongitude)

        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in

            if let mPlacemark = placemarks{
                if let dict = mPlacemark[0].addressDictionary as? [String: Any]{
                    if let Name = dict["Name"] as? String{
                        if let City = dict["City"] as? String{
                            self.currentLocationStr = Name + ", " + City
                        }
                    }
                }
            }
        }
        return currentLocationStr
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
