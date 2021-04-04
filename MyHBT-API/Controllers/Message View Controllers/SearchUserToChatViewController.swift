//
//  SearchUserToChatViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/8/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class SearchUserToChatViewController: UIViewController, SearchUserToChatCellDelegator {
    // Array of users which match the search query
    var arrayOfUsers: [User] = []
    
    // Selected user id to pass to the next view controller
    static var selectedUserId = ""
    
    // Selected chat room id to pass to the next view controller
    static var selectedChatRoomId = ""
    
    // Selected chat room object to pass to the next view controller (chat view controller)
    var selectedChatRoomObject = MessageRoom(_id: "", user1: "", user2: "")
    
    // The text field which will be used to search for user
    @IBOutlet weak var searchUserTextField: UITextField!
    
    // List of users that match the search query
    @IBOutlet weak var userList: UITableView!
    
    // User repository
    let userRepository = UserRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate method to get data for the table view
        userList.dataSource = self
        
        // Register the message room cell for the table view
        userList.register(UINib(nibName: "SearchUserToMessageCell", bundle: nil), forCellReuseIdentifier: "searchUserToMessageCell")
        
        // Call the function to load list of users for the first time
        loadListOfUsers(searchQuery: "")
        
        // Do this show that the view controller will know when text field is changing
        searchUserTextField.addTarget(self, action: #selector(SearchUserToChatViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    //**************************************** WORK WITH THE TEXT FIELD ****************************************
    // The function to handle action of when user is typing
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Call the function to reload list of users based on search query
        loadListOfUsers(searchQuery: searchUserTextField.text!)
    }
    //**************************************** END WORK WITH THE TEXT FIELD ****************************************
    
    //**************************************** FUNCTION TO LOAD LIST OF USERS WHICH MATCH THE SEARCH QUERY ****************************************
    func loadListOfUsers(searchQuery: String) {
        // Call the function to search for user based on full name
        userRepository.searchUser(searchQuery: searchQuery) { (arrayOfUsers) in
            // Update list of users
            self.arrayOfUsers += arrayOfUsers
            
            // Update the table view
            DispatchQueue.main.async {
                self.userList.reloadData()
            }
        }
    }
    //**************************************** END FUNCTION TO LOAD LIST OF USERS WHICH MATCH THE SEARCH QUERY ****************************************
    
    //**************************************** PERFORM SEGUE, TAKE USER TO THE CHAT VIEW CONTROLLER AND PREPARE INFO ****************************************
    // The function to perform segue and take user to the view controller where the user can start chatting with the selected user
    func callSegueFromCell(myData dataobject: AnyObject) {
        // Perform the segue and take user to the view controller where the user can start chatting
        performSegue(withIdentifier: "searchUserToChatToChatRoom", sender: self)
    }
    
    // The function which will take user to the view controller where user can start chatting
    func gotoChat(chatRoomObject: MessageRoom) {
        // Update selected chat room object
        self.selectedChatRoomObject = chatRoomObject
        
        // Perform the segue and take user to the view controller where user can start chatting
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "searchUserToChatToChatRoom", sender: self)
        }
    }
    
    // Pass the selected chat room id and message receiver id to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // The chat view controller
        let vc = segue.destination as? ChatViewController
        
        if (vc != nil) {
            // Set selected message room id to be the selected one
            vc!.chatRoomObject = self.selectedChatRoomObject
            
            // Set the message receiver id and chat room id to be the one selected by the user
            //vc!.messageRoomId = SearchUserToChatViewController.selectedChatRoomId
            //vc!.messageReceiverUserId = SearchUserToChatViewController.selectedUserId
        }
    }
    //**************************************** END PERFORM SEGUE, TAKE USER TO THE CHAT VIEW CONTROLLER AND PREPARE INFO ****************************************
}

// For the table view
extension SearchUserToChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of users which match the searech query
        return arrayOfUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell for the search user cell
        let cell = userList.dequeueReusableCell(withIdentifier: "searchUserToMessageCell", for: indexPath) as! SearchUserToMessageCell
        
        // Get user object at this row
        let userObject = arrayOfUsers[indexPath.row]
        
        // Set the delegate property in the cell to be self so that the cell can call the segue
        cell.delegate = self
        
        // Set up user id for this cell
        cell.userId = userObject._id
        
        // Call the function to load avatar for the user at this row
        cell.loadUserInfoBasedOnId(userId: userObject._id)
        
        // Return the cell
        return cell
    }
}

// Protocol which will be used to enable the table view cell to perform segue
protocol SearchUserToChatCellDelegator {
    func callSegueFromCell(myData dataobject: AnyObject)
    func gotoChat(chatRoomObject: MessageRoom)
}
