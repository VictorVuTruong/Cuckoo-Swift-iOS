//
//  UserStatsContentCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/22/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class UserStatsContentCell: UITableViewCell {
    var delegate: UserStatsCellDelegator?
    var delegateUserStatsDetail: UserStatsDetailCellDelegator?
    
    // USer id of the user at this row
    var userId = ""
    
    // Image of the user stats content
    @IBOutlet weak var userStatsContentAvatar: UIImageView!
    
    // Content of the user stats content
    @IBOutlet weak var userStatsContentContent: UILabel!
    
    // Sub-content of the user stats content
    @IBOutlet weak var userStatsContentSubContent: UILabel!
    
    // The view which will wrap around user stats content info
    @IBOutlet weak var userStatsView: UIView!
    
    // User repository
    let userRepository = UserRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make avatar look round
        AdditionalFunctions.init().makeRounded(image: userStatsContentAvatar)
        
        // Create tap gesture recognizer for the user stats view
        let tapGestureUserStatsView = UITapGestureRecognizer(target: self, action: #selector(UserStatsContentCell.viewTappedProfileDetail))
        
        // Add tap gesture to the Views
        userStatsView.addGestureRecognizer(tapGestureUserStatsView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //**************************************** TAP GESTURES ****************************************
    // The function which take the user to the post detail when the user tap the view
    @objc func viewTappedProfileDetail(gesture: UIGestureRecognizer) {
        // Check to make sure that view is not nil
        if (gesture.view) != nil {
            // Call the function to get info of the currently logged in user and go to the profile detail page
            createUserObjectBasedOnUserIdAndGotoProfileDetail(userId: userId)
        }
    }
    //**************************************** END TAP GESTURES ****************************************
    
    //**************************************** GET USER INFO ****************************************
    // The function to load user info at this row
    func loadUserInfoBasedOnId (userId: String) {
        // Call the function to load user info
        AdditionalFunctions.init().getUserFullNameAndAvatar(userId: userId, senderFullName: userStatsContentContent, senderAvatar: userStatsContentAvatar)
    }
    //**************************************** END GET USER INFO ****************************************
    
    //**************************************** GET USER OBJECT AND GO TO PROFILE ****************************************
    // The function to create user object of the user based on id and go to profile detail page
    func createUserObjectBasedOnUserIdAndGotoProfileDetail(userId: String) {
        // Call the function to get info of user with specified user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            // If delegate object is nil, it means that the user stats view controller is using this row
            if (self.delegate != nil) {
                // Call the function to perform segue and take user to the view controller where the user can see profile detail of user at this row
                DispatchQueue.main.async {
                    self.delegate?.callSegueFromCellShowProfileDetailOfUser(userObject: userObject)
                }
            } else {
                // Set the selected user object property in the user stats detail view controller to be the user object obtained here
                UserStatsDetailViewController.selectedUserObjectToShowProfile = userObject
                
                // Call the function to perform segue and take user to the view controller where the user can see profile detail of user at this row
                DispatchQueue.main.async {
                    self.delegateUserStatsDetail?.callSegueFromCellShowProfileDetailOfUser(userObject: userObject)
                }
            }
        }
    }
    //**************************************** END GET USER OBJECT AND GO TO PROFILE ****************************************
}
