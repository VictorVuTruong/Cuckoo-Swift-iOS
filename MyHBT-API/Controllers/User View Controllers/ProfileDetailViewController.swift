//
//  ProfileDetailViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/14/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class ProfileDetailViewController: UIViewController, ProfileDetailCellDelegator {
    // The boolean to keep track of if the selected user is the currently logged in user or not
    var isCurrentUser = false
    
    // User id of the currently logged in user
    var currentUserId = ""
    
    // Selected chat room id (used in case user need to go to the view controller where the user can start chatting)
    var chatRoomId = ""
    
    // Selected chat room object (used in case user need to go to the view controller where the user can start chatting)
    var chatRoomObject = MessageRoom(_id: "", user1: "", user2: "")
    
    // Post object of the selected post (used in case user need to go to view controller where the user can see post detail of the selected
    // photo associated with the post)
    var postObject = CuckooPost(content: "", writer: "", _id: "", numOfImages: 0, orderInCollection: 0, dateCreated: "")
    
    // The selected use object
    var userObject = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // Array of images of the post
    var arrayOfImages: [CuckooPostPhoto] = []
        
    // Photo repository
    let photoRepository = PhotoRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    // User stats repository
    let userStatsRepository = UserStatsRepository()
    
    // The table view which will display profile detail of the user
    @IBOutlet weak var profileDetailView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate method to get data for the table view
        profileDetailView.dataSource = self
        
        // Register the profile detail header cell for the table view
        profileDetailView.register(UINib(nibName: "ProfileDetailHeaderCell", bundle: nil), forCellReuseIdentifier: "profileDetailHeaderCell")
        
        // Register the profile detail photo cell for the table view
        profileDetailView.register(UINib(nibName: "ProfileDetailPhotoCell", bundle: nil), forCellReuseIdentifier: "profileDetailPhotoCell")
        
        // Call the function to load info of the current user and configure further settings as well as load photos
        getInfoOfCurrentUserAndLoadFurtherInfo()
        
        // Call the function to update profile visit status between the 2 users
        updateUserProfileVisitBetween2Users()
        
        // Let title be the user full name
        self.title = userObject.fullName
    }
    
    //*********************************** LOAD USER INFO SEQUENCE ***********************************
    // The function to load info of the currently logged in user and check to see if the selected user is the currently logged in or not
    func getInfoOfCurrentUserAndLoadFurtherInfo() {
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Check to see if selected user is the currently logged in user or not
            if (self.userObject._id == userObject._id) {
                // Set the boolean which keep track of if the selected user is the current user or not to be true
                self.isCurrentUser = true
                
                // Reload the table view
                DispatchQueue.main.async {
                    self.profileDetailView.reloadData()
                }
            } // Otherwise, set the boolean to be false
            else {
                self.isCurrentUser = false
                
                // Reload the table view
                DispatchQueue.main.async {
                    self.profileDetailView.reloadData()
                }
            }
        }
        
        // Call the function to load images created by the user
        getImagesCreatedByUser(userId: self.userObject._id)
    }
    
    // The function to get images posted by the currently logged in user
    func getImagesCreatedByUser(userId: String) {
        // Call the function to get images created by user with specified user
        photoRepository.getImagesCreatedByUser(userId: userId) { (arrayOfPhotos) in
            // Update the array of post photo objects of this view controller
            self.arrayOfImages += arrayOfPhotos
            
            // Reload the table view
            DispatchQueue.main.async {
                self.profileDetailView.reloadData()
            }
        }
    }
    //*********************************** END LOAD USER INFO SEQUENCE ***********************************
    
    //*********************************** UPDATE USER PROFILE VISIT SEQUENCE ***********************************
    /*
     When user visit the profile, update profile visit between current user and user being visited
     */
    
    // The function to update user profile visit between the 2 users
    func updateUserProfileVisitBetween2Users() {
        // Call the function to update user profile visit between the 2 users
        userStatsRepository.updateUserProfileVisit(userId: self.userObject._id)
    }
    //*********************************** END UPDATE USER PROFILE VISIT SEQUENCE ***********************************
    
    //*********************************** IMPLEMENT FUNCTIONS FOR THE TABLE VIEW ***********************************
    // The function which will take user to the view controller where the user can edit profile info
    func callSegueFromCellGotoEditProfile(myData dataobject: AnyObject) {
        // Perform segue and take user to the view controller where the user can edit profile
        self.performSegue(withIdentifier: "profileDetailToProfilePage", sender: dataobject)
    }
    
    // The function to perform segue and take user to the view controller where the user can start chatting
    func callSegueFromCellGotoChat() {
        // Perform segue and take user to the view controller where the user can start chatting
        self.performSegue(withIdentifier: "profileDetailToChat", sender: self)
    }
    
    // The function to perform segue and take user to the view controller where the user can see post detail
    // of the post associated with the selected photo
    func callSegueFromCellGotoPostDetail(postObject: CuckooPost) {
        // Update the selected post object
        self.postObject = postObject
        
        // Perform the segue
        self.performSegue(withIdentifier: "profileDetailToPostDetail", sender: self)
    }
    
    // The function to perform segue and take user to the view controller where the user can see list of followers
    // of the specified user
    func callSegueFromCellGotoListOfFollowers (myData dataobject: AnyObject) {
        // Perform the segue
        self.performSegue(withIdentifier: "profileDetailToUserViewShowFollower", sender: dataobject)
    }
    
    // The function to perform segue and go to list of followings
    func callSegueFromCellGotoListOfFollowings (myData dataobject: AnyObject) {
        // Perform the segue
        self.performSegue(withIdentifier: "profileDetailToUserViewShowFollowing", sender: dataobject)
    }
    
    // The function to udpate post object before going to the view controller where user can see post detail of the selected post
    func updateSelectedPostObject (postObject: CuckooPost) {
        // Update the post object
        self.postObject = postObject
    }
    
    // The function to update chat room object between the 2 users before going there
    func updateChatRoomObject(chatRoomObject: MessageRoom) {
        print(chatRoomObject)
        
        // If chat room object is a blank object, create a room object with info of the 2 users
        if (chatRoomObject._id == "") {
            // Call the function to get info of the currently logged in user
            userRepository.getInfoOfCurrentUser { (userObject) in
                self.chatRoomObject = MessageRoom(_id: "", user1: userObject._id, user2: self.userObject._id)
                
                // Perform segue and take user to the view controller where the user can start chatting
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "profileDetailToChat", sender: self)
                }
            }
        } else {
            // Update the chat room object
            self.chatRoomObject = chatRoomObject
            
            // Perform segue and take user to the view controller where the user can start chatting
            self.performSegue(withIdentifier: "profileDetailToChat", sender: self)
        }
    }
    //*********************************** END IMPLEMENT FUNCTIONS FOR THE TABLE VIEW ***********************************
    
    //*********************************** PREPARE INFO FOR THE NEXT VIEW CONTROLLER ***********************************
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check to see which segue is used
        if (segue.identifier == "profileDetailToChat") {
            // If the segue will take user to the view controller where the user can start chatting, pass info related to the
            // chat room into the next view controller
            let vc = segue.destination as? ChatViewController
            
            // Set the chat room id object the chat view controller to be the selected one
            vc!.chatRoomObject = self.chatRoomObject
            
            // Set the user id in the chat view controller to be the current user
            //vc!.messageReceiverUserId = userObject.userId
        } // If the segue will take user to the view controller where the user can see post detail of the post associated
        // with the selected photo, pass info of the post to the post detail view controller
        else if (segue.identifier == "profileDetailToPostDetail") {
            // The post detail view controller
            let vc = segue.destination as? PostDetailViewController
            
            // Set the post object property inside the post detail view controller to be the one selected by the user
            vc!.cuckooPostObject = postObject
        } // If the segue will take user to the view controller where the user can see list of followers of the specified user
        // pass info of the selected user into the user view view controller and let the view controller know that it should
        // show list of followers
        else if (segue.identifier == "profileDetailToUserViewShowFollower") {
            // The user view view controller
            let vc = segue.destination as? UserViewViewController
            
            // Set the selected user id in the user view view controller and let it know that it should show list of followers
            vc!.userId = self.userObject._id
            vc!.whatToDo = "getListOfFollowers"
        } // If the segue will take user to the view controller where the user can see list of followings of the specified user
        // pass info of the selected user into the user view view controller and let the view controller know that it should
        // show list of followings
        else if (segue.identifier == "profileDetailToUserViewShowFollowing") {
            // The user view view controller
            let vc = segue.destination as? UserViewViewController
            
            // Set the selected user id in the user view view controller and let it know that it should show list of followings
            vc!.userId = self.userObject._id
            vc!.whatToDo = "getListOfFollowings"
        }
        // Otherwise, don't do anything
        else {
            return
        }
    }
    //*********************************** END PREPARE INFO FOR THE NEXT VIEW CONTROLLER ***********************************
}

