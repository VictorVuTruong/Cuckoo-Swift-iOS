//
//  SearchFriendCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/14/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class SearchFriendCell: UITableViewCell {
    var delegate:SearchFriendCellDelegator!
    
    // User object at this cell
    var userObject = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // The view which surrounds the search user cell
    @IBOutlet weak var searchUserCellView: UIView!
    
    // Avatar of the user at this row
    @IBOutlet weak var userAvatar: UIImageView!
    
    // Full name of the user at this row
    @IBOutlet weak var userFullName: UILabel!
    
    // The label which let the current user know if user at this row is being followed or not
    @IBOutlet weak var followStatus: UILabel!
    
    // User repository
    let userRepository = UserRepository()
    
    // Follow repository
    let followRepository = FollowRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // create tap gesture recognizer for the view which will take user to the view controller where the user
        // can see profile detail of the selected user
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(SearchFriendCell.viewTappedGotoProfileDetail(gesture:)))
        
        // Add tap gesture to the view
        searchUserCellView.addGestureRecognizer(tapGestureView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Call the function to make the avatar look round
        AdditionalFunctions.init().makeRounded(image: userAvatar)
    }
    
    //***************************************** TAP GESTURE RECOGNIZER *****************************************
    // The function which will take user to the view controller where the user can profile detail of the selected user
    @objc func viewTappedGotoProfileDetail(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Set the selected user object property in the search friend view controller to be user at this row
            SearchFriendViewController.selectedUserObject = userObject
            
            // Call the function to perform segue and take user to the view controller where the user can see profile detail of the selected user
            delegate.callSegueFromCell(myData: "" as AnyObject)
        }
    }
    //***************************************** END TAP GESTURE RECOGNIZER *****************************************
    
    // The function to get info of the user at this cell
    func getInfoOfUser(userId: String) {
        // Call the function to load info of the user at this cell
        AdditionalFunctions.init().getUserFullNameAndAvatar(userId: userId, senderFullName: userFullName, senderAvatar: userAvatar)
    }
    
    // The function to check following status between the current user and the user at this cell
    func getFollowStatus(otherUserId: String) {
        // Call the function to get follow status between current user and user at this row
        followRepository.checkFollowStatusBetween2Users(userId: otherUserId) { (isFollowed) in
            // Check the follow status and return the right thing
            if (isFollowed) {
                // If isFollowed is true, set content of label to be "Following"
                DispatchQueue.main.async {
                    self.followStatus.text = "Following"
                }
            } // Otherwise, set content of the label to be "Not following"
            else {
                DispatchQueue.main.async {
                    self.followStatus.text = "Not Following"
                }
            }
        }
    }
}
