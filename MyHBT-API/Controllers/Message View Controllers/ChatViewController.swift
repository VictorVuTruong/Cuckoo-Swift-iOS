//
//  ChatViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/29/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import SocketIO
import FLAnimatedImage

class ChatViewController: UIViewController, UITextFieldDelegate {
    // Array of chat messages
    var chatMessages: [Message] = []
    
    // The selected chat room id
    var messageRoomId = ""
    
    // The selected chat room objecct
    var chatRoomObject = MessageRoom(_id: "", user1: "", user2: "")
    
    // User id of the message receiver
    var messageReceiverUserId = ""
    
    // User object of the message receiver
    var messageReceiverUserObject = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // Object for socket io
    let manager = SocketManager(socketURL: URL(string: AppResource.init().APIURL)!, config: [.log(true), .compress])
    
    // Avatar of the message receiver
    @IBOutlet weak var receiverAvatar: UIImageView!
    
    // Full name of the message receiver
    @IBOutlet weak var receiverFullName: UILabel!
    
    // The table view which will show messages
    @IBOutlet weak var messageView: UITableView!
    
    // The view which surround the receiver info which will take user to the view controller where the user can see detail of the message receiver
    @IBOutlet weak var receiverInfoView: UIView!
    
    // Content of the message to send
    @IBOutlet weak var messageToSendContent: UITextField!
    
    // The button to start video call
    @IBAction func videoCallButton(_ sender: UIButton) {
        // Perform segue and take user to the view controller where user can start video calling
        performSegue(withIdentifier: "chatToVideoChat", sender: self)
    }
    
    // User repository
    let userRepository = UserRepository()
    
    // Message repository
    let messageRepository = MessageRepository()
    
    // Notification repository
    let notificationRepository = NotificationRepository()
    
    // The button to send message
    @IBAction func sendMessageButton(_ sender: UIButton) {
        // Call the function to get info of the currently logged in user and create new message sent by that user id
        sendNewMessage(messageReceiver: messageReceiverUserId, messageContent: messageToSendContent.text!)
    }
    
    // The button to send picture
    @IBAction func sendPhotoButton(_ sender: UIButton) {
        // Perform segue and take user to the activity where the user can choose and send photo as a message
        performSegue(withIdentifier: "chatRoomToSendPhoto", sender: self)
    }
    
    // The view which indicate that other user in the chat room is typing
    @IBOutlet weak var isTypingView: UIView!
    
