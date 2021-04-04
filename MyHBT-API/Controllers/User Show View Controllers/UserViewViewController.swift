//
//  UserViewViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/1/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

/*
 This view controller will do this
 It shows list of users who like a specified post, followers and following of a specified user
 It will have a variable which will keep track of what it gonna do
 */

class UserViewViewController: UIViewController, GotoProfileDetailFromUserViewCellDelegator {
    // The variable which will keep track of what the view controller going to do
    var whatToDo = "getListOfLikes"
    
    // Post id of the selected post to show list of likes (in case the view controller is supposed to show list of likes of a post)
    var postId = "5fa3986ece10080514324095"
    
    // User id (in case the view controller suppose to get list of following and followers of the user)
    var userId = ""
    
    // List of users to view
    var listOfUsers: [User] = []
    
    // Selected user object. It will be used when user tap at one of the user in the list and want to see
    // profile detail of that user
    static var selectedUser = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // User repository
    let userRepository = UserRepository()
    
    // Comment and like repository
    let commentAndLikeRepository = CommentAndLikeRepository()
    
    // The table view which will display list of users
    @IBOutlet weak var userView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate method to get data for the table view
        userView.dataSource = self
        
        // Register the user view cell for the table view
        userView.register(UINib(nibName: "UserViewCell", bundle: nil), forCellReuseIdentifier: "userViewCell")
        
        // Based on the variable which specify what to do next to call the right function
        if (whatToDo == "getListOfLikes") {
            // If what to do next is to get list of likes, call the function to get list of users who like to the post
            loadListOfLikes(postId: postId)
        } // If what to do next is to get list of followers, call the function to get list of followers of the user
        else if (whatToDo == "getListOfFollowers") {
            getListOfFollowers(userId: userId)
        } // If what to do next is to get list of followings, call the function to get list of followings of the user
        else {
            getListOfFollowings(userId: userId)
        }
    }
    
    //***************************************** GET LIST OF LIKES SEQUENCE *****************************************
    /*
     In this sequence, we will do 2 things
     1. Get list of likes of the post
     2. Based on list of like, create user objects out of of them and add them to array of users
     */
    // The function to load list of likes based on post id
    func loadListOfLikes(postId: String) {
        // Call the function to get list of likes of post
        commentAndLikeRepository.getListOfLikesOfPost(postId: postId) { (arrayOfLikes) in
            // Loop through the array of likes Call the function to create user objects out of user id and add to the array of users
            for like in arrayOfLikes {
                // Call the function
                self.createUserObjectOutOfUserId(userId: like.whoLike)
            }
        }
    }
    //***************************************** END GET LIST OF LIKES SEQUENCE *****************************************
    
    //***************************************** GET LIST OF FOLLOWERS SEQUENCE *****************************************
    /*
     In this sequence, we will do 2 things
     1. Get list of followers of the user
     2. Based on list of followers, create user objects out of of them and add them to array of users
     */
    
    // The function to get list of followers of the user
    func getListOfFollowers(userId: String) {
        // Call the function to get list of followers of user with specified user id
        userRepository.getListOfFollowers(following: userId) { (listOfFollows) in
            // Loop through the list of followers, create user objects out of them and add them to the array of users
            for follow in listOfFollows {
                // Call the function
                self.createUserObjectOutOfUserId(userId: follow.follower)
            }
        }
    }
    //***************************************** END GET LIST OF FOLLOWERS SEQUENCE *****************************************
    
    //***************************************** GET LIST OF FOLLOWING SEQUENCE *****************************************
    /*
     In this sequence, we will do 2 things
     1. Get list of followings of the user
     2. Based on list of followings, create user objects out of of them and add them to array of users
     */
    
    // The function to get list of followings of the user
    func getListOfFollowings(userId: String) {
        // Call the function to get list of followings of user with specified user id
        userRepository.getListOfFollowing(follower: userId) { (listOfFollows) in
            // Loop through the list of followings, create user objects out of them and add them to the array of users
            for follow in listOfFollows {
                // Call the function
                self.createUserObjectOutOfUserId(userId: follow.following)
            }
        }
    }
    //***************************************** GET LIST OF FOLLOWING SEQUENCE *****************************************
    
    //***************************************** ADDITIONAL FUNCTIONS *****************************************
    // The function to create user object out of user id and add it to the array of users
    func createUserObjectOutOfUserId(userId: String) {
        // Call the function to get info of user based on user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            // Add user object to the array of users
            self.listOfUsers.append(userObject)
            
            // Reload the table view
            DispatchQueue.main.async {
                self.userView.reloadData()
            }
        }
    }
    //***************************************** END ADDITIONAL FUNCTIONS *****************************************
    
    //************************************ THE FUNCTION WHICH WILL PERFORM SEGUE AND TAKE USER TO THE PROFILE DETAIL VIEW CONTROLLER ************************************
    func callSegueFromCellGotoProfileDetail(myData dataobject: AnyObject) {
        // Perform the segue and take user to the view controller where the user can see profile detail of the selected user
        performSegue(withIdentifier: "userViewToProfileDetail", sender: self)
    }
    //************************************ END FUNCTION WHICH WILL PERFORM SEGUE AND TAKE USER TO THE PROFILE DETAIL VIEW CONTROLLER ************************************
    
    //************************************ PREPARE INFO FOR THE NEXT VIEW CONTROLLER ************************************
    // Pass info to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Let the destination view controller to be profile detail view controller
        let vc = segue.destination as? ProfileDetailViewController
        
        // Prepare user object for the next view controller
        vc!.userObject = UserViewViewController.selectedUser
    }
    //************************************ END PREPARE INFO FOR THE NEXT VIEW CONTROLLER ************************************
}

// For the table view
extension UserViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return length of the list of users
        return listOfUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell for the user view cell
        let cell = userView.dequeueReusableCell(withIdentifier: "userViewCell", for: indexPath) as! UserViewCell
        
        // Get user object at this row
        let userObject = listOfUsers[indexPath.row]
        
        // Delegate the cell
        cell.delegate = self
        
        // Call the function to load full name and avatar for the user at this row
        cell.loadFullNameAndAvatar(userId: userObject._id)
        
        // Set user object at this row
        cell.userObject = userObject
        
        // Return the cell
        return cell
    }
    
}

// Protocol which will be used to enable the table view cell to perform segue
protocol GotoProfileDetailFromUserViewCellDelegator {
    func callSegueFromCellGotoProfileDetail(myData dataobject: AnyObject)
}
