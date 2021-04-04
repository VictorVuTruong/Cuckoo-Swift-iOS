//
//  HBTGramPostCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/4/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import SDWebImage

class CuckooPostCell: UITableViewCell {
    var delegate:PostDetailCellDelegator!
    
    // The post object of post at this position
    var postObject = CuckooPost(content: "", writer: "", _id: "", numOfImages: 0, orderInCollection: 0, dateCreated: "")
    
    // UIView which hold the post content
    @IBOutlet weak var postContentView: UIView!
    
    // UIView which hold the post photo
    @IBOutlet weak var postPhotoView: UIView!
    
    // Avatar of the post writer
    @IBOutlet weak var writerAvatar: UIImageView!
    
    // Full name of the post writer
    @IBOutlet weak var writerFullName: UILabel!
    
    // Date created of the post
    @IBOutlet weak var dateCreated: UILabel!
    
    // Content of the post
    @IBOutlet weak var postContent: UILabel!
    
    // First image of the post
    @IBOutlet weak var postImage: UIImageView!
    
    // Number of likes of the post
    @IBOutlet weak var numOfLikes: UILabel!
    
    // Number of comments of the post
    @IBOutlet weak var numOfComments: UILabel!

    // The view which wrap around the user info (It will take user to the view controller where the user can see info of the post writer)
    @IBOutlet weak var userInfoView: UIView!
    
    // The like button
    @IBAction func likeButton(_ sender: UIButton) {
        // Call the function to create new like
        checkLikeStatusAndCreateNewLike(postId: postObject._id)
    }
    
    // The like button object
    @IBOutlet weak var likeButtonObject: UIButton!
    
    // Some objects for the like button
    private let unlikedImage = UIImage(named: "likeButtonUnlikedPic")
    private let likedImage = UIImage(named: "likeButtonLikedPic")
    private let unlikedScale: CGFloat = 0.7
    private let likedScale: CGFloat = 1.3
    
    // The comment button
    @IBAction func commentButton(_ sender: Any) {
        // Call the segue to move to the controller which view post detail
        self.delegate.callSegueFromCellShowPostDetail(postObject: self.postObject)
    }

    // The post comment button
    @IBAction func postCommentButton(_ sender: Any) {
    }
    
    // Avatar of the currently logged in user
    @IBOutlet weak var userAvatar: UIImageView!
    
    // Content of the comment to post
    @IBOutlet weak var commentContentField: UITextField!
    
    // Photo repository
    let photoRepository = PhotoRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    // Post repository
    let postRepository = PostRepository()
    
    // Comment and like repository
    let commentAndLikeRepository = CommentAndLikeRepository()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Call the function to make writer and user avatar look round
        AdditionalFunctions.init().makeRounded(image: userAvatar)
        AdditionalFunctions.init().makeRounded(image: writerAvatar)

        // Call the function to load avatar for the currently logged in user
        loadAvatarForCurrentUser()
        
