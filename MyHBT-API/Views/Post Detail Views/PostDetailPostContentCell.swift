//
//  PostDetailPostContentCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/5/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class PostDetailPostContentCell: UITableViewCell {
    // Content of the post
    @IBOutlet weak var postContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
