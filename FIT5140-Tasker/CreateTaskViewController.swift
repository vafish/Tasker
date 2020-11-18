//
//  CreateTaskViewController.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/3/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit


class CreateTaskViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, searchDelegate {

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    @IBOutlet weak var search: UIButton!
    var databaseController: DatabaseProtocol?
    var locationManager:CLLocationManager!
    var resultSearchController:UISearchController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        search.layer.cornerRadius = 5
        search.layer.borderWidth = 1
        search.layer.borderColor = UIColor.white.cgColor
        databaseController = FirebaseController()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func DoneButtonClick(_ sender: Any) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy/MM/dd HH:mm"


        let dueDate = timeFormatter.string(from: dueDatePicker.date)
        if taskNameTextField.text != "" {
            let name = taskNameTextField.text!
            let descript = descriptionTextField.text!
            let loc = locationTextField.text!
            let _ = databaseController?.addTask(name: name, descript:descript, duedate: dueDate, location: loc, reminder: self.reminderSwitch.isOn)
            
            navigationController?.popViewController(animated: true)
            return
            
        }
    }
    
    
   
    @IBAction func SearchClicked(_ sender: Any) {
        
    }
    
        
    
    

 

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchTableViewController {
                    destination.delegate = self
                }
    }
   
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func finishSearch(controller: SearchTableViewController) {
        self.locationTextField.text = controller.searchController?.searchBar.text
        controller.navigationController?.popViewController(animated: true)
    }
    func cancelSearch(controller: SearchTableViewController) {
        self.locationTextField.text = ""
        controller.navigationController?.popViewController(animated: true)
    }
}



