//
//  RegisterViewController.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/1/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class RegisterViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    var image_url: String?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
            //tap.cancelsTouchesInView = false
    
        view.addGestureRecognizer(tap)
        image_url = "https://avatars.abstractapi.com/v1/?api_key=1bded16c65944ac7a25bc206cd7a6e6e&name="
        // Do any additional setup after loading the view.
    }
    
    @IBAction func generateAvatar(_ sender: Any) {
        if usernameTextField.text != ""{
            self.image_url = self.image_url! + usernameTextField.text!
        
        guard let imageURL = URL(string: self.image_url!) else { return }

                // just not to cause a deadlock in UI!
            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: imageURL) else { return }

                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
            
        }
        else{
            displayErrorMessage("Please enter a username first")
        }
    }
    
    @IBAction func Register(_ sender: Any) {
        guard let password = passwordTextField.text else {
         displayErrorMessage("Please enter a password")
         return
         }
         guard let email = emailTextField.text else {
         displayErrorMessage("Please enter an email address")
         return
         }

         Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
            self.displayErrorMessage(error.localizedDescription)
            }
            
            let uid = Auth.auth().currentUser?.uid
            let ref = Firestore.firestore().collection("users").document(uid!)
            if uid != nil{
                ref.setData([
                    "email": self.emailTextField.text!,
                    "password": self.passwordTextField.text!,
                    "username": self.usernameTextField.text!,
                    "imageUrl": self.image_url!,
                    "uid": uid! as String
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                
            }

         }
    }
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message:
                                                errorMessage, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Dismiss", style:
                                                 UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
                                                 }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
}
