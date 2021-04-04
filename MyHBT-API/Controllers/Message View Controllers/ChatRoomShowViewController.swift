//
//  ChatRoomShowViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/30/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class ChatRoomShowViewController: UIViewController, MessageRoomCellDelegator, ChatRoomShowProtocol {
    // Array of message rooms
    var messageRooms : [MessageRoom] = []
    
    // The table view which will display chat rooms in which the current user is involved
    @IBOutlet weak var messageRoomView: UITableView!
    
    // The view which cover the create new message button and will take user to the view controller where the user can search for user to message
    @IBOutlet weak var createMessageView: UIView!
    
    // Selected messageRoomObject
    var selectedMessageRoomObject = MessageRoom(_id: "", user1: "", user2: "")
    
    // Message repository
    let messageRepository = MessageRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate method to get data for the table view
        messageRoomView.dataSource = self
        
        // Register the message room cell for the table view
        messageRoomView.register(UINib(nibName: "MessageRoomCell", bundle: nil), forCellReuseIdentifier: "messageRoomCell")
        
        // Create tap gesture recognizer which will take user to the view controller where the user can search for user to message with
        let tapGestureCreateMessage = UITapGestureRecognizer(target: self, action: #selector(viewTappedCreateMessage(gesture:)))
        
        // Add tap gesture to the view
        createMessageView.addGestureRecognizer(tapGestureCreateMessage)
        
        // Call the function to get list of chat room of the currently logged in user
        loadChatRoomForCurrentUser()
    }
    
    //************************************* TAP GESTURES RECOGNIZER *************************************
    // The function which will take user to the view controller where the user can search for user to message with
    @objc func viewTappedCreateMessage(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Perform the segue and take user to the view controller where the user can search for user to message with
            performSegue(withIdentifier: "messageRoomToSearchUserToChat", sender: self)
        }
    }
    //************************************* END TAP GESTURES RECOGNIZER *************************************
    
    //************************************* LOAD CHAT ROOMS *************************************
    // The function to load chat rooms for the currently logged in user
    func loadChatRoomForCurrentUser() {
        // Call the function to get list of chat room of the currently logged in user
        messageRepository.getChatRoomsOfCurrentUser { (arrayOfChatRoom) in
            // Update list of chat room
            self.messageRooms += arrayOfChatRoom
            
            // Reload the table view
            DispatchQueue.main.async {
                self.messageRoomView.reloadData()
            }
        }
    }
    //************************************* END LOAD CHAT ROOMS *************************************
    
    // The function to perform segue
    func callSegueFromCell(myData dataobject: AnyObject) {
        // Perform the segue and take user to the view controller where the user can start chatting
        self.performSegue(withIdentifier: "messageRoomToChatRoom", sender: dataobject)
    }
    
    // Pass the selected message receiver id and chat room id to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // The chat view controller
        let vc = segue.destination as? ChatViewController
        
        if (vc != nil) {
            // Set the message receiver id and chat room id to be the one selected by the user
            vc!.chatRoomObject = self.selectedMessageRoomObject
        }
    }
    
    // The function which will perform segue and take user to the view controller where user can chat with the selected user
    func gotoChat(chatRoomObject: MessageRoom) {
        // Update the selected message room id
        self.selectedMessageRoomObject = chatRoomObject
        
        // Perform the segue and take user to the view controller where the user can start chatting
        self.performSegue(withIdentifier: "messageRoomToChatRoom", sender: self)
    }
}

// For the table view
extension ChatRoomShowViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of message rooms in which the current user is involved in
        return messageRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create a cell for the message room
        let cell = messageRoomView.dequeueReusableCell(withIdentifier: "messageRoomCell", for: indexPath) as! MessageRoomCell
        
        // Get the message room object at this row
        let messageRoomObject = messageRooms[indexPath.row]
        
        // Call the function to set up receiver info and latest message content of the chat room
        cell.loadLatestMessage(chatRoomId: messageRoomObject._id)
        
        // Set the delegate property in the cell to be self so that the cell can call the segue
        cell.delegate = self
        cell.chatRoomShowProtocol = self
        
        // Set the chat room object in the row to be the chat room object at this row
        cell.chatRoomObject = messageRoomObject
        
        // Return the cell
        return cell
    }
}

// Protocol which will be used to enable the table view cell to perform segue
protocol MessageRoomCellDelegator {
    func callSegueFromCell(myData dataobject: AnyObject)
}
