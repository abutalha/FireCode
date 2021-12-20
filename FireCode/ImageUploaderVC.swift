//
//  ImageUploaderVC.swift
//  FireCode
//
//  Created by AbuTalha on 20/12/2021.
//

import UIKit
import FirebaseStorage

class ImageUploaderVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellID", for: indexPath) as! ImageCell
        cell.cellImage.image = imgArray[indexPath.row]
        return cell
    }
    
    let picker = UIImagePickerController()
    var imgArray = [UIImage]()
    
    @IBOutlet weak var imageCloud: UIImageView!
    @IBOutlet weak var kbStatus: UILabel!
    @IBOutlet weak var imagesCollection: UICollectionView!
    @IBOutlet weak var uploadProgress: UIProgressView!
    @IBOutlet weak var downloadProgress: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureControls()
    }

    // MARK: Configuration for UIImagePickerView and UICollectionView
    func configureControls() {
        
        // UIPickerView
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.title = "Choose Image"
        
        // UICollectionView
        imagesCollection.delegate = self
        imagesCollection.dataSource = self
     
        // ProgressViews
        downloadProgress.progress = 0
        uploadProgress.progress = 0
    }
    
    // MARK: IBActions
    @IBAction func onDownloadPressed(_ sender: UIButton) {
        downloadImagesFromCloud()
    }
    
    @IBAction func onUploadPressed(_ sender: UIButton) {
        
        // Show Image Library to choose an image ✅
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: Download Multiple images from FB and populate in a Collection View
    func downloadImagesFromCloud() {
        
        let storageRef = Storage.storage().reference()
        let folderRef = storageRef.child("Cloud")

        folderRef.listAll { snapshot, error in
            print (snapshot.items.count)
            
            for (index, item) in snapshot.items.enumerated() {
                // MARK: Download the image and save it to an array
                item.getData(maxSize: Int64.max) { data, error in
                    guard let data = data else { return }
                    self.imgArray.append(UIImage(data: data)!)
                    DispatchQueue.main.async {
                        self.imagesCollection.reloadData()
                        self.downloadProgress.progress =  Float(index + 1 / snapshot.items.count)
                    }
                }
            }
        }
    }
    
    // MARK: Handle ImagePicker Delegate and Upload the captured image to FB Storage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Load the image into imageview ✅
        let image = info[.originalImage] as! UIImage
        self.imageCloud.image = image
        
        // Convert the image to data ✅
        let data = image.pngData()

        // Handle for FB Storage ✅
        let fbStorage = Storage.storage().reference()
        
        // Generate random number to save it as new image for every upload
        let randomNumber = Int.random(in: 1...2000)
        
        // Handle for the image path and name to be saved
        let imgRef = fbStorage.child("Cloud/newimage\(randomNumber).png")
        
        // Put the data into FB and track its progress
        let task = imgRef.putData(data!)
        task.observe(.progress) { snapshot in
            
            // Its UI update, so we must run in main thread
            DispatchQueue.main.async {
                self.kbStatus.text = "\(snapshot.progress!.completedUnitCount / 1024) KB"
                self.uploadProgress.progress = Float(snapshot.progress?.fractionCompleted ?? 1.0)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}


class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    
}
