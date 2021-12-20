//
//  ViewController.swift
//  FireCode
//
//  Created by AbuTalha on 07/12/2021.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

// MARK: Firebase Database ✅
// MARK: 1. Create Firebase Account (if not already done) ✅
// MARK: 2. Create iOS App ✅
// MARK: 3. Register the app ✅
// MARK: 4. Download Config File ✅
// MARK: 5. Add Firebase SDK (using SPM) ✅
// MARK: 6. Add Initialization Code ✅
// MARK: 7. Build App and Continue ✅
// MARK: 8. Setup Database ✅
// MARK: 9. Add your code to CRUD
// MARK: 10. GO HOME (after 5:00 pm) ✅

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    //MARK: Create handle for the FDB ✅
    let db = Database.database().reference()
    let dbStore = Firestore.firestore()
    
    let picker = UIImagePickerController()
    
    // MARK: Outlets ✅
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var lblOutput: UILabel!
        
    @IBAction func savePressed(_ sender: UIButton) {
        writeToRealtimeDB()
        writeToFirestore()
        downloadFileFromStore()
    }
    
    
    func downloadFileFromStore() {
        
        let imageURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/firestorage-9f9a8.appspot.com/o/flower.jpeg?alt=media&token=3a0513e5-fe32-4fa4-b13f-3c3e786bc626")!
        
        URLSession.shared.dataTask(with: imageURL) { (data, _, error) in

            if (error == nil) {
                guard let data = data else { return }
                print (data)
            }
        }
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        
        db.child("Cars").child("American").removeValue()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.title = "Choose image"
        present(picker, animated: true, completion: nil)


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeRealtimeDB()
        observeFirestoreDB()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        db.child("Cars").removeAllObservers()
    }
    
    // TODO: Write to Firestore (Collections) ✅
    func writeToFirestore() {
        dbStore.collection("Places").addDocument(
            data: ["name" : txtInput.text ?? ""])
    }
    
    // TODO: Read from Firestore (Collections) ✅
    func observeFirestoreDB() {
         
        dbStore.collection("Places").addSnapshotListener { snapshot, error in

            // Process the documents and update UI
            if let documents = snapshot?.documents {
                for doc in documents {
                    print (doc.data())
                }
            }
        }
    }
    
    // TODO: Write to Realtime Database ✅
    func writeToRealtimeDB() {
        
        let keysToStore = ["Medicine" : "Panadol",
                           "Description": "It will make you weaker",
                           "Brand": "NoBrand"]
        
        db.child("Tibb").child("Alopathy").child("Description").setValue(txtInput.text!)

        let array = ["OnGround", "OnAir", "OnSea"]
        db.child("Cars").child("Saudi").setValue(array)
        
    }
    
    // TODO: Read from Realtime Database ✅
    func observeRealtimeDB() {
        // TODO: Read from Realtime Database
        db.child("Cars").observe(.childChanged) { [self] snapshot in
            
            // process the data and update UI
            print ("-----Observing-----")
            self.lblOutput.text = snapshot.value as? String
            print (snapshot)
            
        } withCancel: { error in
            print (error.localizedDescription)
        }
    }
    
    // TODO: Upload an image to Storage ✅
    func uploadFileToStore() {

//        // Create a root reference
//        let storageRef = storage.reference()
//
//        // Get a reference to the storage service using the default Firebase App
//         let storage = Storage.storage()
//
//        // Create a storage reference from our storage service
//        let storageRef = storage.reference()
//
//        // Create a reference to "mountains.jpg"
//        let mountainsRef = storageRef.child("mountains.jpg")
//
//        // Create a reference to 'images/mountains.jpg'
//        let mountainImagesRef = storageRef.child("images/mountains.jpg")
//
//        // While the file names are the same, the references point to different files
//        mountainsRef.name == mountainImagesRef.name;            // true
//        mountainsRef.fullPath == mountainImagesRef.fullPath;    // false
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.title = "Choose image"
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        

        
        let imageURL = info[.originalImage] as! UIImage
        print (imageURL)
        
        //let data = imageURL.jpegData(compressionQuality: 0.8)!
        let data = imageURL.pngData()

        guard let data = data else { return }
        
        let stRef = Storage.storage().reference()
        let fileRef = stRef.child("new/mount.png")


        print (stRef.root())
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"

        let upload = fileRef.putData(data, metadata: nil)
//        fileRef.putData(data, metadata: nil) { snapshot, err in
//            print ("upload in progress")
//            print (snapshot)
//        }
        upload.resume()
        upload.observe(.progress) { snapshot in
            print (snapshot.progress?.completedUnitCount)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}

