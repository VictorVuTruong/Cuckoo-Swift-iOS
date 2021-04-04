//
//  ProfileDetailHeaderCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/14/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class ProfileDetailHeaderCell: UITableViewCell {
    var delegate: ProfileDetailCellDelegator!
    
    // User id at this cell
    var userId = ""
    
    // Follow repository
    let followRepository = FollowRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    // Post repository
    let postRepository = PostRepository()
    
    // Message repository
    let messageRepository = MessageRepository()
    
    // Avatar of the user
    @IBOutlet weak var userAvatar: UIImageView!
    
    // Cover photo of the user
    @IBOutlet weak var userCoverPhoto: UIImageView!
    
    // Full name of the user
    @IBOutlet weak var userFullName: UILabel!
    
    // Bio of the user
    @IBOutlet weak var userBio: UILabel!
    
    // Number of posts created by the user
    @IBOutlet weak var numOfPosts: UILabel!
    
    // Number of followers of the user
    @IBOutlet weak var numOfFollowers: UILabel!
    
    // The view which wrap around number of followers
    @IBOutlet weak var numOfFollowersView: UIView!
    
    // Number of users to whom user is following
    @IBOutlet weak var numOfFollowings: UILabel!
    
    // The view which wrap around number of followings
    @IBOutlet weak var numOfFollowingsView: UIView!
    
    // The view which surrounds the edit profile button
    @IBOutlet weak var editProfileView: UIView!
    
    // The view which surrounds the message and follow/unfollow button
    @IBOutlet weak var messageFollowView: UIView!
    
    // The button which will take user to the view controller where the user can edit profile. Just for currently logged in user
    @IBAction func editProfileButton(_ sender: UIButton) {
        // Call the function which will perform the segue and take user to the view controller where the user can edit profile info
        delegate.callSegueFromCellGotoEditProfile(myData: "dataobject" as AnyObject)
    }
    @IBOutlet weak var followUnfollowButtonObject: UIButton!
    
    // The button to follow/unfollow the user
    @IBAction func followUnfollowButton(_ sender: UIButton) {
        // If content of the button is "Follow", add follow for the user and change its content to unfollow
        if (sender.titleLabel!.text == "  Follow  ") {
            // Call the function to create follow
            createFollow(userToFollow: userId)
        } // Otherwise, remove a follow and change its content to "  Follow  "
        else {
            // Call the function to remove a follow
            removeFollow(otherUserId: userId)
        }
    }
    
    // The button to send message to the user
    @IBAction func messageButton(_ sender: UIButton) {
        // Call the function to get info of the current user and go to the view controller where the user can start chatting
        checkChatRoonmAndGotoChat(selectedUserId: userId)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Call the function to make the avatar look round
        AdditionalFunctions.init().makeRounded(image: userAvatar)
        
        // Create tap gesture recognizer for the number of followers view
        let tapGestureNumOfFollowersView = UITapGestureRecognizer(target: self, action: #selector(ProfileDetailHeaderCell.viewTappedNumOfFollowers(gesture:)))
        
        // Create tap gesture recognizer for the number of followings view
        let tapGestureNumOfFollowingsView = UITapGestureRecognizer(target: self, action: #selector(ProfileDetailHeaderCell.viewTappedNumOfFollowings(gesture:)))
        
        // Add tap gesture recognizer to the number of followers view
        numOfFollowersView.addGestureRecognizer(tapGestureNumOfFollowersView)
        
        // Add tap gesture recognizer to the number of followings view
        numOfFollowingsView.addGestureRecognizer(tapGestureNumOfFollowingsView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //**************************************** VIEW TAP HANDLERS ****************************************
    // The function which will handle action of when number followers view is tapped
    @objc func viewTappedNumOfFollowers(gesture: UIGestureRecognizer) {
        // Call the function which will take user to the view controller where the user can see who like the post
        self.delegate.callSegueFromCellGotoListOfFollowers(myData: "" as AnyObject)
    }
    
    // The function which will handle action of when number of followings view is tapped
    @objc func viewTappedNumOfFollowings(gesture: UIGestureRecognizer) {
        // Call the function which will take user to the view controller where the user can see who like the post
        self.delegate.callSegueFromCellGotoListOfFollowings(myData: "" as AnyObject)
    }
    //**************************************** VIEW TAP HANDLERS ****************************************
    
    //****************************************** GET NUMBER OF FOLLOWERS AND FOLLOWINGS ******************************************
    // The function to get number of followers of the user
    func getNumOfFollowers(userId: String) {
        // Call the function to get number of followers of user with specified user id
        followRepository.getNumOfFollowers(userId: userId) { (numOfFollowers) in
            // Get the number of followers (length of the array of followers) and load it into the label
            DispatchQueue.main.async {
                self.numOfFollowers.text = "\(numOfFollowers)"
            }
        }
    }
    
    // The function to get number of followings of the user
    func getNumOfFollowings(userId: String) {
        // Call the function to get number of followings of user with specified user id
        followRepository.getNumOfFollowings(userId: userId) { (numOfFollowings) in
            // Get the number of followings (length of the array of followings) and load it into the label
            DispatchQueue.main.async {
                self.numOfFollowings.text = "\(numOfFollowings)"
            }
        }
    }
    //****************************************** END GET NUMBER OF FOLLOWERS AND FOLLOWINGS ******************************************
    
    //****************************************** GET NUMBER OF POSTS ******************************************
    func getNumOfPosts(userId: String) {
        // Call the function to get number of posts created by user with specified user
        postRepository.getNumOfPostsCreatedByUser(userId: userId) { (numOfPosts) in
            // Get the number of posts (length of the array of posts) and load it into the label
            DispatchQueue.main.async {
                self.numOfPosts.text = "\(numOfPosts)"
            }
        }
    }
    //****************************************** END GET NUMBER OF POSTS ******************************************
    
    //****************************************** GET AVATAR AND FULL NAME OF THE USER ******************************************
    // The function to load user avatar and cover photo
    func loadUserBasicInfo(userId: String) {
        // Call the function to get info of the currently logged in user
        userRepository.getUserInfoBasedOnId(userId: userId, completion: { (userObject) in
            DispatchQueue.main.async {
                // Load cover photo
                self.userCoverPhoto.sd_setImage(with: URL(string: userObject.coverURL), placeholderImage: UIImage(named: "placeholder.jpg"))
                
                // Load avatar
                self.userAvatar.sd_setImage(with: URL(string: userObject.avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
                
                // Load full name
                self.userFullName.text = userObject.fullName
            }
        })
    }
    
    // The function to load bio of the user
    func loadUserBio(userId: String) {
        // Call the function to load user bio of the user
        userRepository.getUserBio(userId: userId) { (userBio) in
            DispatchQueue.main.async {
                // Load bio into the label
                self.userBio.text = userBio
            }
        }
    }
    //****************************************** END GET AVATAR AND FULL NAME OF THE USER ******************************************
    
    //*********************************** FOLLOW A USER SEQUENCE ***********************************
    // The function to create a follow between the current user and selected user at this view controller
    func createFollow(userToFollow: String) {
        // Call the function to create a follow between current user and user with specified user id
        followRepository.createAFollowBetween2Users(userId: userToFollow) { (followCreated) in
            if (followCreated) {
                // Set content of the button to be "  Unfollow  "
                DispatchQueue.main.async {
                    self.followUnfollowButtonObject.setTitle("  Unfollow  ", for: .normal)
                }
            }
        }
    }
    //*********************************** END FOLLOW A USER SEQUENCE ***********************************
    
    //****************************************** GET FOLLOW STATUS BETWEEN 2 USERS ******************************************
    // The function to get follow status between current user and selected user
    func checkFollowStatus(otherUserId: String) {
        // Call the function to get follow status between the 2 users
        followRepository.checkFollowStatusBetween2Users(userId: otherUserId) { (isFollow) in
            if (isFollow) {
                // If the follow status is yes, set content of the button to be Unfollow
                DispatchQueue.main.async {
                    self.followUnfollowButtonObject.setTitle("  Unfollow  ", for: .normal)
                }
            }
        }
    }
    //****************************************** END GET FOLLOW STATUS BETWEEN 2 USERS ******************************************
    
    //****************************************** UNFOLLOW AS USER SEQUENCE ******************************************
    // The function to remove a follow between the 2 users based on the specified user ids
    func removeFollow(otherUserId: String) {
        // Call the function to remove a follow between 2 users
        followRepository.removeAFollowBetween2Users(userId: otherUserId) { (isRemoved) in
            // Set content of the button to be "  Follow  "
            DispatchQueue.main.async {
                self.followUnfollowButtonObject.setTitle("  Follow  ", for: .normal)
            }
        }
    }
    //****************************************** END UNFOLLOW AS USER SEQUENCE ******************************************
    
    //****************************************** GO TO MESSAGE ******************************************
    /*
     We will do 3 things here
     1. Get id of the currently logged in user
     2. Check for chat room between the 2 users
     3. Take user to the view controller where the user can start chatting
     */
    
    // The function to check for chat room between the 2 users
    func checkChatRoonmAndGotoChat(selectedUserId: String) {
        // Call the function to get chat room between the 2 users and go to chat
        messageRepository.getChatRoomBetween2Users(userId: selectedUserId) { (chatRoomObject) in
            // Assign this chat room to the selected chat room object property in the profile detail view controller
            //self.delegate.updateChatRoomObject(chatRoomObject: chatRoomObject)
            
            print(chatRoomObject)
            
            // Call the function to perform segue and take user to the view controller where the user can start chatting
            DispatchQueue.main.async {
                self.delegate.updateChatRoomObject(chatRoomObject: chatRoomObject)
            }
        }
    }
    //****************************************** END GO TO MESSAGE ******************************************
}
