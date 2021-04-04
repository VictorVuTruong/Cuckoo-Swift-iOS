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
    
    // Photo repository
    let photoRepository = PhotoRepository()
    
    // Additional assets
    let additionalAssets = AdditionalAssets()
    
    // User repository
    let userRepository = UserRepository()
    
    // Comment repository
    let commentRepository = CommentAndLikeRepository()
    
    // The image view which will be used to preview photo to be sent
    @IBOutlet weak var previewPhoto: UIImageView!
    
    // The button to send photo for the comment
    @IBAction func sendPhotoButton(_ sender: UIButton) {
        // Call the function to get info of the current user and create new comment with photo
        sendNewComment(commentContent: "image", postId: postId)
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
    
    // The function to add new comment to the database
    func sendNewComment(commentContent: String, postId: String) {
        // Call the function to create new comment
        commentRepository.createComment(postId: postId, commentContent: commentContent) { (newlyCreatedComment) in
            DispatchQueue.main.async {
                // Call the function to upload image of the message to the database as well as the storage
                //self.uploadPhotoToDatabaseAndStorage(messageId: newMessageId, image: self.previewPhotoToSend.image!, sender: sender)
                self.uploadPhotoToDatabaseAndStorage(commentId: newlyCreatedComment._id, image: self.previewPhoto.image!)
            }
        }
    }
    
    // The function to upload photo URL to the database as well as storage
    func uploadPhotoToDatabaseAndStorage(commentId: String, image: UIImage) {
        // Call the function to start uploading image to the database
        additionalAssets.uploadPhotoToDatabase(reference: "hbtGramPostCommentPhotos", image: image) { (imageURL) in
            // Call the function to add new image URL to the database
            self.addNewImageURLToDatabase(imageURL: imageURL, commentId: commentId)
        }
    }
    
    // The function to add new image URL to the database
    func addNewImageURLToDatabase(imageURL: String, commentId: String) {
        // Call the function to add new comment photo URL to the database
        photoRepository.addCommentPhoto(imageURL: imageURL, commentId: commentId) { (isDone) in
            if (isDone) {
                // Call the function to get info of the currently logged in user
                self.userRepository.getInfoOfCurrentUser { (userObject) in
                    // Call the function to emit event to the server
                    self.emitSentCommentWithPhotoEvent(commentObject: CuckooPostComment(_id: commentId, writer: userObject._id, content: "image", postId: self.postId, orderInCollection: 0), postId: self.postId)
                }
                
                DispatchQueue.main.async {
                    // Take user back to the previous view controller
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
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
