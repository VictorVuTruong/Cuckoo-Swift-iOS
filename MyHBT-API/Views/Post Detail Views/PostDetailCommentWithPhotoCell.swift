//
//  PostDetailCommentWithPhotoCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/30/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class PostDetailCommentWithPhotoCell: UITableViewCell {
    var delegate:PostLikeCellDelegator!
    
    // User id of the comment writer
    var commentWriterUserId = ""
    
    // Avatar of the comment writer
    @IBOutlet weak var commentWriterAvatar: UIImageView!
    
    // Full name of the comment writer
    @IBOutlet weak var commentWriterFullName: UILabel!
    
    // The image view which will display image of the comment
    @IBOutlet weak var commentImageView: UIImageView!
    
    // The view which will wrap around user info (comment writer)
    @IBOutlet weak var userInfoView: UIView!
    
    // User repository
    let userRepository = UserRepository()
    
    // Comment photo repository
    let commentPhotoRepository = CommentPhotoRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make the avatar look round
        AdditionalFunctions.init().makeRounded(image: commentWriterAvatar)
        
        // Create tap gesture recognizer for the user info view
        let tapGestureUserInfoView = UITapGestureRecognizer(target: self, action: #selector(PostDetailCommentWithPhotoCell.viewTappedPostWriterProfileDetail))
        
        // Add tap gesture to the Views
        userInfoView.addGestureRecognizer(tapGestureUserInfoView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //**************************************** TAP GESTURES ****************************************
    // The function which will take user to the view controller where the user can see profile detail of the post writer
    @objc func viewTappedPostWriterProfileDetail(gesture: UIGestureRecognizer) {
        // Check to make sure that view is not nil
        if (gesture.view) != nil {
            // Call the function to get info of the post writer based on id and go to the view controller
            // where the user can see profile detail of the post writer
            getUserInfoBasedOnIdAndGotoProfileDetail(userId: self.commentWriterUserId)
        }
    }
    //**************************************** END TAP GESTURES ****************************************
    
    // The function to get image of the comment based on id
    func getCommentImageBasedOnId(commentId: String) {
        // Call the function to get image URL of comment based on comment id
        commentPhotoRepository.getCommentPhotoBasedOnCommentId(commentId: commentId) { imageURL in
            DispatchQueue.main.async {
                // Load image into the ImageView
                self.commentImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder.jpg"))
            }
        }
    }
    
    // The function to load writer info
    func loadFullNameAndAvatarForCommentWriter(userId: String) {
        // Call the function to load info for the receiver based on id and load them into image view and label
        AdditionalFunctions.init().getUserFullNameAndAvatar(userId: userId, senderFullName: commentWriterFullName, senderAvatar: commentWriterAvatar)
    }
    
    //******************************************* GET COMMENT WRITER USER OBJECT SEQUENCE *******************************************
    /*
     In this sequence, we will do 2 things
     1. Get info of the comment writer based on user id and create object out of those info
     2. Call the function which will take user to the view controller where the user can see profile detail of the comment writer
     */
    
    // The function to get user info based on id
    func getUserInfoBasedOnIdAndGotoProfileDetail(userId: String) {
        // Call the function to get user object based on user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            DispatchQueue.main.async {
                // Call the function to perform the segue and take user to the view controller where the user can see profile detail of the comment writer
                self.delegate.callSegueFromCellGotoPostWriterProfileDetail(userObject: userObject)
            }
        }
    }
    //******************************************* END GET COMMENT WRITER USER OBJECT SEQUENCE *******************************************
}
