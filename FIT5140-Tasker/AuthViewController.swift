//
//  ViewController.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 10/29/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class AuthViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    
    var databaseController:FirebaseController?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var register: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        login.layer.cornerRadius = 5
        login.layer.borderWidth = 1
        login.layer.borderColor = UIColor.white.cgColor
        register.layer.cornerRadius = 5
        register.layer.borderWidth = 1
        register.layer.borderColor = UIColor.white.cgColor
        // Do any additional setup after loading the view.
    }
    @IBAction func loginToAccount(_ sender: Any) {
        guard let password = passwordTextField.text else {
         displayErrorMessage("Please enter a password")
         return
         }
         guard let email = emailTextField.text else {
         displayErrorMessage("Please enter an email address")
         return
         }

        Auth.auth().signIn(withEmail: email, password: password) { [self] (user, error) in
            if let error = error {
                self.displayErrorMessage(error.localizedDescription)
                
                
                databaseController = FirebaseController()
            }
         }

    }
    @IBAction func registerAccount(_ sender: Any) {
        
       
        
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message:
                                                errorMessage, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Dismiss", style:
                                                 UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
                                                 }
    
    
    

     override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
     if user != nil {
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
     }
     })
     }

     override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
     Auth.auth().removeStateDidChangeListener(handle!)
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
