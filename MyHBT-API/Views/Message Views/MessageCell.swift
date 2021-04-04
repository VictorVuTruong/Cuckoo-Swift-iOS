//
//  MessageCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/29/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    // Avatar of the sender
    @IBOutlet weak var senderAvatar: UIImageView!
    
    // Full name of the sender
    @IBOutlet weak var senderFullName: UILabel!
    
    // Content of the message
    @IBOutlet weak var messageContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make avatar look round
        AdditionalFunctions.init().makeRounded(image: senderAvatar)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // The function to load full name and avatar of the message sender based on user id
    func getUserFullNameAndAvatar(userId: String) {
        // Call the function to load avatar and full name for the user based on id
        AdditionalFunctions.init().getUserFullNameAndAvatar(userId: userId, senderFullName: senderFullName, senderAvatar: senderAvatar)
    }
}
