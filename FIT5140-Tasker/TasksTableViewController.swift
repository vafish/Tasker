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
protocol AddSuperHeroDelegate: AnyObject {
    func addSuperHero(newHero: SuperHero) -> Bool
}
class TasksTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var imageView: UIImageView!
    var managedObjectContext: NSManagedObjectContext?
    let SECTION_HEROES = 0
    let SECTION_INFO = 1
    let CELL_HERO = "taskCell"
    let CELL_INFO = "totalHeroesCell"
    
    var allHeroes: [SuperHero] = []
    var filteredHeroes: [SuperHero] = []
    weak var superHeroDelegate: AddSuperHeroDelegate?
    var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .all

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistantContainer?.viewContext
        databaseController = FirebaseController()

        filteredHeroes = allHeroes
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Heroes"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredHeroes.count
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            filteredHeroes = allHeroes.filter({ (hero: SuperHero) -> Bool in
                return hero.name.lowercased().contains(searchText) ?? false
            })
        } else {
            filteredHeroes = allHeroes
        }
        
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        print("Deleted")
        databaseController?.deleteSuperHero(hero: filteredHeroes[indexPath.row])
        self.filteredHeroes.remove(at: indexPath.row)
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
        if indexPath.section == SECTION_HEROES {
            let heroCell = tableView.dequeueReusableCell(withIdentifier: CELL_HERO,
                for: indexPath) as! TaskTableViewCell
            let hero = filteredHeroes[indexPath.row]
            
            heroCell.taskNameTextField.text = hero.name
            heroCell.dueDateTextField.text = hero.abilities
            
            return heroCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
        cell.textLabel?.text = "\(allHeroes.count) heroes in the database"
        cell.textLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - Database Listener
    func onHeroListChange(change: DatabaseChange, heroes: [SuperHero]) {
        allHeroes = heroes
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func onTeamChange(change: DatabaseChange, teamHeroes: [SuperHero]) {
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
