//
//  TaskerViewController.swift
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

class TaskerViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let reuseIdentifier = "imageCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 3
    
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var managedObjectContext: NSManagedObjectContext?
    var usersReference = Firestore.firestore().collection("users")
    var storageReference = Storage.storage()
    var snapshotListener: ListenerRegistration?
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBAction func logOut(_ sender: Any) {
        do {
         try Auth.auth().signOut()
         } catch {
         print("Log out error: \(error.localizedDescription)")
         }

         navigationController?.popViewController(animated: true)
    }
//    @IBAction func logOutOfAccount(_ sender: Any) {
//        do {
//         try Auth.auth().signOut()
//         } catch {
//         print("Log out error: \(error.localizedDescription)")
//         }
//
//         navigationController?.popViewController(animated: true)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistantContainer?.viewContext
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener{ (auth, user) in
            guard let userID = Auth.auth().currentUser?.uid else {             
             return
             }

            let userImagesRef = self.usersReference.document("\(userID)").collection("images")

            self.snapshotListener = userImagesRef.addSnapshotListener { (querySnapshot, error) in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error!)")
                return
                }

                querySnapshot!.documentChanges.forEach { change in
                let imageName = change.document.documentID
                let imageURL = change.document.data()["url"] as! String

                if change.type == .added {
                    if self.imagePathList.contains(imageName) == false {
                        if let image = self.loadImageData(filename: imageName) {
                        self.imageList.append(image)
                        self.imagePathList.append(imageName)
                        self.collectionView.reloadSections([0])
                        }
                        else {
                            self.storageReference.reference(forURL: imageURL).getData(maxSize: 5 * 1024 * 1024,
                            completion: { (data, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                     }
                                else if let data = data, let image = UIImage(data: data) {
                                     self.imageList.append(image)
                                     self.imagePathList.append(imageName)
                                     self.saveImageData(filename: imageName, imageData: data)
                                     self.collectionView.reloadSections([0])
                                     }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        snapshotListener?.remove()
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    func saveImageData(filename: String, imageData: Data) {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    let fileURL = documentsDirectory.appendingPathComponent(filename)

    do {
    try imageData.write(to: fileURL)
    } catch {
    print("Error writing file: \(error.localizedDescription)")
    }
    }
    
    // MARK: - Helper Functions
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]

        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        
        return image
    }


    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
    
        cell.backgroundColor = .secondarySystemFill
        cell.imageView.image = imageList[indexPath.row]
    
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }


}
