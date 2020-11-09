//
//  TasksTableViewController.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/3/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UserNotifications
protocol AddTaskDelegate: AnyObject {
    func addSuperHero(newHero: Task) -> Bool
}
class TasksTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating, UNUserNotificationCenterDelegate {
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var imageView: UIImageView!
    var managedObjectContext: NSManagedObjectContext?
    let SECTION_TASKS = 0
    let SECTION_INFO = 1
    let CELL_TASK = "taskCell"
    
    var allTasks: [Task] = []
    var filteredTasks: [Task] = []
    weak var taskDelegate: AddTaskDelegate?
    var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .all
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistantContainer?.viewContext
        databaseController = FirebaseController()

        filteredTasks = allTasks
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Locations"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        
        
        
//        let center = UNUserNotificationCenter.current()
//
//
//           //Delegate for UNUserNotificationCenterDelegate
//
//
//           //Permission for request alert, soud and badge
//        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
//               // Enable or disable features based on authorization.
//            if(!granted){
//                print("not accept authorization")
//            }else{
//                print("accept authorization")
//
//            }
//        }
//        let content = UNMutableNotificationContent()
//        content.title = "Reminder"
//        content.body = "Open the app for see"
//
//        let date = Date().addingTimeInterval(5)
//        let dateComp = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from:date)
//        let identifier = UUID().uuidString
//        //Receive notification after 5 sec
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        //Receive with date
////        var dateInfo = DateComponents()
////        dateInfo.day = 9 //Put your day
////        dateInfo.month = 11 //Put your month
////        dateInfo.year = 2020 // Put your year
////        dateInfo.hour = 17//Put your hour
////        dateInfo.minute = 43 //Put your minutes
//
//            //specify if repeats or no
//        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
//
//        let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
//
//        print(identifier)
//        center.add(request) { (error) in
//            if let error = error {
//                print("Error \(error.localizedDescription)")
//            }else{
//                print("send!!")
//            }
//        }
//        center.add(request)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    
    @IBAction func Note(_ sender: Any) {
        setNotification()
    
//        let alertController = UIAlertController(title: "Local Notification", message: nil, preferredStyle: .actionSheet)
//
//        let setLocalNotificationAction = UIAlertAction(title: "Set", style: .default) { (action) in
//            LocalNotificationManager.setNotification(5, of: .seconds, repeats: false, title: "Reminder", body: "You have a scheduled task: " + self.filteredTasks[0].name, userInfo: [Auth.auth().currentUser?.uid  : ["hello" : Auth.auth().currentUser?.displayName ]], date: self.filteredTasks[0].duedate)
//        }
//        let removeLocalNotificationAction = UIAlertAction(title: "Remove", style: .default) { (action) in
//            LocalNotificationManager.cancel()
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
//        alertController.addAction(setLocalNotificationAction)
//        alertController.addAction(removeLocalNotificationAction)
//        alertController.addAction(cancelAction)
//        self.present(alertController, animated: true, completion: nil)
    }
    
    func setNotification(){
        if self.filteredTasks.isEmpty{
            let alert = UIAlertController(title: "Empty",
                                          message: "No task at the moment ",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return}
        for task in self.filteredTasks{
            
           
                LocalNotificationManager.setNotification(5, of: .seconds, repeats: true, title: "Reminder", body: "You have a scheduled task: " + task.name, userInfo: [Auth.auth().currentUser?.uid  : ["hello" : Auth.auth().currentUser?.displayName ]], date: task.duedate)
                
            
            
        }
        let alert = UIAlertController(title: "Set Reminder",
                                      message: "Reminder are set as you wish :) ",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredTasks.count
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            filteredTasks = allTasks.filter({ (hero: Task) -> Bool in
                return hero.name.lowercased().contains(searchText) ?? false
            })
        } else {
            filteredTasks = allTasks
        }
        
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        print("Deleted")
        databaseController?.deleteTask(task: filteredTasks[indexPath.row])
        self.filteredTasks.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
      }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func Logout(_ sender: Any) {
        do {
         try Auth.auth().signOut()
         } catch {
         print("Log out error: \(error.localizedDescription)")
         }

         navigationController?.popViewController(animated: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        databaseController?.addListener(listener: self)
        handle = Auth.auth().addStateDidChangeListener{ (auth, user) in
            guard let userID = Auth.auth().currentUser?.uid else {
             return
             }
            
            Firestore.firestore().collection("users").getDocuments{(doc, error)in
                if let err = error{
                    debugPrint("Fetch error: \(err)")
                }
                else{
                    guard let snap = doc else{return}
                    for document in snap.documents{
                        let data = document.data()
                        let id = data["uid"]
                        if (id != nil && id as! String == userID) {
                            self.title = "Hello" + (data["username"] as! String)
                            let url = data["imageUrl"]
                            guard let imageURL = URL(string: url as! String) else { return }

                                    // just not to cause a deadlock in UI!
                                DispatchQueue.global().async {
                                    guard let imageData = try? Data(contentsOf: imageURL) else { return }

                                    let image = UIImage(data: imageData)
                                    DispatchQueue.main.async {
                                        self.imageView.image = image
                                    }
                                }
                            
                        }
                        
                    }
                }
            }

        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        databaseController?.addListener(listener: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_TASK,
            for: indexPath) as! TaskTableViewCell
        let task = filteredTasks[indexPath.row]
        
        taskCell.taskNameTextField.text = task.name
        taskCell.dueDateTextField.text = task.duedate
            
        return taskCell
        

        
    }

    // MARK: - Database Listener
    func onTaskListChange(change: DatabaseChange, tasks: [Task]) {
        allTasks = tasks
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func onTeamChange(change: DatabaseChange, teamHeroes: [Task]) {
        // Do nothing not called
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
            preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
            style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
        
    
    
    

}
