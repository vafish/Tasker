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

class EditTasklViewController: UIViewController{

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var reminderSwitch: UISwitch!
    var databaseController: DatabaseProtocol?
    var task:Task?
    var delegate: editTaskDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = FirebaseController()

        delegate?.showTask(controller: self)
        if task != nil{
            nameTextField.text = task?.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            datePicker.date =  dateFormatter.date(from: task!.duedate)!
            reminderSwitch.isOn = ((task?.reminder) == true)
            
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func DoneButtonClicked(_ sender: Any) {
        
        let newTask = Task()
        newTask.name = nameTextField.text!
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        newTask.duedate = timeFormatter.string(from: datePicker.date)
        newTask.reminder = reminderSwitch.isOn
        let _ = databaseController?.editTask(oldtask: self.task!, newtask: newTask)
            
        navigationController?.popViewController(animated: true)
        return
            
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
  

}
