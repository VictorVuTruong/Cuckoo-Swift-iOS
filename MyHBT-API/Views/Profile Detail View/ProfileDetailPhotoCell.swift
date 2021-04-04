//
//  ProfileDetailPhotoCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/14/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class ProfileDetailPhotoCell: UITableViewCell {
    var delegate: ProfileDetailCellDelegator?
    
    // The view which surround image number 1
    @IBOutlet weak var image1View: UIView!
    
    // The post id which contains image number 1
    var image1PostId = ""
    
    // The post id which contains image number 2
    var image2PostId = ""
    
    // The post id which contains image number 3
    var image3PostId = ""
    
    // The post id which contains image number 4
    var image4PostId = ""
    
    // Image number 1
    @IBOutlet weak var image1: UIImageView!
    
    // The view which surround image number 2
    @IBOutlet weak var image2View: UIView!
    
    // Image number 2
    @IBOutlet weak var image2: UIImageView!
    
    // The view which surround image number 3
    @IBOutlet weak var image3View: UIView!
    
    // Image number 3
    @IBOutlet weak var image3: UIImageView!
    
    // The view which surround image number 4
    @IBOutlet weak var image4View: UIView!
    
    // Image number 4
    @IBOutlet weak var image4: UIImageView!
    
    // Post repository
    let postRepository = PostRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // create tap gesture recognizer for image 1 and add it to image 1
        let tapGestureImage1 = UITapGestureRecognizer(target: self, action: #selector(ProfileDetailPhotoCell.viewTappedImage1(gesture:)))
        image1View.addGestureRecognizer(tapGestureImage1)
        
        // create tap gesture recognizer for image 2 and add it to image 2
        let tapGestureImage2 = UITapGestureRecognizer(target: self, action: #selector(ProfileDetailPhotoCell.viewTappedImage2(gesture:)))
        image2View.addGestureRecognizer(tapGestureImage2)
        
        // create tap gesture recognizer for image 3 and add it to image 3
        let tapGestureImage3 = UITapGestureRecognizer(target: self, action: #selector(ProfileDetailPhotoCell.viewTappedImage3(gesture:)))
        image3View.addGestureRecognizer(tapGestureImage3)
        
        // create tap gesture recognizer for image 4 and add it to image 4
        let tapGestureImage4 = UITapGestureRecognizer(target: self, action: #selector(ProfileDetailPhotoCell.viewTappedImage4(gesture:)))
        image4View.addGestureRecognizer(tapGestureImage4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // The function to load image into image number 1
    func loadImage1(imageURL: String) {
        // Load image into image number 1 image view based on URL
        image1.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder.jpg"))
    }
    
    // The function to load image into image number 2
    func loadImage2(imageURL: String) {
        // Load image into image number 2 image view based on URL
        image2.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder.jpg"))
    }
    
    // The function to load image into image number 3
    func loadImage3(imageURL: String) {
        // Load image into image number 3 image view based on URL
        image3.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder.jpg"))
    }
    
    // The function to load image into image number 4
    func loadImage4(imageURL: String) {
        // Load image into image number 4 image view based on URL
        image4.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder.jpg"))
    }
    
    //*************************************** VIEW TAPPED HANDLERS ***************************************
    // The function which take the user to the post detail when the user tap the view for image 1
    @objc func viewTappedImage1(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Call the function which will take user to the view controller where the user can see post detail
            // of the post associated with image 1
            getPostObjectAndGotoPostDetail(postId: image1PostId)
        }
    }
    
    // The function which take the user to the post detail when the user tap the view for image 2
    @objc func viewTappedImage2(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Call the function which will take user to the view controller where the user can see post detail
            // of the post associated with image 2
            getPostObjectAndGotoPostDetail(postId: image2PostId)
        }
    }
    
    // The function which take the user to the post detail when the user tap the view for image 3
    @objc func viewTappedImage3(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Call the function which will take user to the view controller where the user can see post detail
            // of the post associated with image 3
            getPostObjectAndGotoPostDetail(postId: image3PostId)
        }
    }
    
    // The function which take the user to the post detail when the user tap the view for image 1
    @objc func viewTappedImage4(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Call the function which will take user to the view controller where the user can see post detail
            // of the post associated with image 4
            getPostObjectAndGotoPostDetail(postId: image4PostId)
        }
    }
    //*************************************** END VIEW TAPPED HANDLERS ***************************************
    
    //*************************************** CREATE POST OBJECT OF THE POST ASSOCIATED WITH THE PHOTO AND GO TO POST DETAIL ***************************************
    // The function to get information and create post object based on post id
    func getPostObjectAndGotoPostDetail(postId: String) {
        // If the post id is blank, get out of the sequence
        if (postId == "") {
            return
        }
        
        // Call the function to get post object of the post with specified post id
        postRepository.getPostObjectBasedOnPostId(postId: postId) { (postObject) in
            DispatchQueue.main.async {
                // Call the function to perform the segue and take user to the view controller where the user can see post detail
                // of the post associated with the photo
                self.delegate?.callSegueFromCellGotoPostDetail(postObject: postObject)
            }
        }
    }
    //*************************************** END CREATE POST OBJECT OF THE POST ASSOCIATED WITH THE PHOTO AND GO TO POST DETAIL ***************************************
}
