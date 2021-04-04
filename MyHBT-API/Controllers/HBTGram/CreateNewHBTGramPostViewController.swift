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
    
    let mAuth = Auth.auth()
    
    // The array of images that the post is going to have
    var postPhotos: [UIImage] = []
    
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
        getInfoOfCurrentUserAndCreatePost(postContent: postContentToPost.text, numOfImages: postPhotos.count)
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
    
    // 1. The function to get info of the currently logged in user and call the function to create new post in the database for the post
    func getInfoOfCurrentUserAndCreatePost(postContent: String, numOfImages: Int) {
        // The URL to get info of the currently logged in user
        let getCurrentUserInfoURL = URL(string: "\(AppResource.init().APIURL)/api/v1/users/getUserInfoBasedOnToken")
        
        // Create the request for getting info of the currently logged in user
        var getCurrentUserInfoRequest = URLRequest(url: getCurrentUserInfoURL!)
        
        // Let the method to get user info be GET
        getCurrentUserInfoRequest.httpMethod = "GET"
        
        // Get user info task
        let getCurrentUserInfoTask = URLSession.shared.dataTask(with: getCurrentUserInfoRequest) { (data, response, error) in
            // Check for error
            if let error = error {
                // Report the error
                print("There seem to be an error \(error)")
            }
            
            // Get data from the response
            if let data = data {
                // Convert the JSON data string into the NSDictionary
                do {
                    if let convertedJSONIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as?
                        NSDictionary {
                        // Get the data (sign up token)
                        let dataFetched = convertedJSONIntoDict["data"] as! [String: Any]
                        
                        // Get id of the currently logged in user
                        let userId = dataFetched["_id"] as! String
                        
                        // Call the function to add new post in the database
                        self.addPostToDatabase(postContent: postContent, numOfImages: numOfImages, writer: userId)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }

            }
        }
        
        // Resume the get user info task
        getCurrentUserInfoTask.resume()
    }
    
    // 2. The function to add new post to the database
    func addPostToDatabase(postContent: String, numOfImages: Int, writer: String) {
        // The URL to post new post using post method
        let createPostURL = URL(string: "\(AppResource.init().APIURL)/api/v1/cuckooPost")
        
        // Create the request for creating new post
        var createPostRequest = URLRequest(url: createPostURL!)
        
        // Let the method for logging in to be POST
        createPostRequest.httpMethod = "POST"
        
        // Parameters which will be sent to request body and submit to the API endpoint
        let requestString = "content=\(postContent)&numOfImages=\(numOfImages)&writer=\(writer)"
        
        // Set body content for the request
        createPostRequest.httpBody = requestString.data(using: String.Encoding.utf8)
        
        // Perform the post request and create the post
        let createPostTask = URLSession.shared.dataTask(with: createPostRequest) { (data, response, error) in
            // Check for error
            if let error = error {
                // Report the error
                print("There seem to be an error \(error)")

                // Get out of the function
                return
            }
            
            // Convert HTTP Response data in to the a simple string
            if let data = data, let dataString = String (data: data, encoding: .utf8) {
                // Print the response data body
                print("Response data string \n \(dataString)")
                
                // Convert the JSON data string into the NSDictionary
                do {
                    if let convertedJSONIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as?
                        NSDictionary {
                        // Get the whole data from the JSON, it will be in the map format [String: Any]
                        // And then get the user property of the data
                        let dataFetched = ((convertedJSONIntoDict["data"] as! [String: Any])["tour"]) as! [String: Any]
                        
                        // Get post id of the newly created post
                        let newPostId = dataFetched["_id"] as! String
                        
                        // Loop through all images of the post to be created and add them all to the database and storage
                        for image in self.postPhotos {
                            // Run this in the background
                            DispatchQueue.global(qos: .background).async {
                                // Call the function to add all photos to the database and also upload them to the storage
                                self.uploadPhotoToDatabaseAndStorage(postId: newPostId, image: image)
                            }
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        
        // Resume the task
        createPostTask.resume()
    }
    
    // 3. The function to upload photo to the database as well as storage
    func uploadPhotoToDatabaseAndStorage(postId: String, image: UIImage) {
        // Generate name for the image which is going to be added to the database and storage
        let imageName = AppResource().randomString(length: 20)
        
        // Do it asynchronously
        DispatchQueue.main.async {
            // Get the image data
            let imageData = image.jpegData(compressionQuality: 0.1)!
            
            // Create the reference to the storage to save the photo
            let imageRef = self.storage.reference().child("HBTGramPostPhotos/\(imageName).jpg")
            
            // Begin with the uploading process
            imageRef.putData(imageData, metadata: nil) {(metadata, error) in
                // Get the download URL of the image when done
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error \(error)")
                    }
                    
                    guard let downloadURL = url else {
                        return
                    }
                    
                    // Call the function to add new image URL to the database
                    self.addNewImageURLToDatabase(imageURL: downloadURL.absoluteString, postId: postId, image: image)
                }
            }
        }
    }
    
    // 4. The function to add new image URL to the database
    func addNewImageURLToDatabase(imageURL: String, postId: String, image: UIImage) {
        // The URL to post new image URL in the database for the post
        let createPostPhotoURL = URL(string: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhoto")
        
        // Create the request for creating new post photo
        var createPostPhotoRequest = URLRequest(url: createPostPhotoURL!)
        
        // Let the method for logging in to be POST
        createPostPhotoRequest.httpMethod = "POST"
        createPostPhotoRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Parameters which will be sent to request body and submit to the API endpoint
        let jsonRequestBody : [String: Any] = [
            "postId" : postId,
            "imageURL" : imageURL
        ]
        
        // Set body content for the request
        createPostPhotoRequest.httpBody = jsonRequestBody.percentEncoded()
        
        // Perform the post request and create the post photo
        let createPostPhotoTask = URLSession.shared.dataTask(with: createPostPhotoRequest) { (data, response, error) in
            // Check for error
            if let error = error {
                // Report the error
                print("There seem to be an error \(error)")

                // Get out of the function
                return
            }
            
            if let data = data {
                // Convert the JSON data string into the NSDictionary
                do {
                    if let convertedJSONIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as?
                        NSDictionary {
                        // Get the whole data from the JSON, it will be in the map format [String: Any]
                        // And then get the user property of the data
                        let dataFetched = ((convertedJSONIntoDict["data"] as! [String: Any])["tour"]) as! [String: Any]
                        
                        // Get id of the newly created image
                        let imageId = dataFetched["_id"] as! String
                        
                        // Call the function to start labeling image and upload label to the database
                        self.labelImage(imageId: imageId, image: image)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        
        // Resume the task
        createPostPhotoTask.resume()
    }
    
    // 5. The function to label the image
    func labelImage(imageId: String, image: UIImage) {
        // Create image object for the labeler
        let image = VisionImage(image: image)
        
        // The labeler
        let labeler = Vision.vision().cloudImageLabeler()
        
        // Start with labeling
        labeler.process(image) { labels, error in
            guard error == nil, let labels = labels else { return }

            // Loop through all labels of the image and add them to the database
            for label in labels {
                // Get label of the image
                let imageLabel = label.text
                
                // Call the function to upload image label to the database
                self.uploadImageLabelToDatabase(imageId: imageId, imageLabel: imageLabel)
            }
        }
    }
    
    // The function to upload image label to the database
    func uploadImageLabelToDatabase(imageId: String, imageLabel: String) {
        // The URL to create new image label
        let createNewImageLabelURL = URL(string: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhotoLabel")
        
        // Create the request for creating new image label
        var createNewImageLabelRequest = URLRequest(url: createNewImageLabelURL!)
        
        // Let the method to be POST
        createNewImageLabelRequest.httpMethod = "POST"
        createNewImageLabelRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Parameters which will be sent to request body and submit to the API endpoint
        // We also need to replace any space in label with the "-" sign in order to prevent any error when querying the label
        let jsonRequestBody : [String: Any] = [
            "imageID" : imageId,
            "imageLabel" : AdditionalFunctions.init().replaceStringOccurence(originalString: imageLabel, characterToReplace: " ", replaceCharacterWith: "-")
        ]
        
        // Set body content for the request
        createNewImageLabelRequest.httpBody = jsonRequestBody.percentEncoded()
        
        // Perform the post request to create image label
        let createNewImageLabelTask = URLSession.shared.dataTask(with: createNewImageLabelRequest) { (data, response, error) in
            // Check for error
            if let error = error {
                // Report the error
                print("There seem to be an error \(error)")

                // Get out of the function
                return
            }
        }
        
        // Resume the task
        createNewImageLabelTask.resume()
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
