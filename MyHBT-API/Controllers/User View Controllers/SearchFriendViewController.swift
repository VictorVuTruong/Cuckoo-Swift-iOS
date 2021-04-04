//
//  SearchFriendViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/14/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class SearchFriendViewController: UIViewController, SearchFriendCellDelegator {
    // User repository
    let userRepository = UserRepository()
    
    // Array of users which match the search query
    var arrayOfUsers: [User] = []
    
    // Selected user object to pass to the next view controller
    static var selectedUserObject = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // The text field which will be used to search for friends
    @IBOutlet weak var searchFriendTextField: UITextField!
    
    // The table view which display list of found accounts
    @IBOutlet weak var searchFriendTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate method to get data for the table view
        searchFriendTableView.dataSource = self
        
        // Register the message room cell for the table view
        searchFriendTableView.register(UINib(nibName: "SearchFriendCell", bundle: nil), forCellReuseIdentifier: "searchFriendCell")
        
        // Call the function to load list of users for the first time
        loadListOfUsers(searchQuery: "")
        
        // Do this show that the view controller will know when text field is changing
        searchFriendTextField.addTarget(self, action: #selector(SearchFriendViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    //**************************************** WORK WITH THE TEXT FIELD ****************************************
    // The function to handle action of when user is typing
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Call the function to reload list of users based on search query
        loadListOfUsers(searchQuery: (searchFriendTextField.text!).replacingOccurrences(of: " ", with: "-"))
    }
    //**************************************** END WORK WITH THE TEXT FIELD ****************************************
    
    //**************************************** FUNCTION TO LOAD LIST OF USERS WHICH MATCH THE SEARCH QUERY ****************************************
    func loadListOfUsers(searchQuery: String) {
        // Call the function to start searching for users
        userRepository.searchUser(searchQuery: searchQuery) { (arrayOfFoundUsers) in
            // Clear the current array of found users
            self.arrayOfUsers = []
            
            // Add that object to the array of users
            self.arrayOfUsers += arrayOfFoundUsers
            
            // Update the table view
            DispatchQueue.main.async {
                self.searchFriendTableView.reloadData()
            }
        }
    }
    //**************************************** END FUNCTION TO LOAD LIST OF USERS WHICH MATCH THE SEARCH QUERY ****************************************
    
    //**************************************** PERFORM SEGUEM TAKE USER TO THE PROFILE DETAIL VIEW CONTROLLER AND PREPARE INFO ****************************************
    // The function to perform segue and take user to the view controller where the user can start chatting with the selected user
    func callSegueFromCell(myData dataobject: AnyObject) {
        // Perform the segue and take user to the view controller where the user can start chatting
        performSegue(withIdentifier: "searchFriendToProfileDetail", sender: self)
    }
    
    // Pass the selected user object to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // The chat view controller
        let vc = segue.destination as? ProfileDetailViewController
        
        if (vc != nil) {
            // Set the user object in the profile page view controller to be the selected user
            vc!.userObject = SearchFriendViewController.selectedUserObject
        }
    }
    //**************************************** END PERFORM SEGUEM TAKE USER TO THE PROFILE DETAIL VIEW CONTROLLER AND PREPARE INFO ****************************************
}

// Extension for the table view
extension SearchFriendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of users which match the search query
        return arrayOfUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell for the search friend cell
        let cell = searchFriendTableView.dequeueReusableCell(withIdentifier: "searchFriendCell", for: indexPath) as! SearchFriendCell
        
        // Get user object at this cell
        let userObject = arrayOfUsers[indexPath.row]
        
        // Set user object of this row for the cell
        cell.userObject = userObject
        
        // Delegate the cell
        cell.delegate = self
        
        // Call the function to load user info at this row
        cell.getInfoOfUser(userId: userObject._id)
        
        // Call the function to get follow status between the current user and user this row
        cell.getFollowStatus(otherUserId: userObject._id)
        
        // Return the cell
        return cell
    }
}

// Protocol which will be used to enable the table view cell to perform segue
protocol SearchFriendCellDelegator {
    func callSegueFromCell(myData dataobject: AnyObject)
}
