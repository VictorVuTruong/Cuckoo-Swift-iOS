//
//  MessageWithPhotoCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/7/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class MessageWithPhotoCell: UITableViewCell {
    // Avatar of the message sender
    @IBOutlet weak var senderAvatar: UIImageView!
    
    // Full name of the message sender
    @IBOutlet weak var senderFullName: UILabel!
    
    // Photo of the message
    @IBOutlet weak var messagePhoto: UIImageView!
    
    // Message photo repository
    let messagePhotoRepository = MessagePhotoRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make avatar look round
        AdditionalFunctions.init().makeRounded(image: senderAvatar)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // The function to load image of the message based on the specified message id
    func getMessagePhotoBasedOnMessageId(messageId: String) {
        // Call the function to get message photo of message based on message
        messagePhotoRepository.getMessagePhotoBasedOnMessageId(messageId: messageId) { (imageURL) in
            DispatchQueue.main.async {
                // Load image into the ImageView
                self.messagePhoto.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder.jpg"))
            }
        }
    }
    
    // The function to load sender info
    func loadSenderInfo(userId: String) {
        // Call the function to get info of user based on user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            DispatchQueue.main.async {
                // Load avatar of sender into the image view
                self.senderAvatar.sd_setImage(with: URL(string: userObject.avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
                
                // Load full name of sender into the label
                self.senderFullName.text = userObject.fullName
            }
        }
    }
}