// Extension for the table view
extension ProfileDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of rows needed to hold all images + row for the header
        if (arrayOfImages.count % 4 != 0) {
            // Return the number of rows
            return (arrayOfImages.count / 4) + 1 + 1
        } else {
            // Return the number of rows
            return (arrayOfImages.count / 4) + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // First row should be the profile detail header
        if (indexPath.row == 0) {
            // Create a cell for the profile page detail header
            let cell = profileDetailView.dequeueReusableCell(withIdentifier: "profileDetailHeaderCell", for: indexPath) as! ProfileDetailHeaderCell
            
            // Setup user id for the cell
            cell.userId = userObject._id
            
            // Call the function to get basic info of the user
            cell.loadUserBasicInfo(userId: userObject._id)
            
            // Call the function to load user bio
            cell.loadUserBio(userId: userObject._id)
            
            // Call the function to load number of followers and followings of the user
            cell.getNumOfFollowers(userId: userObject._id)
            cell.getNumOfFollowings(userId: userObject._id)
            
            // Call the function to get follow status between the 2 users
            cell.checkFollowStatus(otherUserId: userObject._id)
            
            // Delegate the cell
            cell.delegate = self
            
            // Call the function to get number of posts created by the user
            cell.getNumOfPosts(userId: userObject._id)
            
            // Check the boolean to see if selected user is the current user or not
            if (isCurrentUser) {
                // Show the edit profile button
                cell.editProfileView.isHidden = false
                
                // Hide the follow and message button
                cell.messageFollowView.isHidden = true
            } // Otherwise, hide the edit profile button
            else {
                // Hide the edit profile button
                cell.editProfileView.isHidden = true
                
                // Show the follow and message button
                cell.messageFollowView.isHidden = false
            }
            
            // Return the cell
            return cell
        }
        
        // The rest will just be the photo album of the user
        else {
            // Create the cell for the profile detail photos
            let cell = profileDetailView.dequeueReusableCell(withIdentifier: "profileDetailPhotoCell", for: indexPath) as! ProfileDetailPhotoCell
            
            // Get the remaining number of images
            let remainingNumOfImages = arrayOfImages.count - (indexPath.row - 1) * 4
            
            // Delegate the cell
            cell.delegate = self
            
            // If the remaining number of images is greater than or equal to 4, all columns in the row will be filled
            if (remainingNumOfImages >= 4) {
                // Set up all images in the row
                cell.loadImage1(imageURL: arrayOfImages[((indexPath.row - 1) * 4)].imageURL)
                cell.loadImage2(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 1].imageURL)
                cell.loadImage3(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 2].imageURL)
                cell.loadImage4(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 3].imageURL)
                
                // Set up the post id which go with the picture as well
                cell.image1PostId = arrayOfImages[((indexPath.row - 1) * 4)].postId
                cell.image2PostId = arrayOfImages[((indexPath.row - 1) * 4 + 1)].postId
                cell.image3PostId = arrayOfImages[((indexPath.row - 1) * 4 + 2)].postId
                cell.image4PostId = arrayOfImages[((indexPath.row - 1) * 4 + 3)].postId
            } // If the remaing number of images is 3, just fill in 3 of them
            else if (remainingNumOfImages == 3) {
                // Set up all images in the row
                cell.loadImage1(imageURL: arrayOfImages[((indexPath.row - 1) * 4)].imageURL)
                cell.loadImage2(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 1].imageURL)
                cell.loadImage3(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 2].imageURL)
                
                // Set up the post id which go with the picture as well
                cell.image1PostId = arrayOfImages[((indexPath.row - 1) * 4)].postId
                cell.image2PostId = arrayOfImages[((indexPath.row - 1) * 4 + 1)].postId
                cell.image3PostId = arrayOfImages[((indexPath.row - 1) * 4 + 2)].postId
            } // If the remaining number of image is 2, just fill in 2 of them
            else if (remainingNumOfImages == 2) {
                // Set up all images in the row
                cell.loadImage1(imageURL: arrayOfImages[((indexPath.row - 1) * 4)].imageURL)
                cell.loadImage2(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 1].imageURL)
                
                // Set up the post id which go with the picture as well
                cell.image1PostId = arrayOfImages[((indexPath.row - 1) * 4)].postId
                cell.image2PostId = arrayOfImages[((indexPath.row - 1) * 4 + 1)].postId
            } // If the remaining number of images is 1, just fill in 1 of them
            else if (remainingNumOfImages == 1) {
                // Set up all images in the row
                cell.loadImage1(imageURL: arrayOfImages[((indexPath.row - 1) * 4)].imageURL)
                
                // Set up the post id which go with the picture as well
                cell.image1PostId = arrayOfImages[((indexPath.row - 1) * 4)].postId
            }
            
            // Return the cell
            return cell
        }
    }
}

// Protocol which will be used to enable the table view cell to perform segue
protocol ProfileDetailCellDelegator {
    // The function to call segue and take user to the view controller where the user can edit profile
    func callSegueFromCellGotoEditProfile(myData dataobject: AnyObject)
    
    // The function to call segue and take user to the view controller where the user can start chatting with the selected user
    func callSegueFromCellGotoChat()
    
    // The function to call segue and take user to the view controller where the user can see post detail of the post
    // associated with the selected photo
    func callSegueFromCellGotoPostDetail(postObject: CuckooPost)
    
    // The function to call segue and take user to the view controller where the user can see list of followers of the users
    func callSegueFromCellGotoListOfFollowers(myData dataobject: AnyObject)
    
    // The function to call segue and take user to the view controller where the user can see list of followings of the users
    func callSegueFromCellGotoListOfFollowings(myData dataobject: AnyObject)
    
    // The function to update selected post object
    func updateSelectedPostObject(postObject: CuckooPost)
    
    // The function to update the chat room object between 2 users and go to the chat view controller
    func updateChatRoomObject(chatRoomObject: MessageRoom)
}