    // The is typing icon
    @IBOutlet weak var isTypingImageView: FLAnimatedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create tap gesture recognizer for the view which will take user to the view controller where the user
        // can see profile detail of the message receiver
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.viewTappedGotoProfileDetail))
        
        // Add tap gesture to the view
        receiverInfoView.addGestureRecognizer(tapGestureView)
        
        // These lines are to push the layout up when the keyboard shows
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.messageToSendContent.delegate = self
        
        // These lines are to get the animating GIF for the is typing indicator
        let urlString = "https://firebasestorage.googleapis.com/v0/b/hbtgram.appspot.com/o/appAssets%2FisTypingGIF.gif?alt=media&token=71493225-7d1a-4f3c-a42b-b8dfeec221b3"
        let url = URL(string: urlString)!
        let imageData = try? Data(contentsOf: url)
        let imageData3 = FLAnimatedImage(animatedGIFData: imageData)
        isTypingImageView.animatedImage = imageData3
        
        // Do this show that the app will know when text field is changing
        messageToSendContent.addTarget(self, action: #selector(ChatViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        // Hide the is typing view at beginning
        isTypingView.isHidden = true
        
        // Delegate method to get data for the table view
        messageView.dataSource = self
        
        // Call the function to get info of messag receiver
        loadInfoOfMessageReceiver()
        
        // Register the message cell for the table view
        messageView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        
        // Register the message with photo cell for the table view
        messageView.register(UINib(nibName: "MessageWithPhotoCell", bundle: nil), forCellReuseIdentifier: "messageWithPhotoCell")
        
        // If the chat room id is still a blank string, don't call this function yet. If it is not, call it
        if (chatRoomObject._id != "") {
            // Call the function to load all messages of the selected message room
            loadAllMessages(messageRoomId: chatRoomObject._id)
        }
        else if (messageRoomId != "") {
            // Call the function to load all messages
            loadAllMessages(messageRoomId: messageRoomId)
        }
        
        // Call the function to bring user into the chat room
        bringUserIntoChatRoomAndListenToMessageEvent(messageRoomId: messageRoomId)
    }
    
    //************************************** VIEW TAPPED OBJECT (HANDLE ACTION OF WHEN VIEW IS TAPPED) **************************************
    // The function which will take user to the view controller where the user can see profile detail of the message receiver
    @objc func viewTappedGotoProfileDetail(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Call the function to create message receiver user object and go to the view controller where the user can see
            // profile detail of the message receiver
            self.createReceiverUserObjectAndGotoProfileDetail(userId: self.messageReceiverUserId)
        }
    }
    //************************************** END VIEW TAPPED OBJECT (HANDLE ACTION OF WHEN VIEW IS TAPPED) **************************************
    
    //************************************** WORK WITH SOCKET.IO **************************************
    // The function to handle action of when user is typing
    @objc func textFieldDidChange(_ textField: UITextField) {
        // The socket
        let socket = manager.defaultSocket
        
        // Emit event to the server to let the server knows that user is typing
        socket.emit("isTyping", [
            "chatRoomId": messageRoomId
        ])
        
        // If content of the text field is empty, emit the done typing event
        if (messageToSendContent.text == "") {
            socket.emit("isDoneTyping", [
                "chatRoomId": messageRoomId
            ])
        }
    }
    
    // The function to bring user into the chat room
    func bringUserIntoChatRoomAndListenToMessageEvent(messageRoomId: String) {
        // The socket
        
        let socket = manager.defaultSocket
        
        // Connect to the socket
        socket.connect()
        
        // When the app is connected to the socket, bring user into the chat room
        socket.on(clientEvent: .connect, callback: {data, ack in
            // Emit event and bring user into the message room
            socket.emit("jumpInChatRoom", [
                "chatRoomId": messageRoomId
            ])
        })
        
        // Listen to updateMessage event. When other user sent message to the database, server will emit this event
        // to let this client app knows that there is new message
        socket.on("updateMessage", callback: {data, ack in
            // Get the data
            let messageObject = (data[0]) as! [String: Any]
            
            // Get sender of the message
            let sender = messageObject["sender"] as! String
            
            // Get receiver of the message
            let receiver = messageObject["receiver"] as! String
            
            // Get content of the message
            let content = messageObject["content"] as! String
            
            // Get id of the message
            let messageId = messageObject["_id"] as! String
            
            // Create new message object out of those info
            let newMessageObject = Message(sender: sender, receiver: receiver, content: content, _id: messageId)
            
            // Add the new message object to the array of messages
            self.chatMessages.append(newMessageObject)
            
            // Reload the table view
            DispatchQueue.main.async {
                self.messageView.reloadData()
                
                // Scroll to the last row of the table view
                let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
                self.messageView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        })
        
        // Listen to updateMessageWithPhoto event. When one of the user in the chat room send an image, update the table view
        socket.on("updateMessageWithPhoto", callback: {data, ack in
            // Get the data
            let messageObject = data[0] as! [String : Any]
            
            // Get sender of the message
            let sender = messageObject["sender"] as! String
            
            // Get receiver of the message
            let receiver = messageObject["receiver"] as! String
            
            // Get content of the message
            let content = messageObject["content"] as! String
            
            // Get id of the message
            let messageId = messageObject["_id"] as! String
            
            // Create new message object out of those info
            let newMessageObject = Message(sender: sender, receiver: receiver, content: content, _id: messageId)
            
            // Add the new message object to the array of messages
            self.chatMessages.append(newMessageObject)
            
            // Reload the table view
            DispatchQueue.main.async {
                self.messageView.reloadData()
                
                // Scroll to the last row of the table view
                let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
                self.messageView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        })
        
        // Listen to typing event. If other user in the message room is typing, the server will let the client app know and we also need to
        // handle that
        socket.on("typing", callback: {data, ack in
            // Call the function to show the is typing view
            self.showIsTyping()
        })
        
        // Listen to done typing even
        socket.on("doneTyping", callback: {data, ack in
            // Call the function to hide the is typing view
            self.hideIsTyping()
        })
    }
    
    // The function to emit event to the server through socket in order to let the server know that there is a sent message
    func emitSentEvent(messageObject: Message) {
        // The socket
        let socket = manager.defaultSocket
        
        // Emit the sent message event to the server
        socket.emit("newMessage", [
            "sender" : messageObject.sender,
            "receiver" : messageObject.receiver,
            "content" : messageObject.content,
            "messageId" : messageObject._id,
            "chatRoomId" : messageRoomId
        ])
        
        // Emit the done typing event
        socket.emit("isDoneTyping", [
            "chatRoomId": messageRoomId
        ])
    }
    
    // The function to hide the is typing view
    func hideIsTyping() {
        // Hide the is typing view
        isTypingView.isHidden = true
    }
    
    // The function to show the is typing view
    func showIsTyping() {
        // Show the is typing view
        isTypingView.isHidden = false
    }
    //************************************** END WORKING WITH SOCKET.IO **************************************
    
    //************************************** GET INFO OF MESSAGE RECEIVER SEQUENCE **************************************
    // The function to load info of message receiver
    func loadInfoOfMessageReceiver() {
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Check chat room to determine user id of message receiver
            if (self.chatRoomObject.user1 == userObject._id) {
                self.messageReceiverUserId = self.chatRoomObject.user2
            } else {
                self.messageReceiverUserId = self.chatRoomObject.user1
            }
            
            DispatchQueue.main.async {
                // Call the function to make sender avatar look round
                AdditionalFunctions.init().makeRounded(image: self.receiverAvatar)
                
                // Call the function to load avatar and full name for the message receiver
                AdditionalFunctions.init().getUserFullNameAndAvatar(userId: self.messageReceiverUserId, senderFullName: self.receiverFullName, senderAvatar: self.receiverAvatar)
            }
        }
    }
    //************************************** GET INFO OF MESSAGE RECEIVER SEQUENCE **************************************
    // The function to load all messages of the selected message room
    func loadAllMessages(messageRoomId: String) {
        // Call the function to load all messages of the message room
        messageRepository.loadAllMessagesOfRoom(chatRoomId: messageRoomId) { (arrayOfMessages) in
            // Update array of messagaes
            self.chatMessages += arrayOfMessages
            
            // Reload the table view
            DispatchQueue.main.async {
                self.messageView.reloadData()
            }
        }
    }
    
    //************************************** CREATE NEW MESSAGE SEQUENCE **************************************
    // The function to send new message to the database
    func sendNewMessage(messageReceiver: String, messageContent: String) {
        messageRepository.createNewMessage(messageContent: messageContent, messageReceiver: messageReceiver) { (newMessageId, chatRoomId) in
            // If the chat room id in this view controller is still blank, assign the obtained chat room id to it
            if (self.messageRoomId == "") {
                // Assign it
                self.messageRoomId = chatRoomId
            }
            
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Create new message object
                let newMessageObject = Message(sender: userObject._id, receiver: messageReceiver, content: messageContent, _id: newMessageId)
                
                // Add the newly created message object to the array of messages
                self.chatMessages.append(newMessageObject)
                
                // Call the function to send message notification to the message receiver
                self.notificationRepository.sendNotificationToUser(userId: messageReceiver, notificationContent: "\(messageContent)", notificationTitle: "message") { }
                
                // Reload the table view
                DispatchQueue.main.async {
                    self.messageView.reloadData()
                    
                    // Empty content of the messageToSend content TextField
                    self.messageToSendContent.text = ""
                    
                    // Call the function to emit sent event
                    self.emitSentEvent(messageObject: newMessageObject)
                }
            }
        }
    }
    //************************************** END CREATE NEW MESSAGE SEQUENCE **************************************
    
    //************************************** PREPARE INFO FOR THE NEXT ACTIVITY **************************************
    // Pass the selected message receiver id and chat room id to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // The post detail view controller
        let vc = segue.destination as? ChatSendPhotoViewController
        
        if (vc != nil) {
            // Set the message receiver id and chat room id to be the one selected by the user
            vc!.messageRoomId = self.chatRoomObject._id
            vc!.messageReceiverUserId = self.messageReceiverUserId
        }
        
        // Check which segue is used
        if (segue.identifier == "chatRoomToSendPhoto") {
            // If the segue will take user to the send photo view controller
            // Set the message receiver id and chat room id to be the one selected by the user
            let vc = segue.destination as? ChatSendPhotoViewController
            
            // Set the message receiver id and chat room id to be the one selected by the user
            vc!.messageRoomId = self.chatRoomObject._id
            vc!.messageReceiverUserId = self.messageReceiverUserId
        } // Otherwise, destination view controller will be profile detail view controller
        // set userObject to be the message receiver user because it will show info of the message receiver
        else if (segue.identifier == "chatToProfileDetail") {
            // Let vc be the Profile Detail view controller
            let vc = segue.destination as? ProfileDetailViewController
            
            // Set the userObject in the profile detail view controller to be the message receiver
            vc!.userObject = self.messageReceiverUserObject
        } // If the segue will take user to the video call view controller, pass chat room name into that view controller
        else if (segue.identifier == "chatToVideoChat") {
            // Let vc be the Video view controller
            let vc = segue.destination as? VideoViewController
            
            // Set the chat room name to be the one that 2 users are in
            vc!.chatRoomName = self.chatRoomObject._id
            
            // Set user id of the call receiver to the message receiver in this view controller
            vc!.callReceiverUserId = self.messageReceiverUserId
        }
        // For other view controller, don't do anything
        else {
            return
        }
    }
    //************************************** END PREPARE INFO FOR THE NEXT ACTIVITY **************************************
    
    //************************************** WORK WITH THE TEXT FIELD **************************************
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    //************************************** END WORK WITH THE TEXT FIELD **************************************
    
    //************************************** CREATE USER OBJECT FOR MESSAGE RECEIVER AND GO TO PROFILE DETAIL **************************************
    func createReceiverUserObjectAndGotoProfileDetail(userId: String) {
        // Call the function to get user object of user based on user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            // Update the messageReceiverUserObject of the view controller
            self.messageReceiverUserObject = userObject
            
            // Perform segue and take user to the view controller where the user can see profile info of the message receiver
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "chatToProfileDetail", sender: self)
            }
        }
    }
    //************************************** END CREATE USER OBJECT FOR MESSAGE RECEIVER AND GO TO PROFILE DETAIL **************************************
}

// For the table view
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of messages in this chat room
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the message object at this row
        let messageObject = chatMessages[indexPath.row]
        
        // If content of message at this cell is "image", the cell at this position will show the image instead of just plain text
        if (messageObject.content == "image") {
            // Create a cell for the message with photo
            let cell = messageView.dequeueReusableCell(withIdentifier: "messageWithPhotoCell", for: indexPath) as! MessageWithPhotoCell
            
            // Call the function to load avatar and full name for the message sender
            cell.loadSenderInfo(userId: messageObject.sender)
            
            // Call the function to load image of the message
            cell.getMessagePhotoBasedOnMessageId(messageId: messageObject._id)
            
            // Return the cell
            return cell
        } // Otherwise, just let the cell be the message cell which shows the plain text
        else {
            // Create a cell for the message
            let cell = messageView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell

            // Call the function to load avatar and full name for the message sender
            cell.getUserFullNameAndAvatar(userId: messageObject.sender)
            
            // Load message content into the label of the message cell
            cell.messageContent.text = messageObject.content
            
            // Return the cell
            return cell
        }
    }
}
