//
//  UserViewCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/1/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class UserViewCell: UITableViewCell {
    var delegate: GotoProfileDetailFromUserViewCellDelegator!
    
    // User object at this row
    var userObject = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // Avatar of the user
    @IBOutlet weak var userAvatar: UIImageView!
    
    // Full name of the user
    @IBOutlet weak var userFullName: UILabel!
    
    // The view which will wrap around the user view
    @IBOutlet weak var userShowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make user avatar look round
        AdditionalFunctions.init().makeRounded(image: userAvatar)
        
        // create tap gesture recognizer for the user show view
        let tapGestureUserShowView = UITapGestureRecognizer(target: self, action: #selector(UserViewCell.viewTappedUserView(gesture:)))
        
        // Add tap gesture to the user Views
        userShowView.addGestureRecognizer(tapGestureUserShowView)
    }

    //************************************ VIEW TAP HANDLERS ************************************
    // The function which handle event of when view is tapped (user show view)
    @objc func viewTappedUserView(gesture: UIGestureRecognizer) {
        // Set the selected user object in the user view view controller to be user at this row
        UserViewViewController.selectedUser = userObject
        
        // Call the function to perform segue and take user to the view controller where the user can see profile detail of the selected user
        delegate.callSegueFromCellGotoProfileDetail(myData: "" as AnyObject)
    }
    //************************************ END VIEW TAP HANDLERS ************************************
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // The function to load full name and avatar of the user to show
    func loadFullNameAndAvatar(userId: String) {
        // Call the function to load avatar and full name of the user
        AdditionalFunctions.init().getUserFullNameAndAvatar(userId: userId, senderFullName: userFullName, senderAvatar: userAvatar)
    }
}
