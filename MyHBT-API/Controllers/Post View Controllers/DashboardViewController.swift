//
//  HBTGramViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/4/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, PostDetailCellDelegator, MenuProtocol {
    // Objects for the menu
    var transition: SlideInTransition?
    var topView: UIView?
    
    // The view which will take up the whole screen
    var transparentView = UIView ()
    
    // The variable which will keep track of where to start load next
    var orderInCollectionForNextLoad = 0
    
    // User id of the current user
    var currentUserId = ""
    
    // Laet updated locaion of the current user
    var currentUserLastUpdatedLocation = ""
    
    // The selected user object to show profile detail of (post writer)
    // This one is specified by the hbt gram post cell
    var selectedUserObjectToShowProfile = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // The selected post object
    var selectedPostObject = CuckooPost(content: "", writer: "", _id: "", numOfImages: 0, orderInCollection: 0, dateCreated: "")
    
    // User object of the currently logged in user
    // This one is specified by this view controller
    var currentUserObject = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // User repository
    let userRepository = UserRepository()
    
    // Post repository
    let postRepository = PostRepository()

    // The table view which will display posts
    @IBOutlet weak var hbtGramTableView: UITableView!
    
    var menuViewController: MenuViewController?
    
    // Button to open the menu
    @IBAction func menuButton(_ sender: UIBarButtonItem) {
        menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        menuViewController!.didTapMenuType = {menuType in
            self.transitionToNewContent(menuType)
        }
        
        menuViewController!.modalPresentationStyle = .overCurrentContext
        menuViewController!.transitioningDelegate = self
        
        present(menuViewController!, animated: true)
    }
    
    // The array of hbt gram post objects
    var hbtGramPostObjects: [CuckooPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transition = SlideInTransition(menuProtocol: self)
        
        // Delegate method to get data for the table view
        hbtGramTableView.dataSource = self
        
        // Register the HBTGram post cell for the table view
        hbtGramTableView.register(UINib(nibName: "HBTGramPostCell", bundle: nil), forCellReuseIdentifier: "hbtGramPostCell")
        
        // Register the load more cell for the table view
        hbtGramTableView.register(UINib(nibName: "HBTGramPostLoadMoreCell", bundle: nil), forCellReuseIdentifier: "hbtGramPostLoadMoreCell")
        
        // Call the function to get info of the latest post and load list of posts for the current user
        //getInfoOfLatestPostAndLoadPosts()
        loadPostsForUser()
        
        // Call the function to get info of the currently logged in user and update the current user object property of this view controller
        getInfoOfCurrentUser()
    }
    
    // The function to perform transition to the right menu
    func transitionToNewContent(_ menuType: MenuType) {
        topView?.removeFromSuperview()
        switch menuType {
            case .dashboard:
                // This is already dashboard. Don't do anything here
                break
            
            case .overview:
                break
            
            case .firstcategory:
                break
            
            case .chat:
                // Perform the segue and go to the love from HBT view controller
                performSegue(withIdentifier: "hbtGramToChat", sender: self)
            
            case .create:
                // Perform seuge and take user to the view controller where the user can create new post
                performSegue(withIdentifier: "hbtGramToCreateNewPost", sender: self)

            case .profile:
                // Perform segue and take user to the view controller where the user can see the profile
                performSegue(withIdentifier: "hbtGramToProfilePage", sender: self)
                
            case .signout:
                // Call the function which will sign the user out
                signout()
            
            case .secondcategory:
                break
            
            case .findfriends:
                // Perform segue and take user to the view controller where the user can search for more friends
                performSegue(withIdentifier: "hbtGramToSearchFriend", sender: self)
            
            case .personalprofilepage:
                // Perform segue and take user to the view controller where the user can see profile detail
                performSegue(withIdentifier: "hbtGramToUserProfileDetail", sender: self)
            
            case .userstats:
                // Perform segue and take user to the view controller where the user can see account stats
                performSegue(withIdentifier: "hbtGramToUserStats", sender: self)
            
            case .thirdcategory:
                break
            
            case .locations:
                // Perform segue and take user to the view controller of the location page
                performSegue(withIdentifier: "hbtGramToLocationPage", sender: self)
            
            case .explore:
                // Perform segue and take user to the view controller of the explore page
                performSegue(withIdentifier: "hbtGramToExplore", sender: self)
            
            case .notification:
                // Perform segue and take user to the view controller where user can see notifications
                performSegue(withIdentifier: "hbtGramToNotification", sender: self)
            
            case .blank:
                break
            
            case .close:
                break
        }
    }
    
    //*********************************************** GET USER INFO AND GO TO PROFILE DETAIL PAGE SEQUENCE ***********************************************
    // The function to get info of the currently logged in user and create new message sent by that user id
    func getInfoOfCurrentUser() {
        // Call the function to load info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Update current user object property of this view controller
            self.currentUserObject = userObject
        }
    }
    //*********************************************** END GET USER INFO AND GO TO PROFILE DETAIL PAGE SEQUENCE ***********************************************
    
    //*********************************************** GET POSTS SEQUENCE ***********************************************
    // The function to get all posts for the currently logged in user
    func loadPostsForUser() {
        // Call the function to get order in collection of latest post
        postRepository.getOrderInCollectionOfLatestPost { (latestPostOrderInCollection) in
            // Call the function to start loading posts
            self.postRepository.getPostsForCurrentUser (currentLocationInList: latestPostOrderInCollection) { (arrayOfPosts, orderInCollectionForNextLoad) in
                // Update the order in collection for next load
                self.orderInCollectionForNextLoad = orderInCollectionForNextLoad
                
                // Update array of post objects
                self.hbtGramPostObjects += arrayOfPosts
                
                // Reload the table view
                DispatchQueue.main.async {
                    // Reload the table view
                    self.hbtGramTableView.reloadData()
                }
            }
        }
    }
    
    // The function to load more posts for the currently logged in user
    func loadMorePosts() {
        // Call the function to load more posts from current location in list of the user
        postRepository.getPostsForCurrentUser(currentLocationInList: orderInCollectionForNextLoad) { (arrayOfPosts, orderInCollectionForNextLoad) in
            // Update the order in collection for next load
            self.orderInCollectionForNextLoad = orderInCollectionForNextLoad
            
            // Update array of post objects
            self.hbtGramPostObjects += arrayOfPosts
            
            // Reload the table view
            DispatchQueue.main.async {
                // Reload the table view
                self.hbtGramTableView.reloadData()
            }
        }
    }
    
    // The function to show alert to the user which will let user know that end of post collection has been reached
    func showEndOfCollectionAlert() {
        let alert = UIAlertController(title: "No more to read", message: "You have read all posts", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Gotcha", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //*********************************************** END GET POSTS SEQUENCE ***********************************************
    
    // The function to perform signout operation
    func signout() {
        // Call the function to sign current user out
        userRepository.signOut() {
            // Call the function and perform the segue
            DispatchQueue.main.async {
                // Perform the segue and take user back to the welcome view controller
                self.performSegue(withIdentifier: "mainMenuToWelcome", sender: self)
            }
        }
    }
    
    //*********************************************** FUNCTIONS WHICH CAN BE CALLED FROM THE TABLE VIEW CELL ***********************************************
    // The function which will be used for for the cell of this table view to be able to call segue and go to the post detail view controller
    func callSegueFromCellShowPostDetail(postObject: CuckooPost) {
        // Update selected post object
        self.selectedPostObject = postObject
        
        // Perform the segue
        self.performSegue(withIdentifier: "hbtGramTohbtGramPostDetail", sender:self)
    }
    
    // The function which will take user to the view controller where the user can see profile detail of the post writer
    func callSegueFromCellShowProfileDetailOfPostWriter(userObject: User) {
        // Update the selected user object
        self.selectedUserObjectToShowProfile = userObject
        
        // Perform the segue and take user to the view controller where the user can see profile detail of the post writer
        self.performSegue(withIdentifier: "hbtGramToUserProfileDetailPostWriter", sender: self)
    }
    
    // The function which will load more posts
    func callFunctionToLoadMorePost(myData dataobject: AnyObject) {
        // Call the function to update news feed
        self.loadMorePosts()
    }
    //*********************************************** END FUNCTIONS WHICH CAN BE CALLED FROM THE TABLE VIEW CELL ***********************************************
    
    //*********************************************** PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
    // Pass info to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check which segue is used
        if (segue.identifier == "hbtGramTohbtGramPostDetail") {
            // If the segue will take user to the post detail view controller,
            // set the post object in the post detail view controller to be the one that the user selected
            let vc = segue.destination as? PostDetailViewController
            
            // Set the post object in the post detail view controller to be the one that the user selected
            vc!.cuckooPostObject = self.selectedPostObject
        } // Otherwise, destination view controller will be profile detail view controller
        // set userObject to be the currently logged in user because it will show info of the current user
        else if (segue.identifier == "hbtGramToUserProfileDetail") {
            // Let vc be the Profile Detail view controller
            let vc = segue.destination as? ProfileDetailViewController
            
            // Set the userObject in the profile detail view controller to be the currently logged in uuser
            vc!.userObject = self.currentUserObject
        } // If the destination view controller will be profile detail view controller and use to shoe profile
        // of the post writer, set userObject to be the selected user to show profile detail of
        else if (segue.identifier == "hbtGramToUserProfileDetailPostWriter") {
            // Let vc be the Profile Detail view controller
            let vc = segue.destination as? ProfileDetailViewController
            
            // Set the userObject in the profile detail view controller to be the selected user object (psot writer)
            vc!.userObject = self.selectedUserObjectToShowProfile
        }
        // For other view controller, don't do anything
        else {
            return
        }
    }
    //*********************************************** END PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
    
    // The function to close the menu
    func closeMenu() {
        menuViewController?.dismiss(animated: true, completion: {})
    }
}

