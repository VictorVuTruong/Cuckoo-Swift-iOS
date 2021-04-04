//
//  NotificationCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 1/1/21.
//  Copyright © 2021 beta. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    var delegate: NotificationCellDelegator!
    
    // Avatar of the user that involve in the notification
    @IBOutlet weak var notificationAvatar: UIImageView!
    
    // The view which will wrap around the notification avatar
    @IBOutlet weak var notificationAvatarView: UIView!
    
    // Content of the notification
    @IBOutlet weak var notificationContent: UILabel!
    
    // The view which will wrap around the notification content
    @IBOutlet weak var notificationContentView: UIView!
    
    // Image of the notification
    @IBOutlet weak var notificationImage: UIImageView!
    
    // Post repository
    let postRepository = PostRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    // Notification repository
    let notificationRepository = NotificationRepository()
    
    // Post id of the post associated with this notification
    var postId = ""
    
    // User id of the user associated with this notification
    var userId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make the avatar look round
        AdditionalFunctions.init().makeRounded(image: notificationAvatar)
        
        // Create tap gesture recognizer for the avatar and add it to the avatar
        let tapGestureAvatar = UITapGestureRecognizer(target: self, action: #selector(NotificationCell.viewTappedGotoProfileDetail(gesture:)))
        notificationAvatarView.addGestureRecognizer(tapGestureAvatar)
        
        // Create tap gesture recognizer for the content view and add it to the view
        let tapGestureContent = UITapGestureRecognizer(target: self, action: #selector(NotificationCell.viewTappedGotoPostDetail(gesture:)))
        notificationContentView.addGestureRecognizer(tapGestureContent)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //*************************************** VIEW TAPPED HANDLERS ***************************************
    // The function which will take user to the view controller where user can see post detail of the selected post
    @objc func viewTappedGotoPostDetail(gesture: UIGestureRecognizer) {
        if (gesture.view) != nil {
            // Call the function which will get info of post based on post id and take user to the view controller where user can see post detail of the selected post
            getPostObjectAndGotoPostDetail(postId: postId)
        }
    }
    
    // The function which will take user to the view controller where user can see profile detail of the selected user
    @objc func viewTappedGotoProfileDetail(gesture: UIGestureRecognizer) {
        if (gesture.view) != nil {
            // Call the function which will get info of post based on post id and take user to the view controller where user can see profile detail of the selected user
            getUserInfoBasedOnIdAndGotoProfileDetail(userId: userId)
        }
    }
    //*************************************** END VIEW TAPPED HANDLERS ***************************************
    
    //******************************* LOAD CONTENT OF NOTIFICATION SEQUENCE *******************************
    /*
     In this sequence, we will do these things
     1. Get info of the user that is associated with this notification based on id
     2. Based on specified from the database, load the right content for the notification
     */
    
    // The function to load info of the user associated with this notification
    func loadInfoOfUserOfNotificationAndContent(userId: String, content: String) {
        // Call the function to load detail notification
        notificationRepository.getNotificationDetail(content: content, userId: userId) { (userObject, notificationContent) in
            DispatchQueue.main.async {
                // Load avatar of the user into the image view
                self.notificationAvatar.sd_setImage(with: URL(string: userObject.avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
                
                // Load content of the notification into the label
                self.notificationContent.text = notificationContent
            }
        }
    }
    //******************************* END LOAD CONTENT OF NOTIFICATION SEQUENCE *******************************
    
    //******************************* LOAD IMAGE OF NOTIFICATION SEQUENCE *******************************
    // The function to load image of the notification
    func loadImageForNotification(imageURL: String) {
        // Only load image if the image URL is not "none"
        if (imageURL == "none") {
            return
        }
        
        // Load image URL of the notification into the image view
        self.notificationImage.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder.jpg"))
    }
    //******************************* END LOAD IMAGE OF NOTIFICATION SEQUENCE *******************************
    
    //******************************* LOAD USER INFO AND GOTO PROFILE DETAIL SEQUENCE *******************************
    // The function to get info of the user based on id
    // And create the object out of the fetched user info
    func getUserInfoBasedOnIdAndGotoProfileDetail(userId: String) {
        // Call the function to get user object of user based on user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            DispatchQueue.main.async {
                // Call the function which will perform segue and take user to the view controller where user can see profile detail of the selected user
                self.delegate.gotoProfileDetailOfUserOfNotification(userObject: userObject)
            }
        }
    }
    //******************************* END LOAD USER INFO AND GOTO PROFILE DETAIL SEQUENCE *******************************
    
    //******************************* LOAD POST DETAIL AND GOTO POST DETAIL SEQUENCE *******************************
    // The function to get information and create post object based on post id
    func getPostObjectAndGotoPostDetail(postId: String) {
        // If the post id is "none", call the function to show the profile detail of user associated with notification
        if (postId == "none") {
            // Call the function
            self.getUserInfoBasedOnIdAndGotoProfileDetail(userId: userId)
            
            // Get out of the function
            return
        }
        
        // Call the function to get post object of post based on post id
        postRepository.getPostObjectBasedOnPostId(postId: postId) { (postObject) in
            DispatchQueue.main.async {
                // Call the function to perform segue and take user to the post detail view controller
                self.delegate.gotoPostDetailOfPostOfNotification(postObject: postObject)
            }
        }
    }
    //******************************* END LOAD POST DETAIL AND GOTO POST DETAIL SEQUENCE *******************************
}
