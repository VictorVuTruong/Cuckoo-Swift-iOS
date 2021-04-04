//
//  PostDetailHeaderCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/5/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class PostDetailHeaderCell: UITableViewCell {
    var delegate:PostLikeCellDelegator!
    
    // Post writer user object
    var postWriterUserObject = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // Avatar of the post writer
    @IBOutlet weak var postWriterAvatar: UIImageView!
    
    // Full name of the post writer
    @IBOutlet weak var postWriterFullName: UILabel!
    
    // Date created of the post
    @IBOutlet weak var dateCreated: UILabel!
    
    // The view which wrap around the user info view
    @IBOutlet weak var userInfoView: UIView!
    
    // User repository
    let userRepository = UserRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make avatar of the post writer look round
        AdditionalFunctions.init().makeRounded(image: postWriterAvatar)
        
        // Create tap gesture recognizer for the user info view
        let tapGestureUserInfoView = UITapGestureRecognizer(target: self, action: #selector(PostDetailHeaderCell.viewTappedPostWriterProfileDetail))
        
        // Add tap gesture to the view
        userInfoView.addGestureRecognizer(tapGestureUserInfoView)
    }

    //**************************************** TAP GESTURES ****************************************
    // The function which take the user to the profile detail of the post writer
    @objc func viewTappedPostWriterProfileDetail(gesture: UIGestureRecognizer) {
        // Check to make sure that view is not nil
        if (gesture.view) != nil {
            // Call the segue to move to the controller which view post detail
            self.delegate.callSegueFromCellGotoPostWriterProfileDetail(userObject: postWriterUserObject)
        }
    }
    //**************************************** END TAP GESTURES ****************************************
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // The function to load full name and avatar of the post writer
    func loadFullNameAndAvatar(userId: String) {
        // Only load when user id is not blank
        if (userId == "") {
            return
        }
        
        // Call the function to load full name and avatar for the user with specified user id
        AdditionalFunctions.init().getUserFullNameAndAvatar(userId: userId, senderFullName: postWriterFullName, senderAvatar: postWriterAvatar)
        
        // Call the function to get user object of the post writer
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            self.postWriterUserObject = userObject
        }
    }
}
