//
//  NotificationViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 1/1/21.
//  Copyright © 2021 beta. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, NotificationCellDelegator, PostDetailCellDelegator {
    // User id of the current user
    var currentUserId = ""
    
    // Current location in list of user
    var currentLocationInList = 0
    
    // Array of notifications for the user
    var arrayOfNotifications: [Notification] = []
    
    // User object of user that is associated with one of the notifications to show profile detail of
    var selectedUserObject: User = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // Post object of post that is associated with one of the notifications to show detail of
    var selectedPostObject: CuckooPost = CuckooPost(content: "", writer: "", _id: "", numOfImages: 0, orderInCollection: 0, dateCreated: "")
    
    // Notification repository
    let notificationRepository = NotificationRepository()
    
    // The view which will display the notification
    @IBOutlet weak var notificationView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate method to get data for the table view
        notificationView.dataSource = self
        
        // Register the notification cell for the table view
        notificationView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
        
        // Register the load more cell for the table view
        notificationView.register(UINib(nibName: "HBTGramPostLoadMoreCell", bundle: nil), forCellReuseIdentifier: "hbtGramPostLoadMoreCell")
        
        // Call the function to start loading notifications for the first time
        loadListOfNotificationsFirstLoad()
    }
    
    //*********************************************** GET NOTIFICATIONS SEQUENCE ***********************************************
    /*
     In this sequence we will have 2 things
     1. Get order in collection of latest notification (when list is loaded for the first time)
     2. Get notifications for the user based on current location in list
     */
    
    // The function to load list of notifications for the first time
    func loadListOfNotificationsFirstLoad() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get order in collection of latest notification in the database
            self.notificationRepository.getOrderInCollectionOfLatestNotification { (orderInCollectionOfLatestNotification) in
                // Call the function to start loading posts
                self.notificationRepository.loadNotificationsForCurrentUser(currentLocationInList: orderInCollectionOfLatestNotification) { (arrayOfNotifications, newCurrentLocationInList) in
                    // Update array of notifications
                    self.arrayOfNotifications += arrayOfNotifications
                    
                    // Update new current location in list
                    self.currentLocationInList = newCurrentLocationInList
                    
                    DispatchQueue.main.async {
                        // Update the table view
                        self.notificationView.reloadData()
                    }
                }
            }
        }
    }
    
    // The function to load more notifications
    func loadMoreNotifications() {
        // Call the function to load more notifications based on current location in list of the user
        notificationRepository.loadNotificationsForCurrentUser(currentLocationInList: currentLocationInList) { (arrayOfNotifications, newCurrentLocationInList) in
            // Call the function to start loading posts
            self.notificationRepository.loadNotificationsForCurrentUser(currentLocationInList: newCurrentLocationInList) { (arrayOfNotifications, newCurrentLocationInList) in
                // Update array of notifications
                self.arrayOfNotifications += arrayOfNotifications
                
                // Update new current location in list
                self.currentLocationInList = newCurrentLocationInList
                
                DispatchQueue.main.async {
                    // Reload the table view
                    self.notificationView.reloadData()
                }
            }
        }
    }
    //*********************************************** GET NOTIFICATIONS SEQUENCE ***********************************************
    
    //*********************************************** IMPLEMENT FUNCTIONS FOR PROTOCOL ***********************************************
    // The function which will take user to the view controller where user can see profile detail of user associated with notification
    func gotoProfileDetailOfUserOfNotification(userObject: User) {
        // Update the selected user object
        self.selectedUserObject = userObject
        
        // Perform the segue and take user to the view controller where user can see profile detail of the selected user
        performSegue(withIdentifier: "notificationToProfileDetail", sender: self)
    }
    
    // The function which will take user to the view controller where user can see post detail of post associated with notification
    func gotoPostDetailOfPostOfNotification(postObject: CuckooPost) {
        // Update thhe selected post object
        self.selectedPostObject = postObject
        
        // Perform the segue and take user to the view controller where user can see post detail of the selected post
        performSegue(withIdentifier: "notificationToPostDetail", sender: self)
    }
    
    // Functions of the protocol that contains the load more row
    func callSegueFromCell(myData dataobject: AnyObject) {}
    
    func callSegueFromCellShowProfileDetailOfPostWriter(myData dataobject: AnyObject) {}
    
    func callSegueFromCellShowPostDetail(postObject: CuckooPost) {}
    
    func callSegueFromCellShowProfileDetailOfPostWriter(userObject: User) {}
    
    // Actually, this one is to load more notifications
    func callFunctionToLoadMorePost(myData dataobject: AnyObject) {
        // Call the function to load more notifications
        loadMoreNotifications()
    }
    //*********************************************** END IMPLEMENT FUNCTIONS FOR PROTOCOL ***********************************************
    
    //*********************************************** PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
    // Pass info to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check which segue is used
        if (segue.identifier == "notificationToProfileDetail") {
            // If the segue will take user to the profile detail view controller,
            // update user object at that view controller
            let vc = segue.destination as? ProfileDetailViewController
            
            // Update the user object
            vc!.userObject = self.selectedUserObject
        } else if (segue.identifier == "notificationToPostDetail") {
            // If the segue will take user to the post detail view controller,
            // update post object at that view controller
            let vc = segue.destination as? PostDetailViewController
            
            // Update the post object
            vc!.cuckooPostObject = self.selectedPostObject
        }
    }
    //*********************************************** END PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
}

// For the table view
extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of notifications in the array also add 1 for the load more cell
        return arrayOfNotifications.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Every cells before the last is to show the notifications
        if (indexPath.row >= 0 && indexPath.row < arrayOfNotifications.count) {
            // Create cell for the notification cell
            let cell = notificationView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
            
            // Notification object at this row
            let notificationObject = self.arrayOfNotifications[indexPath.row]
            
            // Delegate the cell
            cell.delegate = self
            
            // Update post id in the cell for this row
            cell.postId = notificationObject.postId
            
            // Update user id in the cell for this row
            cell.userId = notificationObject.fromUser
            
            // Call the function to load user info of the user associated with the notification and content of it
            cell.loadInfoOfUserOfNotificationAndContent(userId: notificationObject.fromUser, content: notificationObject.content)
            
            // Call the function to load
            cell.loadImageForNotification(imageURL: notificationObject.image)
            
            // Return the cell
            return cell
        } // Last row will be the load more button
        else {
            // Create a cell for the hbt gram post load more button
            let cell = notificationView.dequeueReusableCell(withIdentifier: "hbtGramPostLoadMoreCell", for: indexPath) as! CuckooPostLoadMoreCell
            
            // Set the delegate property in the cell to be self so that the cell can call the segue
            cell.delegate = self
            
            // Hide the is loading activity indicator view
            cell.loadMoreActivityIndicatorView.isHidden = true
            
            // Return the cell
            return cell
        }
    }
}

// Protocol for the table view
protocol NotificationCellDelegator {
    // The function to go to the view controller where user can see profile detail of the user associated with the notification
    func gotoProfileDetailOfUserOfNotification(userObject: User)
    
    // The function to go to the view controller where user can see post detail of the post associated with the notification
    func gotoPostDetailOfPostOfNotification(postObject: CuckooPost)
}
