//
//  HBTGramPostCommentAddPhotoViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/30/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import Firebase
import SocketIO

class PostCommentAddPhotoViewController: UIViewController {
    // Object for socket io
    let manager = SocketManager(socketURL: URL(string: AppResource.init().APIURL)!, config: [.log(true), .compress])
    
    // Post id of the post to get commented
    var postId = ""
    
    // Instance of the Firebase storage
    let storage = Storage.storage()
    
    // The image view which will be used to preview photo to be sent
    @IBOutlet weak var previewPhoto: UIImageView!
    
    // The button to send photo for the comment
    @IBAction func sendPhotoButton(_ sender: UIButton) {
        // Call the function to get info of the current user and create new comment with photo
        getInfoOfCurrentUserAndCreateCommentWithPhoto(commentContent: "image")
    }
    
    // The button to choose another photo to send
    @IBAction func chooseAnotherPhotoButton(_ sender: UIButton) {
        // Call the function to show the image picker
        showImagePickerController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Call the function so that user can choose which photo to send
        showImagePickerController()
        
        // Call the function so that it will bring user into the post detail room
        bringUserIntoPostDetailRoomAndListenToCommentEvent(postId: self.postId)
    }
    
    //****************************************** WORK WITH SOCKET.IO ******************************************
    // The function to bring user into the post detail room
    func bringUserIntoPostDetailRoomAndListenToCommentEvent(postId: String) {
        // The socket
        let socket = manager.defaultSocket
        
        // Connect to the socket
        socket.connect()
        
        // When the app is connected to the socket, bring user into the chat room
        socket.on(clientEvent: .connect, callback: {data, ack in
            // Emit event and bring user into the message room
            socket.emit("jumpInPostDetailRoom", [
                "postId": self.postId
            ])
        })
    }
    
    // The function to emit the send comment with photo event everytime a comment with photo is sent
    func emitSentCommentWithPhotoEvent(commentObject: CuckooPostComment, postId: String) {
        // The socket
        let socket = manager.defaultSocket
        
        // Emit the sent comment event to the server
        socket.emit("imageSentAsComment", [
            "commentId" : commentObject._id,
            "writer" : commentObject.writer,
            "content" : commentObject.content,
            "postId" : postId
        ])
    }
    //****************************************** END WORK WITH SOCKET.IO ******************************************
    
    //******************************************* SEND NEW COMMENT WITH PHOTO SEQUENCE *******************************************
    /*
     In this sequence, we will do these things
     1. Get info of the current user
     2. Add new comment to the comment collection in the database
     3. Upload photo to the storage
     4. Upload image id to the comment photo URL collection in the database
     */
    
