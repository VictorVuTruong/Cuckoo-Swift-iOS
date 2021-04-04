//
//  MessageRoomCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/30/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class MessageRoomCell: UITableViewCell {
    var delegate:MessageRoomCellDelegator!
    var chatRoomShowProtocol:ChatRoomShowProtocol!
    
    // User id of the message receiver
    var messageReceiverUserId = ""
    
    // Chat room object at this row
    var chatRoomObject = MessageRoom(_id: "", user1: "", user2: "")
    
    // Avatar of the message receiver
    @IBOutlet weak var receiverAvatar: UIImageView!
    
    // Full name of the message receiver
    @IBOutlet weak var receiverFullName: UILabel!
    
    // Content of the message
    @IBOutlet weak var messageContent: UILabel!
    
    // The view which surround this cell. When user tap this, it will take user to the view controller where the user can chat with the selected user
    @IBOutlet weak var messageView: UIView!
    
    // Message repository
    let messageRepository = MessageRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make avatar look round
        AdditionalFunctions.init().makeRounded(image: receiverAvatar)
        
        // create tap gesture recognizer for the message view which will take user to the view controller to chat with selected user when view is tapped
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(MessageRoomCell.viewTapped(gesture:)))
        
        // Add tap gesture recognizer to the message view
        messageView.addGestureRecognizer(tapGestureView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // The function which take the user to the view controller where the user can chat with the selected user when view is tapped
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Call the function to take user to the view controller where user can start chatting
            chatRoomShowProtocol.gotoChat(chatRoomObject: chatRoomObject)
        }
    }
    
    // The function to get info of the latest message and load the right content for the message label
    func loadLatestMessage(chatRoomId: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to get info of the latest message of the chat room
                self.messageRepository.getLatestMessageOfChatRoom(chatRoomId: chatRoomId) { (latestMessageObject) in
                    // If the latest message is sent by the current user, write the word "You:" before the message content
                    if (latestMessageObject.sender == userObject._id) {
                        // Call the function to load info for the message receiver and set up latest message content
                        DispatchQueue.main.async {
                            self.loadReceiverInfoAndMessageContent(receiver: latestMessageObject.receiver, content: "You: \(latestMessageObject.content)")
                        }
                    } // Otherwise, just load the content alone
                    else {
                        // Call the function to load info for the message receiver and set up latest message content
                        DispatchQueue.main.async {
                            self.loadReceiverInfoAndMessageContent(receiver: latestMessageObject.sender, content: latestMessageObject.content)
                        }
                    }
                }
            }
        }
    }
    
    // The function to load receiver info and message content at this cell
    func loadReceiverInfoAndMessageContent(receiver: String, content: String) {
        // Call the function to load info for the receiver based on id and load them into image view and label
        AdditionalFunctions.init().getUserFullNameAndAvatar(userId: receiver, senderFullName: receiverFullName, senderAvatar: receiverAvatar)
        
        // Load content of the message into the label
        messageContent.text = content
    }
}
