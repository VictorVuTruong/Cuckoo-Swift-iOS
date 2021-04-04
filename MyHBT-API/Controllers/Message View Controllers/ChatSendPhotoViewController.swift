//
//  ChatSendPhotoViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/7/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import SocketIO
import Firebase

class ChatSendPhotoViewController: UIViewController {
    // Instance of the FirebaseStorage
    let storage = Storage.storage()
    
    // Object for socket io
    let manager = SocketManager(socketURL: URL(string: AppResource.init().APIURL)!, config: [.log(true), .compress])
    
    // User id of the message receiver
    var messageReceiverUserId = ""
    
    // Message room id in which 2 users are in
    var messageRoomId = ""
    
    // Additional assets
    let additionalAssets = AdditionalAssets()
    
    // Message repository
    let messageRepository = MessageRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    // ImageView which will be used for the user to review photo to send
    @IBOutlet weak var previewPhotoToSend: UIImageView!
    
    // The button to send the photo
    @IBAction func sendPhotoButton(_ sender: UIButton) {
        // Call the function to start the send message with photo sequence
        sendNewMessage(postContent: "image", receiver: messageReceiverUserId)
    }
    
    // The button to choose another photo
    @IBAction func chooseAnotherPhotoButton(_ sender: UIButton) {
        // Call the function to show the image picker
        showImagePickerController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Call the function to connect to the socket
        connectToSocket()
        
        // Call the function so that user can choose which photo to send
        showImagePickerController()
    }
    
    //******************************************* START WORKING WITH SOCKET.IO *******************************************
    // The function to create connection with the socket
    func connectToSocket() {
        // The socket
        let socket = manager.defaultSocket
        
        // Connect to the socket
        socket.connect()
        
        // When the app is connected to the socket, bring user into the chat room
        socket.on(clientEvent: .connect, callback: {data, ack in
            // Emit event and bring user into the message room
            socket.emit("jumpInChatRoom", [
                "chatRoomId": self.messageRoomId
            ])
        })
    }
    
    // The function to emit event to the server which will then let the server know that there is a message as an image
    func emitSendPhotoEvent(messageObject: Message) {
        // The socket
        let socket = manager.defaultSocket
        
        // Connect to the socket
        socket.connect()
        
        // When the app is connected to the socket, bring user into the chat room
        socket.on(clientEvent: .connect, callback: {data, ack in
            // Emit event and bring user into the message room
            socket.emit("jumpInChatRoom", [
                "chatRoomId": self.messageRoomId
            ])
        })
        
        // Emit the sent message with photo event to the server
        socket.emit("userSentPhotoAsMessage", [
            "sender" : messageObject.sender,
            "receiver" : messageObject.receiver,
            "content" : messageObject.content,
            "messageId" : messageObject._id,
            "chatRoomId" : messageRoomId
        ])
    }
    //******************************************* END WORKING WITH SOCKET.IO *******************************************
    
    //******************************************* SEND NEW MESSAGE WITH PHOTO SEQUENCE *******************************************
    // The function to add new post to the database
    func sendNewMessage(postContent: String, receiver: String) {
        // Call the function to send new message
        messageRepository.createNewMessage(messageContent: postContent, messageReceiver: receiver) { (newMessageId, chatRoomId) in
            DispatchQueue.main.async {
                // Call the function to upload image of the message to the database as well as the storage
                self.uploadPhotoToDatabaseAndStorage(messageId: newMessageId, image: self.previewPhotoToSend.image!)
            }
        }
    }
    
    // The function to upload photo to the database as well as storage
    func uploadPhotoToDatabaseAndStorage(messageId: String, image: UIImage) {
        // Call the function to upload new image to the storage
        additionalAssets.uploadPhotoToDatabase(reference: "messagePhotos", image: image) { (downloadURL) in
            // Call the function to add new image URL to the database
            self.addNewImageURLToDatabase(imageURL: downloadURL, messageId: messageId)
        }
    }
    
    // The function to add new image URL to the database
    func addNewImageURLToDatabase(imageURL: String, messageId: String) {
        // Call the function to create new message photo in the database
        messageRepository.createNewMessagePhoto(messageId: messageId, imageURL: imageURL) { (isDone) in
            // If upload operation is done, emit the send event and get out of the sequence
            if (isDone) {
                // Call the function to get info of the currently logged in user
                self.userRepository.getInfoOfCurrentUser { (userObject) in
                    // Call the function to emit event to the server
                    self.emitSendPhotoEvent(messageObject: Message(sender: userObject._id, receiver: self.messageReceiverUserId, content: "image", _id: messageId))
                    
                    DispatchQueue.main.async {
                        // Take user back to the previous view controller
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    //******************************************* END SEND NEW MESSAGE WITH PHOTO SEQUENCE *******************************************
}

// Extension for the image file chooser by which the user can choose which photo to send
extension ChatSendPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            self.previewPhotoToSend.image = image
        } else if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Set the image that has been picked from library into the image view
            self.previewPhotoToSend.image = originalImage
        }
        
        // Dismiss the image file chooser when the image selection is done
        dismiss(animated: true, completion: nil)
    }
}
