//
//  PostDetailViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/5/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import SocketIO

class PostDetailViewController: UIViewController, PostLikeCellDelegator {
    // Post repository
    let postRepository = PostRepository()
    
    // Photo respository
    let photoRepository = PhotoRepository()
    
    // Comment repository
    let commentRepository = CommentAndLikeRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    // The view which will blur the main view controller when menu is shown
    var transparentView = UIView ()
    
    // Table view for the post options menu
    var tableView = UITableView()
    
    // Table view for the comment options menu
    var tableViewCommentOptionsMenu = UITableView()
    
    // Array of menu items
    let arrayOfMenuItems = ["Edit", "Delete"]
    let arrayOfMenuItemsOtherUser = ["Report", "Unfollow"]
    let arrayOfMenuItemsCommentsOfCurrentUser = ["Edit comment", "Delete comment"]
    let arrayOfMenuItemsCommentsOfOtherUser = ["Delete comment", "Report"]
    
    // Height of the menu
    let menuHeight: CGFloat = 80
    
    // The button to open menu for further options
    @IBAction func openMenuButton(_ sender: UIBarButtonItem) {
        let window = UIApplication.shared.keyWindow
        
        // Blur the main menu
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        
        let screenSize = UIScreen.main.bounds.size
        tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.menuHeight)
        window?.addSubview(tableView)
        
