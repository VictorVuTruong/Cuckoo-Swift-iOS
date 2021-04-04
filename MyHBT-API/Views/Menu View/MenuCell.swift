//
//  MenuCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 1/17/21.
//  Copyright © 2021 beta. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    var delegate: PostLikeCellDelegator!
    
    // Post id of the post to be deleted or edit
    var postId = ""
    
    // The view which will take action when user tap on it
    @IBOutlet weak var backView: UIView!
    
    // Description of the menu item
    @IBOutlet weak var menuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Create tap gesture recognizer for the menu item
        let tapGestureMenuItem = UITapGestureRecognizer(target: self, action: #selector(MenuCell.viewTappedEditOrDeletePost))
        
        // Add tap gesture to the menu item
        backView.addGestureRecognizer(tapGestureMenuItem)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //**************************************** TAP GESTURES ****************************************
    // The function which will let user edit post or delete it
    @objc func viewTappedEditOrDeletePost(gesture: UIGestureRecognizer) {
        // Check to make sure that view is not nil
        if (gesture.view) != nil {
            // Check to see if title of the label is edit or delete
            if (menuLabel.text! == "Delete") {
                DispatchQueue.main.async {
                    // Call the function to delete a post
                    self.delegate.deleteAPost()
                }
            }
        }
    }
    //**************************************** END TAP GESTURES ****************************************
}
