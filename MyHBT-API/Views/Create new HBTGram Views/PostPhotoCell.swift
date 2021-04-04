//
//  PostPhotoCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/17/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class PostPhotoCell: UITableViewCell {
    var delegate: PostPhotoCellDelegator!

    // ImageView which will be used to display photo at the selected cell
    @IBOutlet weak var postPhotoView: UIImageView!
    
    // The variable which hold information about which photo number it is
    var photoNumber = 0
    
    // The button to remove photo at this row
    @IBAction func deleteButton(_ sender: UIButton) {
        // Set the photo position to remove in the CreateNewHBTGramPostViewController so that the view controller knows which image position to remove
        CreateNewPostViewController.photoPositionToRemove = photoNumber
        
        // Call the function to delete the photo at this position
        deletePhoto()
    }
    
    // The function to delete photo from post
    func deletePhoto () {
        self.delegate.deletePhoto()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
