//
//  CreateNewHBTGramPostViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/17/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import Firebase

class CreateNewPostViewController: UIViewController, PostPhotoCellDelegator {
    // Instance of the storage
    let storage = Storage.storage()
    
    // The static variable which hold the photo position that is going to be removed
    static var photoPositionToRemove = 0
    
    // The array of images that the post is going to have
    var postPhotos: [UIImage] = []
    
    // Post repository
    let postRepository = PostRepository()
    
    // Photo repository
    let photoRepository = PhotoRepository()
    
    // Additional assets
    let additionAssets = AdditionalAssets()
    
    // Content of the post which is going to be created
    @IBOutlet weak var postContentToPost: UITextView!
    
    // The button to start choosing photo
    @IBAction func choosePhotoButton(_ sender: UIButton) {
        // Call the function to show the file picker so that the user can pick the image to post
        showImagePickerController()
    }
    
    // The table view which will show photos of the post which is going to be created
    @IBOutlet weak var postPhotoToPost: UITableView!
    
    // The button which will create the post
    @IBAction func createPostButton(_ sender: UIButton) {
        createNewPostObject(postContent: postContentToPost.text, numOfImages: postPhotos.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate method to get data for the table view
        postPhotoToPost.dataSource = self
        
        // Register the photo cell for the table view
        postPhotoToPost.register(UINib(nibName: "PostPhotoCell", bundle: nil), forCellReuseIdentifier: "postPhotoCell")
    }
    
    // The function to delete a photo out of the array of photo and update the table view
    func deletePhoto () {
        // Remove the element at the selected position
        postPhotos.remove(at: CreateNewPostViewController.photoPositionToRemove)
        
        // Reload the table view
        postPhotoToPost.reloadData()
    }
    
    //********************************************** CREATE NEW POST SEQUENCE **********************************************
    /*
     In this sequence, we will do these things
     1. Get info of the currently logged in user
     2. Create new post for the user and create it in the post collection of the database
     3. Upload images of the post
     4. Upload their URLs to the post photo collection of the database
     5. Label the image of the post and add labels to the post photo label collection of the database
     */
    
    // The function to create new post object in the database
    func createNewPostObject(postContent: String, numOfImages: Int) {
        // Call the function to create new post
        postRepository.createNewPost(postContent: postContent, numOfImages: numOfImages) { (createdPostId) in
            // Loop through all images of the post to be created and add them all to the database and storage
            for image in self.postPhotos {
                // Run this in the background
                DispatchQueue.global(qos: .background).async {
                    // Call the function to add all photos to the database and also upload them to the storage
                    self.uploadPhotoToDatabaseAndStorage(postId: createdPostId, image: image)
                }
            }
        }
    }
    
    // The function to upload photo to the database as well as storage
    // the function will also label the uploaded image
    func uploadPhotoToDatabaseAndStorage(postId: String, image: UIImage) {
        // Call the function to upload new image to the storage
        additionAssets.uploadPhotoToDatabase(reference: "HBTGramPostPhotos", image: image) { (imageURL) in
            // Call the function to create new post photo object in the database
            self.photoRepository.addNewPostPhotoToDatabase(imageURL: imageURL, postId: postId) { (photoId) in
                // Call the function to start labeling the uploaded image
                self.photoRepository.labelImage(imageId: photoId, image: image)
            }
        }
    }
    //********************************************** END CREATE NEW POST SEQUENCE **********************************************
}

// Extension for the image picker
extension CreateNewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // The function to show the image chooser to the user
    func showImagePickerController() {
        // The image picker object
        let imagePicker = UIImagePickerController()
        
        // Let the delegate to the self and let the user edit the image so that the user can crop or do other things
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Present the image file chooser
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //test()
        //print(imageURL)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Add new image to the array and update the table view
            postPhotos.append(image)
            
            // Reload the table view
            postPhotoToPost.reloadData()
        } else if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Add new image to the array and update the table view
            postPhotos.append(originalImage)
            
            // Reload the table view
            postPhotoToPost.reloadData()
        }
        
        // Dismiss the image file chooser when the image selection is done
        dismiss(animated: true, completion: nil)
    }
}

// Extension for the table view
extension CreateNewPostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a cell as a post photo holder
        let cell = postPhotoToPost.dequeueReusableCell(withIdentifier: "postPhotoCell", for: indexPath) as! PostPhotoCell
        
        // Set the image in the cell
        cell.postPhotoView.image = postPhotos[indexPath.row]
        
        // Set the image position for the image
        cell.photoNumber = indexPath.row
        
        // Delegate so that the cell will be able to call the function to delete a photo
        cell.delegate = self
        
        // Return the cell
        return cell
    }
    
}


// Protocol which will be used to enable the table view cell to delete a photo of the post
protocol PostPhotoCellDelegator {
    func deletePhoto()
}
