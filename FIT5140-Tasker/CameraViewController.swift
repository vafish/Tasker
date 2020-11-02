//
//  CameraViewController.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 10/29/20.
//  Copyright © 2020 Monash University. All rights reserved.
//
import UIKit
import CoreData
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var managedObjectContext: NSManagedObjectContext?
    var usersReference = Firestore.firestore().collection("users")
    var storageReference = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistantContainer?.viewContext
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: "Select Option:", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            controller.sourceType = .camera
            self.present(controller, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
        
        let albumAction = UIAlertAction(title: "Photo Album", style: .default) { action in
            controller.sourceType = .savedPhotosAlbum
            self.present(controller, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(cameraAction)
            
        }
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        guard let image = imageView.image else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
        guard let userID = Auth.auth().currentUser?.uid else {
         displayMessage("Cannot upload image until logged in", "Error")
         return
         }
        let date = UInt(Date().timeIntervalSince1970)
        let filename = "\(date).jpg"
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            displayMessage("Image data could not be compressed.", "Error")
            return
        }
        let imageRef = storageReference.child("\(userID)/\(date)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) { (meta, error) in
        if error != nil {
        self.displayMessage("Could not upload image to firebase", "Error")
        }
        else {
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url
                else {
                    print("Download URL not found")
                    return
                    }

                let userImageRef = self.usersReference.document("\(userID)")
                userImageRef.collection("images").document("\(date)").setData([
                "url": "\(downloadURL)"
                ])
                self.displayMessage("Image uploaded to Firebase", "Success")
                    }
                }
            }
    
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            
            let newImage = NSEntityDescription.insertNewObject(forEntityName:
              "ImageMetaData", into: managedObjectContext!) as! ImageMetaData
            newImage.filename = filename

            try self.managedObjectContext?.save()
            self.navigationController?.popViewController(animated: true)
        } catch {
            displayMessage(error.localizedDescription, "Error")
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