        // Create tap gesture recognizer for the post content and photo view
        let tapGestureView = UITapGestureRecognizer(target: self, action: #selector(CuckooPostCell.viewTappedPostDetail))
        
        // Create tap gesture recognizer for the user info view
        let tapGestureUserInfoView = UITapGestureRecognizer(target: self, action: #selector(CuckooPostCell.viewTappedPostWriterProfileDetail))
        
        // Add tap gesture to the Views
        postContentView.addGestureRecognizer(tapGestureView)
        postPhotoView.addGestureRecognizer(tapGestureView)
        userInfoView.addGestureRecognizer(tapGestureUserInfoView)
    }

    //**************************************** TAP GESTURES ****************************************
    // The function which take the user to the post detail when the user tap the view
    @objc func viewTappedPostDetail(gesture: UIGestureRecognizer) {
        // Check to make sure that view is not nil
        if (gesture.view) != nil {
            // Call the function to take user to the view controller where user can see post detail of the selected post
            delegate.callSegueFromCellShowPostDetail(postObject: self.postObject)
        }
    }
    
    // The function which will take user to the view controller where the user can see profile detail of the post writer
    @objc func viewTappedPostWriterProfileDetail(gesture: UIGestureRecognizer) {
        // Check to make sure that view is not nil
        if (gesture.view) != nil {
            // Call the function to get info of the post writer based on id and go to the view controller
            // where the user can see profile detail of the post writer
            getUserInfoBasedOnIdAndGotoProfileDetail(userId: self.postObject.writer)
        }
    }
    //**************************************** END TAP GESTURES ****************************************
    
    //**************************************** LOAD FIRST PHOTO OF POST SEQUENCE ****************************************
    // The function to load first photo of the specified post id
    func loadFirstPhoto(postId: String) {
        // Call the function to load first photo of post with specified post id
        photoRepository.getFirstPhotoOfPost(postId: postId) { (firstPhotoURL) in
            // Load that image URL into the image view
            self.postImage.sd_setImage(with: URL(string: firstPhotoURL), placeholderImage: UIImage(named: "placeholder.png"))
        }
    }
    //**************************************** END LOAD FIRST PHOTO OF POST SEQUENCE ****************************************
    
    //**************************************** LOAD INFO OF CURRENT USER SEQUENCE ****************************************
    // The function to load full name and avatar of the post writer
    func loadFullNameAndAvatar(userId: String) {
        // Call the function to load avatar and full name for the post writer
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            DispatchQueue.main.async {
                // Load user full name into label
                self.writerFullName.text = userObject.fullName
                
                // Load user avatar into image view
                self.writerAvatar.sd_setImage(with: URL(string: userObject.avatarURL), placeholderImage: UIImage(named: "placeholder.png"))
            }
        }
    }
    
    // The function to load avatar of the currently logged in user
    func loadAvatarForCurrentUser() {
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Load current user avatar into the image view
            self.userAvatar.sd_setImage(with: URL(string: userObject.avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
        }
    }
    //**************************************** END LOAD INFO OF CURRENT USER SEQUENCE ****************************************
    
    //**************************************** LOAD NUMBER OF LIKES AND COMMENTS SEQUENCE ****************************************
    // The function to load number of likes of the post
    func loadNumOfLikes(postId: String) {
        // Call the function to get number of likes of
        commentAndLikeRepository.getNumOfLikesOfPost(postId: postId) { (numOfLikes) in
            // Load number of likes into the label
            DispatchQueue.main.async {
                self.numOfLikes.text = "\(numOfLikes) likes"
            }
        }
    }
    
    // The function to load number of comments of the post
    func loadNumOfComments(postId: String) {
        // Call the function to get number of comments of post with specified post id
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
        // Call the function to create new like or remove a like
        commentAndLikeRepository.createNewLike(postId: postId) { (isLiked) in
            // Based on status of the procedure to set the right image for the like button
            if (isLiked) {
                // If new like was created, set image of the button to be the filled heart
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
        // Call the function to get like status of the user and the post
        commentAndLikeRepository.getLikeStatus(postId: postId) { (isLiked) in
            print(isLiked)
            
            // Set up the like button based on like status
            if (isLiked) {
                DispatchQueue.main.async {
                    self.likeButtonObject.setImage(self.likedImage, for: .normal)
                }
            } else {
                DispatchQueue.main.async {
                    self.likeButtonObject.setImage(self.unlikedImage, for: .normal)
                }
            }
        }
    }
    //**************************************** LIKE BUTTON ON CLICK PROCESS ****************************************
    
    //**************************************** GET USER INFO BASED ON ID AND GOTO PROFILE DETAIL SEQUENCE ****************************************
    /*
     In this sequence, we will do 3 things
     1. Get user info based on id and create the object out of that
     2. Set selected user object in the hbt gram view controller to be the created user object
     3. Call the function to perform the segue and take user to the view controller where the user can see info of the post writer
     */
    
    // The function to get info of the user based on id
    // And create the object out of the fetched user info
    func getUserInfoBasedOnIdAndGotoProfileDetail(userId: String) {
        // Call the function to get user object based on user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            // Call the function to perform the segue and take user to the view controller where the user can see profile detail of the
            // post writer
            DispatchQueue.main.async {
                self.delegate.callSegueFromCellShowProfileDetailOfPostWriter(userObject: userObject)
            }
        }
    }
    //**************************************** END GET USER INFO BASED ON ID SEQUENCE ****************************************
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
