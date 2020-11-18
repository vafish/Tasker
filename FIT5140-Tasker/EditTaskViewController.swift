//
//  EditTasklViewController.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/11/20.
//  Copyright © 2020 Monash University. All rights reserved.
//


protocol editTaskDelegate {
    func showTask(controller: EditTasklViewController)
}


import UIKit

class EditTasklViewController: UIViewController, searchDelegate{
    
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var locationTextField: UITextField!
    var databaseController: DatabaseProtocol?
    var task:Task?
    var delegate: editTaskDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = FirebaseController()

        delegate?.showTask(controller: self)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        if task != nil{
            nameTextField.text = task?.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            datePicker.date =  dateFormatter.date(from: task!.duedate!)!
            descriptionTextField.text = task?.descript
            locationTextField.text = task?.location
            reminderSwitch.isOn = ((task?.reminder) == true)
            
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func SearchClicked(_ sender: Any) {
    }
    @IBAction func DoneButtonClicked(_ sender: Any) {
        
        let newTask = Task()
        newTask.name = nameTextField.text!
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        newTask.duedate = timeFormatter.string(from: datePicker.date)
        newTask.reminder = reminderSwitch.isOn
        newTask.descript = descriptionTextField.text!
        newTask.location = locationTextField.text!
        let _ = databaseController?.editTask(oldtask: self.task!, newtask: newTask)
            
        navigationController?.popViewController(animated: true)
        return
            
        
    }
    
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SearchTableViewController {
                    destination.delegate = self
                }
    }

    
    func finishSearch(controller: SearchTableViewController) {
        self.locationTextField.text = controller.searchController?.searchBar.text
        controller.navigationController?.popViewController(animated: true)
    }
    func cancelSearch(controller: SearchTableViewController) {
        self.locationTextField.text = ""
        controller.navigationController?.popViewController(animated: true)
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

}
