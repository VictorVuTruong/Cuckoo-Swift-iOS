//
//  CommentOptionMenuCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 1/19/21.
//  Copyright © 2021 beta. All rights reserved.
//

import UIKit

class CommentOptionMenuCell: UITableViewCell {
    var delegate: PostLikeCellDelegator!
    
    // Title of the option
    @IBOutlet weak var menuLabel: UILabel!
    
    // Back view of the cell
    // Will handle action when user tap on it
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Create tap gesture recognizer for the menu item
        let tapGestureMenuItem = UITapGestureRecognizer(target: self, action: #selector(CommentOptionMenuCell.viewTappedEditOrDeleteComment))
        
        // Add tap gesture to the menu item
        backView.addGestureRecognizer(tapGestureMenuItem)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //**************************************** TAP GESTURES ****************************************
    // The function which will let user edit comment or delete it
    @objc func viewTappedEditOrDeleteComment(gesture: UIGestureRecognizer) {
        // Check to make sure that view is not nil
        if (gesture.view) != nil {
            // Check to see if title of the label is edit or delete
            if (menuLabel.text! == "Delete comment") {
                // Call the function to start deleting the comment
                delegate.deleteComment()
            }
        }
    }
    //**************************************** END TAP GESTURES ****************************************
}
