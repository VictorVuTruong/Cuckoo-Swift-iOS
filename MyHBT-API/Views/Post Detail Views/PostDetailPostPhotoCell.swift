//
//  PostDetailPostPhotoCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/5/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import SDWebImage

class PostDetailPostPhotoCell: UITableViewCell {
    // Photo of the post
    @IBOutlet weak var postPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // The function to load image into image view based on the specified URL
    func loadImage(URLString: String) {
        // Load image into the image view
        postPhoto.sd_setImage(with: URL(string: URLString), placeholderImage: UIImage(named: "placeholder.png"))
    }
}
