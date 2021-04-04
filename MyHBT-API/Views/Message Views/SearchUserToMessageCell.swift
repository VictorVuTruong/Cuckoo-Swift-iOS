//
//  SearchUserToMessageCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/8/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class SearchUserToMessageCell: UITableViewCell {
    var delegate:SearchUserToChatCellDelegator!
    
    // User id of the user at this cell
    var userId = ""
    
    // Avatar of the user
    @IBOutlet weak var userAvatar: UIImageView!
    
    // Full name of the user
    @IBOutlet weak var userFullName: UILabel!
    
    // The view which surround the user info
    @IBOutlet weak var userView: UIView!
    
    // User repository
    let userRepository = UserRepository()
    
    // Message repository
    let messageRepository = MessageRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make the avatar look round
        AdditionalFunctions.init().makeRounded(image: userAvatar)
        
        // create tap gesture recognizer for the view which will take user to the view controller where the user can start chatting
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(SearchUserToMessageCell.viewTappedGotoChat(gesture:)))
        
        // Add tap gesture to the view
        userView.addGestureRecognizer(tapGestureView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // The function to load user info based on the specified user id
    func loadUserInfoBasedOnId(userId: String) {
        // Call the function to load user info based on id
        AdditionalFunctions.init().getUserFullNameAndAvatar(userId: userId, senderFullName: userFullName, senderAvatar: userAvatar)
    }
    
    //***************************************** TAP GESTURE RECOGNIZER *****************************************
    // The function which will take user to the view controller where the user can chat with the selected user
    @objc func viewTappedGotoChat(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Call the function to go to the view controller where the user can start chatting with the selected user
            checkChatRoomAndGotoChat(selectedUserId: userId)
        }
    }
    //***************************************** END TAP GESTURE RECOGNIZER *****************************************
    
    //***************************************** GO TO CHAT SEQUENCE *****************************************
    /*
     In this sequence, we will do 2 things
     1) Get user id of the currently logged in user
     2) Get the chat room id between the current user and the selected user
        If there is no chat room between the 2 users, pass an empty string as chat room id to the next view controller
        If there is chat room between the 2 users, pass it to the next view controller
     */
    
    // The function to check for chat room between the 2 users and go to the activity where user can start chatting
    func checkChatRoomAndGotoChat(selectedUserId: String) {
        // Call the function to check for chat room between the 2 users
        messageRepository.getChatRoomBetween2Users(userId: selectedUserId) { (chatRoomObject) in
            // Check to see if chat room id is blank or not. It it is, modify it with info of current user and user to chat with
            if (chatRoomObject._id == "") {
                // Call the function to get info of the currently logged in user
                self.userRepository.getInfoOfCurrentUser { (userObject) in
                    // Call the function to go to the activity where user can start chatting
                    self.delegate.gotoChat(chatRoomObject: MessageRoom(_id: "", user1: selectedUserId, user2: userObject._id))
                }
            } // Otherwise, just use the found chat room object
            else {
                //  Call the function to go to the activity where user can start chatting
                self.delegate.gotoChat(chatRoomObject: chatRoomObject)
            }
        }
    }
    //***************************************** END GO TO CHAT SEQUENCE *****************************************
}
