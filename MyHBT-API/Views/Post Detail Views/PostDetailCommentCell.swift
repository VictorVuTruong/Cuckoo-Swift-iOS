//
//  PostDetailCommentCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/5/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class PostDetailCommentCell: UITableViewCell {
    var delegate:PostLikeCellDelegator!
    
    // Comment object at this row
    var commentObject = CuckooPostComment(_id: "", writer: "", content: "", postId: "", orderInCollection: 0)
    
    // The button to show options for the comment
    @IBAction func commentOptionButton(_ sender: UIButton) {
        // Call the function to open the comment options
        delegate.openCommentOptionsMenu(commentWriterUserId: commentObject.writer, commentIdShowingOptions: commentObject._id)
    }
    
    // The view which will wrap around the user info
    @IBOutlet weak var userInfoView: UIView!
    
    // Avatar of the comment writer
    @IBOutlet weak var commentWriterAvatar: UIImageView!
    
    // Full name of the comment writer
    @IBOutlet weak var commentWriterFullName: UILabel!
    
    // Content of of the comment
    @IBOutlet weak var commentComment: UILabel!
    
    // User repository
    let userRepository = UserRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make avatar of the user look round
        AdditionalFunctions.init().makeRounded(image: commentWriterAvatar)
        
        // Create tap gesture recognizer for the user info view
        let tapGestureUserInfoView = UITapGestureRecognizer(target: self, action: #selector(PostDetailCommentCell.viewTappedPostWriterProfileDetail))
        
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
            getUserInfoBasedOnIdAndGotoProfileDetail(userId: self.commentObject.writer)
        }
    }
    //**************************************** END TAP GESTURES ****************************************
    
    // The function to load full name and avatar of the comment writer
    func loadFullNameAndAvatarForCommentWriter(userId: String) {
        // Call the function to load full name and avatar of the comment writer
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
        // Call the function to get info of user based on user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            DispatchQueue.main.async {
                // Call the function to perform the segue and take user to the view controller where the user can see profile detail of the comment writer
                self.delegate.callSegueFromCellGotoPostWriterProfileDetail(userObject: userObject)
            }
        }
    }
    //******************************************* END GET COMMENT WRITER USER OBJECT SEQUENCE *******************************************
}