        transparentView.alpha = 0.5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: 0, y: screenSize.height - self.menuHeight, width: screenSize.width, height: self.menuHeight)
        }, completion: nil)
    }
    
    // The function to close the menu when anywhere outside of menu is tapped
    @objc func onClickTransparentView () {
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.menuHeight)
            self.tableViewCommentOptionsMenu.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.menuHeight)
        }, completion: nil)
        
        transparentView.alpha = 0
    }
        
    // Object for socket io
    let manager = SocketManager(socketURL: URL(string: AppResource.init().APIURL)!, config: [.log(true), .compress])
    
    // The table view which will show the post detail
    @IBOutlet weak var postDetailTableView: UITableView!
    
    // Content of the comment to be posted to the database
    @IBOutlet weak var commentContentToPost: UITextField!
    
    // The button to post comment to the database
    @IBAction func postCommentButton(_ sender: UIButton) {
        // Call the function to add new comment to the database
        addCommentToDatabase(commentContent: commentContentToPost.text!, postId: cuckooPostObject._id)
    }
    
    @IBAction func postPhotoCommenButton(_ sender: UIButton) {
        // Perform segue and take user to the view controller where the user can send photo for the comment
        performSegue(withIdentifier: "hbtGramPostDetailToPostCommentPhoto", sender: self)
    }
    
    // HBTGram post object of the selected post
    var cuckooPostObject = CuckooPost(content: "", writer: "", _id: "", numOfImages: 0, orderInCollection: 0, dateCreated: "")
    
    // User object of the post writer (will be updated later in code)
    var postWriterUserObject = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // Array of comments
    var comments: [CuckooPostComment] = []
    
    // Array of image objects
    var images: [CuckooPostPhoto] = []
    
    // User id of the currently logged in user
    var currentUserId = ""
    
    // The variable to keep track of if the comment option menu is showing options for comment by the current user or not
    var isShowingCommentOptionsForCommentByCurrentUser = true
    
    // The variable to keep track of which comment is showing option
    var commentIdShowingOptions = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Delegate method to get data for the table view
        postDetailTableView.dataSource = self
        
        // Register the post header cell the table view
        postDetailTableView.register(UINib(nibName: "PostDetailHeaderCell", bundle: nil), forCellReuseIdentifier: "postDetailHeaderCell")
        
        // Register the post content cell for the table view
        postDetailTableView.register(UINib(nibName: "PostDetailPostContentCell", bundle: nil), forCellReuseIdentifier: "postDetailPostContentCell")
        
        // Register the post photo cell for the table view
        postDetailTableView.register(UINib(nibName: "PostDetailPostPhotoCell", bundle: nil), forCellReuseIdentifier: "postDetailPostPhotoCell")
        
        // Register the post detail number of likes and comments cell for the table view
        postDetailTableView.register(UINib(nibName: "PostDetailNumberOfLikesAndCommentsCell", bundle: nil), forCellReuseIdentifier: "postDetailNumberOfLikesAndCommentsCell")
        
        // Register the post detail comment cell for the table view
        postDetailTableView.register(UINib(nibName: "PostDetailCommentCell", bundle: nil), forCellReuseIdentifier: "postDetailCommentCell")
        
        // Register the post detail comment with photo cell for the table view
        postDetailTableView.register(UINib(nibName: "PostDetailCommentWithPhotoCell", bundle: nil), forCellReuseIdentifier: "postDetailCommentWithPhotoCell")
        
        // Register the post detail is loading comment cell for the table view
        postDetailTableView.register(UINib(nibName: "PostDetaiLoadingCommentCell", bundle: nil), forCellReuseIdentifier: "postDetailLoadingCommentCell")
        
        // Prepare the table view which will be used to show the menu
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "menuCell")
        tableView.reloadData()
        
        // Prepare the table view which will be used to show the comment option menu
        tableViewCommentOptionsMenu.isScrollEnabled = false
        tableViewCommentOptionsMenu.dataSource = self
        tableViewCommentOptionsMenu.register(UINib(nibName: "CommentOptionMenuCell", bundle: nil), forCellReuseIdentifier: "commentOptionMenuCell")
        
        // Call the function to check post
        checkPost(postId: cuckooPostObject._id)
    }
    
    //****************************************** CHECK POST ******************************************
    // The function to check and see if post is accessible or not
    func checkPost(postId: String) {
        // Call the function to check and see if post is accessible or not
        postRepository.checkPost(postId: postId) { (isAccessible) in
            if (isAccessible) {
                // Call the function to update the user object
                self.getUserInfoBasedOnId(userId: self.cuckooPostObject.writer)
                
                // Call the function to load images for the post
                self.loadImages(postId: self.cuckooPostObject._id)
                 
                // Call the function to load comments for the post
                self.loadComments(postId: self.cuckooPostObject._id)
                
                // Call the function to bring user into the post detail room and listen to other comment event
                self.bringUserIntoPostDetailRoomAndListenToCommentEvent(postId: self.cuckooPostObject._id)
                
                // Call the function to get info of the currently logged in user
                self.getInfoOfCurrentUser()
            } else {
                DispatchQueue.main.async {
                    // Show alert and let the user know that post is not available
                    let alert = UIAlertController(title: "Can't show post", message: "Post may have been deleted", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                        // Go to the previous view controller
                        self.navigationController?.popViewController(animated: true)
                        
                        // Get out of the procedure
                        return
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    //****************************************** END CHECK POST ******************************************
    
    //****************************************** WORK WITH SOCKET.IO ******************************************
    // The function to bring user into the post detail room
    func bringUserIntoPostDetailRoomAndListenToCommentEvent(postId: String) {
        // The socket
        let socket = manager.defaultSocket
        
        // Connect to the socket
        socket.connect()
        
        // When the app is connected to the socket, bring user into the chat room
        socket.on(clientEvent: .connect, callback: {data, ack in
            // Emit event and bring user into the message room
            socket.emit("jumpInPostDetailRoom", [
                "postId": self.cuckooPostObject._id
            ])
        })
        
        // Listen to updateComment event. When other user send comment to the database, server will emit this event
        // to let this client app know that there is new message
        socket.on("updateComment", callback: {data, ack in
            // Get the data
            let commentObject = (data[0]) as! [String: Any]
            
            // Get writer of the comment
            let writer = commentObject["writer"] as! String
            
            // Get content of the comment
            let content = commentObject["content"] as! String
            
            // Get id of the comment
            let commentId = commentObject["commentId"] as! String
            
            // Create a new comment out of those info
            let newCommentObject = CuckooPostComment(_id: commentId, writer: writer, content: content, postId: "", orderInCollection: 0)
            
            // Add new comment to the array of comments
            self.comments.append(newCommentObject)
            
            // Reload the table view
            DispatchQueue.main.async {
                self.postDetailTableView.reloadData()
            }
        })
        
        // Listen to updateCommentWithPhoto event. Just the same with the updateComment event
        socket.on("updateCommentWithPhoto", callback: {data, ack in
            // Get the data
            let commentObject = (data[0]) as! [String: Any]
            
            // Get writer of the comment
            let writer = commentObject["writer"] as! String
            
            // Get content of the comment
            let content = commentObject["content"] as! String
            
            // Get id of the comment
            let commentId = commentObject["_id"] as! String
            
            // Create a new comment out of those info
            let newCommentObject = CuckooPostComment(_id: commentId, writer: writer, content: content, postId: "", orderInCollection: 0)
            
            // Add new comment to the array of comments
            self.comments.append(newCommentObject)
            
            // Reload the table view
            DispatchQueue.main.async {
                self.postDetailTableView.reloadData()
            }
        })
    }
    
    // The function to emit event to the server to let the server know that there is a sent comment
    func emitSentEvent(commentObject: CuckooPostComment, postId: String) {
        // The socket
        let socket = manager.defaultSocket
        
        // Emit the sent comment event to the server
        socket.emit("newComment", [
            "commentId" : commentObject._id,
            "writer" : commentObject.writer,
            "content" : commentObject.content,
            "postId" : postId
        ])
    }
    //****************************************** END WORK WITH SOCKET.IO ******************************************
    
    // The function to load all images of the post based on post id
    func loadImages(postId: String) {
        // Call the function to load photos for the post based on post id
        photoRepository.loadPhotosOfPost(postId: postId) { (arrayOfPhotos) in
            // Update the array of image objects
            self.images += arrayOfPhotos
            
            DispatchQueue.main.async {
                // Reload the table view
                self.postDetailTableView.reloadData()
            }
            
            // Loop through the array of images and call the function to update photo label visit status between the user and the photo
            for image in arrayOfPhotos {
                // Call the function to update user photo label visit stats
                self.getPhotoLabelsOfPhotoBasedOnIdAndUpdateLabelVisitStatus(photoId: image._id)
            }
        }
    }
    
    // The function to load all comments of the post
    func loadComments(postId: String) {
        // Call the function to load comments for post with the specified post id
        commentRepository.loadComments(postId: postId) {(arrayOfComments) in
            // Update the array of comments
            self.comments += arrayOfComments
            
            // Reload the table view
            DispatchQueue.main.async {
                // Reload the table view
                self.postDetailTableView.reloadData()
            }
        }
    }
    
    //******************************************* GET INFO OF CURRENT USER SEQUENCE *******************************************
    // The function to get info of the currently logged in user
    func getInfoOfCurrentUser() {
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Update the current user id property of this view controller
            self.currentUserId = userObject._id
        }
    }
    //******************************************* END GET INFO OF CURRENT USER SEQUENCE *******************************************
    
    //******************************************* CREATE NEW COMMENT SEQUENCE *******************************************
    // The function to add new comment to the database
    func addCommentToDatabase(commentContent: String, postId: String) {
        // Call the function to create new comment created by the currently logged in user
        commentRepository.createComment(postId: postId, commentContent: commentContent) { (commentObject) in
            // Add it to the array of comments
            self.comments.append(commentObject)
            
            // Emit event to the server to let it know that new comment was added
            self.emitSentEvent(commentObject: commentObject, postId: self.cuckooPostObject._id)
            
            // Call the function to send notification to the post writer
            AdditionalFunctions.init().sendNotification(forUser: self.cuckooPostObject.writer, fromUser: self.currentUserId, content: "commented", image: self.images[0].imageURL, postId: postId)
            
            // Reload the table view
            DispatchQueue.main.async {
                // Clear content of the comment text field
                self.commentContentToPost.text = ""
                
                // Reload the table view
                self.postDetailTableView.reloadData()
            }
        }
    }
    //******************************************* END CREATE NEW COMMENT SEQUENCE *******************************************
    
    //******************************************* GET PHOTO LABELS SEQUENCE AND UDPATE USER LABEL VISIT *******************************************
    /*
     In this sequence, we will load photo labels of images based on their id
     After that, we will update user label visit status so that it can update user's search trend
     */
    
    // The function to get photo labels of the photo with specified id and upate photo label visit for user
    func getPhotoLabelsOfPhotoBasedOnIdAndUpdateLabelVisitStatus(photoId: String) {
        // Call the function to update photo label visit status of the currently logged in user
        photoRepository.updatePhotoLabelVisitOfCurrentUser(photoId: photoId)
    }
    //******************************************* END GET PHOTO LABELS SEQUENCE *******************************************
    
    //************************************** PREPARE INFO FOR THE NEXT VIEW CONTROLLER **************************************
    // Pass the selected post id to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check which segue is used
        if (segue.identifier == "hbtGramPostDetailToPostCommentPhoto") {
            // If the segue will take user to the send photo view controller
            // Set the post id to be the one selected by the user
            let vc = segue.destination as? PostCommentAddPhotoViewController
            
            // Set the post id to be the one selected by the user
            vc!.postId = self.cuckooPostObject._id
        } // Otherwise, if destination view controller will be user view view controller
        // prepare post id and let the view controller know that it suppose to load list of likes
        else if (segue.identifier == "hbtGramPostDetailToUserView") {
            // Let vc be the user view view controller
            let vc = segue.destination as? UserViewViewController
            
            // Prepare the post id and let the view controller know that it should load list of likes
            vc!.whatToDo = "getListOfLikes"
            vc!.postId = self.cuckooPostObject._id
        } // If the destination view controller is the view controller where user can see profile
        // info of the post writer, set user object in the destination view controller to be the post writer
        else if (segue.identifier == "postDetailToProfileDetail") {
            // Let the vc be the profile detail view controller
            let vc = segue.destination as? ProfileDetailViewController
            
            // Prepare the user object inside the destination view controller
            vc!.userObject = self.postWriterUserObject
        }
        // For other view controller, don't do anything
        else {
            return
        }
    }
    //************************************** END PREPARE INFO FOR THE NEXT VIEW CONTROLLER **************************************
    
    //************************************** IMPLEMENTS PROTOCOL'S FUNCTION **************************************
    // The function which will perform segue and take user to the view controller where the user can see list of likes of the post
    func callSegueFromCellGotoListOfLikes(myData dataobject: AnyObject) {
        // Perform the segue and take user to the view controller where the user can see list of likes of the post
        self.performSegue(withIdentifier: "hbtGramPostDetailToUserView", sender: self)
    }
    
    // The function which will perform segue and take user to the view controller where the user can see profile detail of the post writer or comment writer
    func callSegueFromCellGotoPostWriterProfileDetail(userObject: User) {
        // Update the selected user object
        self.postWriterUserObject = userObject
        
        // Perform the segue and take user to the view controller where the user can see profile detail of the post writer
        self.performSegue(withIdentifier: "postDetailToProfileDetail", sender: self)
    }
    
    // The function which will update user object at this view controller to be the post writer in order to show profile detail of
    func updateSelectedUserObject(userObject: User) {
        // Update the user object
        self.postWriterUserObject = userObject
    }
    
    // The function which will send notification for the post writer
    func sendNotificationToPostWriter(forUser: String, content: String) {
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Call the function to send notification
            AdditionalFunctions.init().sendNotification(forUser: forUser, fromUser: userObject._id, content: content, image: self.images[0].imageURL, postId: self.cuckooPostObject._id)
        }
    }
    
    // The function which will let the user delete post
    func deleteAPost () {
        // Call the function to hide the menu
        onClickTransparentView()
        
        // Ask the user to make sure that user really want to delete the post
        let deleteAlert = UIAlertController(title: "Delete post", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            // Call the function to delete the post
            self.deletePost()
        }))

        deleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            // Get out of the function
            return
        }))
        
        // Show the alert
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    // The function which will open the comment options menu
    func openCommentOptionsMenu(commentWriterUserId: String, commentIdShowingOptions: String) {
        // Set the comment id of the comment which is showing options
        self.commentIdShowingOptions = commentIdShowingOptions
        
        // Set the variable which keep track of if the menu is showing options for comment by current user or not
        if (currentUserId == commentWriterUserId) {
            self.isShowingCommentOptionsForCommentByCurrentUser = true
        } else {
            self.isShowingCommentOptionsForCommentByCurrentUser = false
        }
        
        let window = UIApplication.shared.keyWindow
        
        // Blur the main menu
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        
        let screenSize = UIScreen.main.bounds.size
        tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.menuHeight)
        window?.addSubview(tableViewCommentOptionsMenu)
        
        transparentView.alpha = 0.5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableViewCommentOptionsMenu.frame = CGRect(x: 0, y: screenSize.height - self.menuHeight, width: screenSize.width, height: self.menuHeight)
        }, completion: nil)
        
        // Reload the menu
        self.tableViewCommentOptionsMenu.reloadData()
    }
    
    // The function to delete a comment
    func deleteComment() {
        // Ask the user to make sure that user really want to delete the comment
        let deleteAlert = UIAlertController(title: "Delete comment", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        
        // If user click yes, delete the comment
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            // Call the function to delete a comment
            self.commentRepository.deleteComment(commentId: self.commentIdShowingOptions) {(isDeleted) in
                if (isDeleted) {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Comment Deleted", message: "Comment has been deleted", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }))

        // If user click no, don't do anything
        deleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            // Get out of the function
            return
        }))
        
        // Show the alert
        self.present(deleteAlert, animated: true, completion: nil)
    }
    //************************************** END IMPLEMENTS PROTOCOL'S FUNCTION **************************************
    
    //************************************** THE FUNCTION WHICH WILL GET INFO OF USER BASED ON ID AND GO TO PROFILE DETAIL **************************************
    // The function to get info of the user based on id
    // And create the object out of the fetched user info
    func getUserInfoBasedOnId(userId: String) {
        // Call the function to load user info based on id
        userRepository.getUserInfoBasedOnId(userId: userId) {(userObject) in
            // Update the user object for the post writer
            self.postWriterUserObject = userObject
        }
    }
    //************************** END THE FUNCTION WHICH WILL GET INFO OF USER BASED ON ID AND GO TO PROFILE DETAIL **************************
    
    //************************** DELETE POST **************************
    // The function to delete a post
    func deletePost() {
        // Call the function to start deleting a post
        postRepository.deletePost(postId: self.cuckooPostObject._id) { (isDeleted) in
            if (isDeleted) {
                DispatchQueue.main.async {
                    // Show the alert
                    let alert = UIAlertController(title: "Post Deleted", message: "Post has been deleted", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                        // Go to the previous view controller
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    //************************** END DELETE POST **************************
}

// For the table view
extension PostDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.postDetailTableView) {
            // Return the sum of header + content + photos + num of likes and comments + comments
            return 3 + images.count + comments.count
        } else if (tableView == self.tableViewCommentOptionsMenu) {
            // Check to see if the menu is showing options for comment by current user or not
            if (isShowingCommentOptionsForCommentByCurrentUser) {
                return arrayOfMenuItemsCommentsOfCurrentUser.count
            } else {
                return arrayOfMenuItemsCommentsOfOtherUser.count
            }
        } else {
            // Need to check if current view controller is viewing post by current user or not
            if (currentUserId == cuckooPostObject.writer) {
                return arrayOfMenuItems.count
            } else {
                return arrayOfMenuItemsOtherUser.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.postDetailTableView) {
            // First row should show the header
            if (indexPath.row == 0) {
                // Let the cell be the post detail header cell
                let cell = postDetailTableView.dequeueReusableCell(withIdentifier: "postDetailHeaderCell", for: indexPath) as! PostDetailHeaderCell
                
                // Load header info into the view
                cell.dateCreated.text = cuckooPostObject.dateCreated
                
                // Delegate the cell
                cell.delegate = self
                
                // Call the function to load name and avatar of the post writer
                cell.loadFullNameAndAvatar(userId: cuckooPostObject.writer)
                
                // Return the cell
                return cell
            }
            
            // Second row will show content of the post
            else if (indexPath.row == 1) {
                // Let the cell be the post detail post content cell
                let cell = postDetailTableView.dequeueReusableCell(withIdentifier: "postDetailPostContentCell", for: indexPath) as! PostDetailPostContentCell
                
                // Load post content into the view
                cell.postContent.text = cuckooPostObject.content
                
                // Return the cell
                return cell
            }
            
            // From this point, will start showing the photos
            else if (indexPath.row >= 2 && indexPath.row <= images.count + 1 && images.count != 0) {
                // Let the cell be the post detail post content cell
                let cell = postDetailTableView.dequeueReusableCell(withIdentifier: "postDetailPostPhotoCell", for: indexPath) as! PostDetailPostPhotoCell
                
                // Call the function to load image at this row into the image view
                cell.loadImage(URLString: images[indexPath.row - 2].imageURL)
                
                // Return the cell
                return cell
            }
            
            // After that, show number of likes and comments
            else if (indexPath.row == images.count + 2) {
                // Let the cell be the post detail comment cell
                let cell = postDetailTableView.dequeueReusableCell(withIdentifier: "postDetailNumberOfLikesAndCommentsCell", for: indexPath) as! PostDetailNumberOfLikesAndCommentsCell
                
                // Delegate the cell
                cell.delegate = self
                
                // Set post object property in the cell to be the selected post object at this view controller
                cell.postObject = cuckooPostObject
                
                // Call the function to get number of likes and comments for the post
                cell.loadNumOfLikes(postId: cuckooPostObject._id)
                cell.loadNumOfComments(postId: cuckooPostObject._id)
                
                // Call the function to get like status of the post
                cell.getLikeStatus(postId: cuckooPostObject._id)
                
                // Return the cell
                return cell
            }
            
            // The rest will show the comment
            else {
                if (comments.count != 0 && images.count != 0) {
                    // Get the comment object at this row
                    let commentObject = comments[indexPath.row - 3 - images.count]

                    // Check content of the comment
                    if (commentObject.content == "image") {
                        // If content of the comment is image, let the comment cell show the image for the comment
                        // Let the cell be the comment cell with photo
                        let cell = postDetailTableView.dequeueReusableCell(withIdentifier: "postDetailCommentWithPhotoCell", for: indexPath) as! PostDetailCommentWithPhotoCell
                        
                        // Set comment writer user id for the cell
                        cell.commentWriterUserId = commentObject.writer
                        
                        // Delegate the cell
                        cell.delegate = self
                        
                        // Call the function to load avatar and full name of the comment writer
                        cell.loadFullNameAndAvatarForCommentWriter(userId: commentObject.writer)
                        
                        // Call the function to load image for the comment
                        cell.getCommentImageBasedOnId(commentId: commentObject._id)
                        
                        // Return the cell
                        return cell
                    } // Otherwise, comment is just plain text
                    else {
                        // Let the cell be the comment cell
                        let cell = postDetailTableView.dequeueReusableCell(withIdentifier: "postDetailCommentCell", for: indexPath) as! PostDetailCommentCell
                        
                        // Call the function to load avatar and full name of the comment writer
                        cell.loadFullNameAndAvatarForCommentWriter(userId: commentObject.writer)
                        
                        // Set comment object for the cell
                        cell.commentObject = commentObject
                        
                        // Delegate the cell
                        cell.delegate = self
                        
                        // Load comment content into the view
                        cell.commentComment.text = commentObject.content
                        
                        // Return the cell
                        return cell
                    }
                } else {
                    // Let the cell be the is loading comment cell
                    let cell = postDetailTableView.dequeueReusableCell(withIdentifier: "postDetailLoadingCommentCell", for: indexPath) as! PostDetaiLoadingCommentCell
                    
                    // Return the cell
                    return cell
                }
            }
        } else if (tableView == self.tableViewCommentOptionsMenu) {
            // Let the cell be the comment option menu cell
            let cell = self.tableViewCommentOptionsMenu.dequeueReusableCell(withIdentifier: "commentOptionMenuCell", for: indexPath) as! CommentOptionMenuCell
            
            // Delegate the cell
            cell.delegate = self
            
            // Set the label inside the cell
            if (isShowingCommentOptionsForCommentByCurrentUser) {
                cell.menuLabel.text = arrayOfMenuItemsCommentsOfCurrentUser[indexPath.row]
            } else {
                cell.menuLabel.text = arrayOfMenuItemsCommentsOfOtherUser[indexPath.row]
            }
            
            // Return the cell
            return cell
        }
        else {
            // Let the cell be the menu cell
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
            
            // Delegate the cell
            cell.delegate = self
            
            // Set the label inside the cell
            // Need to check and see if current view controller is viewing post of current user or not
            if (currentUserId == cuckooPostObject.writer) {
                cell.menuLabel.text = arrayOfMenuItems[indexPath.row]
            } else {
                cell.menuLabel.text = arrayOfMenuItemsOtherUser[indexPath.row]
            }
            
            // Return the cell
            return cell
        }
    }
}

// Protocol which will be used to enable the table view cell to perform segue
protocol PostLikeCellDelegator {
    // The function to perform the segue and take user to the view controller where the user can see list of likes of the post
    func callSegueFromCellGotoListOfLikes(myData dataobject: AnyObject)
    
    // The function to perform the segue and take user to the view controller where the user can profile detail of the post writer
    func callSegueFromCellGotoPostWriterProfileDetail(userObject: User)
    
    // The function which will update user object at this view controller to be the selected user
    func updateSelectedUserObject(userObject: User)
    
    // The function which will send notification to the post writer when user like or comment this post
    func sendNotificationToPostWriter(forUser: String, content: String)
    
    // The function which will let the user delete a post
    func deleteAPost()
    
    // The function which will open menu for comment options
    func openCommentOptionsMenu(commentWriterUserId: String, commentIdShowingOptions: String)
    
    // The function to delete a comment
    func deleteComment()
}