// For the table view
extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of elements in the array of posts plus the load more button
        return hbtGramPostObjects.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Every row before the last row will show posts
        if (indexPath.row >= 0 && indexPath.row < hbtGramPostObjects.count) {
            // Create a cell for the hbt gram post
            let cell = hbtGramTableView.dequeueReusableCell(withIdentifier: "hbtGramPostCell", for: indexPath) as! CuckooPostCell
            
            // Get the post object at this row
            let postObject = hbtGramPostObjects[indexPath.row]
            
            // Call the function to load full name and avatar for the post writer
            cell.loadFullNameAndAvatar(userId: postObject.writer)
            
            // Call the function to load first image of the post
            cell.loadFirstPhoto(postId: postObject._id)
            
            // Call the function to load number of likes and comments for the post
            cell.loadNumOfLikes(postId: postObject._id)
            cell.loadNumOfComments(postId: postObject._id)
            
            // Call the function to get like status of the user and the post and set up the like button
            cell.getLikeStatus(postId: postObject._id)
            
            // Load the rest of information into the view
            cell.dateCreated.text = postObject.dateCreated
            cell.postContent.text = postObject.content
            
            // Set the post object inside cell to be the one at this position
            cell.postObject = postObject
            
            // Set the delegate property in the cell to be self so that the cell can call the segue
            cell.delegate = self
            
            // Return the cell
            return cell
        } // Last row will show the load more button
        else {
            // Create a cell for the hbt gram post load more button
            let cell = hbtGramTableView.dequeueReusableCell(withIdentifier: "hbtGramPostLoadMoreCell", for: indexPath) as! CuckooPostLoadMoreCell
            
            // Set the delegate property in the cell to be self so that the cell can call the segue
            cell.delegate = self
            
            // Hide the is loading activity indicator view
            cell.loadMoreActivityIndicatorView.isHidden = true
            
            // Return the cell
            return cell
        }
    }
}

// Extension for the menu
extension DashboardViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition!.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition!.isPresenting = false
        return transition
    }
}

// Protocol which will be used to enable the table view cell to perform segue
protocol PostDetailCellDelegator {
    // The function which will perform segue and take user to the view controller where the user can see post detail of the selected post
    func callSegueFromCellShowPostDetail(postObject: CuckooPost)
    
    // The function which will take user to the view controller where the user can see profile detail of the post writer
    func callSegueFromCellShowProfileDetailOfPostWriter(userObject: User)
    
    // The function which will load more posts for the news feed
    func callFunctionToLoadMorePost(myData dataobject: AnyObject)
}