    // The function to get info of the currently logged in user and call the function to send comment with photo
    func getInfoOfCurrentUserAndCreateCommentWithPhoto(commentContent: String) {
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
                        
                        // Get user if of the currently logged in user
                        let userId = dataFetched["_id"] as! String
                        
                        // Call the function to send new comment to the database as well as putting image into the storage
                        self.sendNewComment(commentContent: commentContent, writer: userId, postId: self.postId)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }

            }
        }
        
        // Resume the get user info task
        getCurrentUserInfoTask.resume()
    }
    
    // The function to add new comment to the database
    func sendNewComment(commentContent: String, writer: String, postId: String) {
        // The URL to send new comment
        let sendNewCommentURL = URL(string: "\(AppResource.init().APIURL)/api/v1/cuckooPostComment")
        
        // Create the request for sending new comment
        var sendNewCommentRequest = URLRequest(url: sendNewCommentURL!)
        
        // Let the method to be POST
        sendNewCommentRequest.httpMethod = "POST"
        
        // Parameters which will be sent to request body and submit to the API endpoint
        let requestString = "content=\(commentContent)&writer=\(writer)&postId=\(postId)"
        
        // Set body content for the request
        sendNewCommentRequest.httpBody = requestString.data(using: String.Encoding.utf8)
        
        // Perform the post request and send new comment
        let sendNewCommentTask = URLSession.shared.dataTask(with: sendNewCommentRequest) { (data, response, error) in
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
                        let dataFetched = (convertedJSONIntoDict["data"] as! [String: Any])["tour"] as! [String: Any]
                        
                        // Get id of the newly created comment
                        let newCommentId = dataFetched["_id"] as! String
                        
                        DispatchQueue.main.async {
                            // Call the function to upload image of the message to the database as well as the storage
                            //self.uploadPhotoToDatabaseAndStorage(messageId: newMessageId, image: self.previewPhotoToSend.image!, sender: sender)
                            self.uploadPhotoToDatabaseAndStorage(commentId: newCommentId, image: self.previewPhoto.image!, sender: writer)
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }

            }
        }
        
        // Resume the task
        sendNewCommentTask.resume()
    }
    
    // The function to upload photo to the database as well as storage
    func uploadPhotoToDatabaseAndStorage(commentId: String, image: UIImage, sender: String) {
        // Generate name for the image which is going to be added to the database and storage
        let imageName = AppResource().randomString(length: 20)
        
        // Do it asynchronously
        DispatchQueue.main.async {
            // Get the image data
            let imageData = image.jpegData(compressionQuality: 0.1)!
            
            // Create the reference to the storage to save the photo
            let imageRef = self.storage.reference().child("hbtGramPostCommentPhotos/\(imageName).jpg")
            
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
                    self.addNewImageURLToDatabase(imageURL: downloadURL.absoluteString, commentId: commentId, sender: sender)
                }
            }
        }
    }
    
    // The function to add new image URL to the database
    func addNewImageURLToDatabase(imageURL: String, commentId: String, sender: String) {
        // The URL to post new image URL in the database for the comment
        let createCommentPhotoURL = URL(string: "\(AppResource.init().APIURL)/api/v1/cuckooPostCommentPhoto")
        
        // Create the request for creating new comment photo
        var createCommentPhotoRequest = URLRequest(url: createCommentPhotoURL!)
        
        // Let the method for logging in to be POST
        createCommentPhotoRequest.httpMethod = "POST"
        createCommentPhotoRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Parameters which will be sent to request body and submit to the API endpoint
        let jsonRequestBody : [String: Any] = [
            "commentId" : commentId,
            "imageURL" : imageURL
        ]
        
        // Set body content for the request
        createCommentPhotoRequest.httpBody = jsonRequestBody.percentEncoded()
        
        // Perform the post request and create the post photo
        let createMessagePhotoTask = URLSession.shared.dataTask(with: createCommentPhotoRequest) { (data, response, error) in
            // Check for error
            if let error = error {
                // Report the error
                print("There seem to be an error \(error)")

                // Get out of the function
                return
            } // If everything is done, emit event to the server to notify the server that there is a message with photo
            // and bring user back to the previous chat view controller. This is the end of the sending image sequence
            else {
                // Call the function to emit event to the server
                self.emitSentCommentWithPhotoEvent(commentObject: CuckooPostComment(_id: commentId, writer: sender, content: "image", postId: self.postId, orderInCollection: 0), postId: self.postId)
                
                DispatchQueue.main.async {
                    // Take user back to the previous view controller
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        // Resume the task
        createMessagePhotoTask.resume()
    }
    //******************************************* END SEND NEW COMMENT WITH PHOTO SEQUENCE *******************************************
}

// Extension for the image file chooser by which the user can choose which photo to send
extension PostCommentAddPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Set the image that has just been picked and editted from library into the image view
            self.previewPhoto.image = image
        } else if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Set the image that has been picked from library into the image view
            self.previewPhoto.image = originalImage
        }
        
        // Dismiss the image file chooser when the image selection is done
        dismiss(animated: true, completion: nil)
    }
}
