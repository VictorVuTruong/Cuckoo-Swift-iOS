//
//  PostDetailNumberOfLikesAndCommentsCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/5/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class PostDetailNumberOfLikesAndCommentsCell: UITableViewCell {
    var delegate: PostLikeCellDelegator!
    
    // Post object of the post being shown
    var postObject = CuckooPost(content: "", writer: "", _id: "", numOfImages: 0, orderInCollection: 0, dateCreated: "")
    
    // The like button
    @IBAction func likeButton(_ sender: UIButton) {
        // Call the function to create new like
        checkLikeStatusAndCreateNewLike(postId: postObject._id)
    }
    
    // The like button object
    @IBOutlet weak var likeButtonObject: UIButton!
    
    // The view which surround the number of likes
    // (when tapped, it will take user to the view controller where the user can see list of users who like the post)
    @IBOutlet weak var likeButtonView: UIView!
    
    // Number of likes
    @IBOutlet weak var numOfLikes: UILabel!
    
    // Numbebr of comments
    @IBOutlet weak var numOfComments: UILabel!
    
    // Some objects for the like button
    private let unlikedImage = UIImage(named: "likeButtonUnlikedPic")
    private let likedImage = UIImage(named: "likeButtonLikedPic")
    private let unlikedScale: CGFloat = 0.7
    private let likedScale: CGFloat = 1.3
    
    // Comment and like repository
    let commentAndLikeRepository = CommentAndLikeRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Create tap gesture recognizer for the like button view
        let tapGestureViewLikeButton = UITapGestureRecognizer(target: self, action: #selector(PostDetailNumberOfLikesAndCommentsCell.viewTappedLikeButton(gesture:)))
        
        // Add tap gesture recognizer to the like button view
        likeButtonView.addGestureRecognizer(tapGestureViewLikeButton)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //**************************************** VIEW TAP HANDLERS ****************************************
    // The function which will handle action of when view is tapped (like button view)
    @objc func viewTappedLikeButton(gesture: UIGestureRecognizer) {
        // Call the function which will take user to the view controller where the user can see who like the post
        self.delegate.callSegueFromCellGotoListOfLikes(myData: "" as AnyObject)
    }
    //**************************************** VIEW TAP HANDLERS ****************************************
    
    //**************************************** LOAD NUMBER OF LIKES AND COMMENTS SEQUENCE ****************************************
    // The function to load number of likes of the post
    func loadNumOfLikes(postId: String) {
        // Call the function to load num of likes of post with specified post id
        commentAndLikeRepository.getNumOfLikesOfPost(postId: postId) { (numOfLikes) in
            // Load number of likes into the label
            DispatchQueue.main.async {
                self.numOfLikes.text = "\(numOfLikes) likes"
            }
        }
    }
    
    // The function to load number of comments of the post
    func loadNumOfComments(postId: String) {
        // Call the function to load num of comments of post with specified post id
        commentAndLikeRepository.getNumOfCommentsOfPost(postId: postId) { (numOfComments) in
            // Load number of comments into the label
            DispatchQueue.main.async {
                self.numOfComments.text = "\(numOfComments) comments"
            }
        }
    }
    //**************************************** END LOAD NUMBER OF LIKES AND COMMENTS SEQUENCE ****************************************
    
    //**************************************** LIKE BUTTON EVENTS ****************************************
    // The function to check like status and add new like for the post
    func checkLikeStatusAndCreateNewLike(postId: String) {
        // Call the function to create new like for post by the current user
        commentAndLikeRepository.createNewLike(postId: postId) { (likeCreated) in
            // If new like was created, set image of the button to be the filled heart
            if (likeCreated) {
                DispatchQueue.main.async {
                    // Set image
                    self.likeButtonObject.setImage(self.likedImage, for: .normal)
                    
                    // Animate
                    UIView.animate(withDuration: 0.1, animations: {
                        self.likeButtonObject.transform = self.transform.scaledBy(x: self.likedScale, y: self.likedScale)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.1, animations: {
                            self.likeButtonObject.transform = CGAffineTransform.identity
                        })
                    })
                    
                    // Call the function to load number of likes again
                    self.loadNumOfLikes(postId: self.postObject._id)
                    
                    // Call the function to send notification to the post writer (through the protocol)
                    self.delegate.sendNotificationToPostWriter(forUser: self.postObject.writer, content: "liked")
                }
            } // Otherwise, set image of the button to be the unfilled heart
            else {
                DispatchQueue.main.async {
                    // Set image
                    self.likeButtonObject.setImage(self.unlikedImage, for: .normal)
                    
                    // Animate
                    UIView.animate(withDuration: 0.1, animations: {
                        self.likeButtonObject.transform = self.transform.scaledBy(x: self.unlikedScale, y: self.unlikedScale)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.1, animations: {
                            self.likeButtonObject.transform = CGAffineTransform.identity
                        })
                    })
                    
                    // Call the function to load number of likes again
                    self.loadNumOfLikes(postId: self.postObject._id)
                }
            }
        }
    }
    //**************************************** END LIKE BUTTON EVENTS ****************************************
    
    //**************************************** LIKE BUTTON ON CLICK PROCESS ****************************************
    /*
     In this sequence, we will do these things
     1. Get info of the current user
     2. Get like status of the current user and the post
     3. Set up the like button based on the like status
     4. We also have a function to handle tap gesture for the like button
     */
    
    // The function to get like status of the user and the post
    func getLikeStatus(postId: String) {
        // Call the function to get like status between current user and post with specified post id
        commentAndLikeRepository.getLikeStatus(postId: postId) { (isLiked) in
            // If the post is liked, call the function to set up the like button
            // and let the function know that user has liked the post
            if (isLiked) {
                DispatchQueue.main.async {
                    self.likeButtonObject.setImage(self.likedImage, for: .normal)
                }
            } // Otherwise, call the function to set up the like button and let the function know that user has
            // not liked the post
            else {
                DispatchQueue.main.async {
                    self.likeButtonObject.setImage(self.unlikedImage, for: .normal)
                }
            }
        }
    }
}
