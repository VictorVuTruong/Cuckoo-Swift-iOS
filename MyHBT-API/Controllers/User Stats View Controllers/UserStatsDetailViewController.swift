//
//  UserStatsDetailViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/23/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class UserStatsDetailViewController: UIViewController, UserStatsDetailCellDelegator {
    // The selected user object to show profile detail of (user interact with the current user)
    // This one is specified by the user stats content cell
    static var selectedUserObjectToShowProfile = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // The variable to keep track of which kind of user stats info to load
    var userStatsInfoToLoad = "userProfileVisit"
    
    // User id of the currently logged in user
    var currentUserId = ""
    
    // Array of user interaction
    var arrayOfUserInteraction: [UserInteraction] = []
    
    // Array of user like interaction
    var arrayOfUserLikeInteraction: [UserLikeInteraction] = []
    
    // Array of user comment interaction
    var arrayOfUserCommentInteraction: [UserCommentInteraction] = []
    
    // Array of user profile visit
    var arrayOfUserProfileVisit: [UserProfileVisit] = []
    
    // User stats repository
    let userStatsRepository = UserStatsRepository()
    
    // The table view which will show user stats detail
    @IBOutlet weak var userStatsDetailView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate method to get data for the table view
        userStatsDetailView.dataSource = self
        
        // Register the userStatsCategoryCell for the table view
        userStatsDetailView.register(UINib(nibName: "UserStatsCategoryCell", bundle: nil), forCellReuseIdentifier: "userStatsCategoryCell")
        
        // Register the userStatsContentCell for the table view
        userStatsDetailView.register(UINib(nibName: "UserStatsContentCell", bundle: nil), forCellReuseIdentifier: "userStatsContentCell")
        
        // Based on the userStatsInfoToLoad variable to load the right user stats info
        // If it is userInteraction, load array of user interaction for the user
        if (self.userStatsInfoToLoad == "userInteraction") {
            // Call the function to load user interaction
            self.loadListOfUserInteraction()
        } // If it is userLikeInteraction, load array of user like interaction for the user
        else if (self.userStatsInfoToLoad == "userLikeInteraction") {
            // Call the function to load user like interaction
            self.loadListOfUserLikeInteraction()
        } // If it is userCommentInteraction, load array of user comment interaction for the user
        else if (self.userStatsInfoToLoad == "userCommentInteraction") {
            // Call the function to load user comment interaction
            self.loadListOfUserCommentInteraction()
        } // If it is userProfileVisit, load array of user profile visit for the user
        else if (self.userStatsInfoToLoad == "userProfileVisit") {
            // Call the function to load user profile visit
            self.loadListOfUserProfileVisit()
        }
    }
    
    //************************************ USER STATS INFO LOAD ************************************
    // The function to load list of users who interact with the current user the most (list of user interaction)
    func loadListOfUserInteraction() {
        // Call the function to get list of user interaction
        userStatsRepository.getListOfUserInteraction { (arrayOfUserInteraction) in
            // Update the array of user interaction
            self.arrayOfUserInteraction += arrayOfUserInteraction
            
            // Reload the table view
            DispatchQueue.main.async {
                self.userStatsDetailView.reloadData()
            }
        }
    }
    
    // The function to load list of users that like post of current user the most (list of user like interaction)
    func loadListOfUserLikeInteraction() {
        // Call the function to get list of user like interaction
        userStatsRepository.getListOfUserLikeInteraction { (arrayOfUserLikeInteraction) in
            // Update the array of user like interaction
            self.arrayOfUserLikeInteraction += arrayOfUserLikeInteraction
            
            // Reload the table view
            DispatchQueue.main.async {
                self.userStatsDetailView.reloadData()
            }
        }
    }
    
    // The function to load list of users that comment post of current user the most (list of user comment interaction)
    func loadListOfUserCommentInteraction() {
        // Call the function to get list of user comment interaction
        userStatsRepository.getListOfUserCommentInteration { (arrayOfUserCommentInteraction) in
            // Update the array of user comment interaction
            self.arrayOfUserCommentInteraction += arrayOfUserCommentInteraction
            
            // Reload the table view
            DispatchQueue.main.async {
                self.userStatsDetailView.reloadData()
            }
        }
    }
    
    // The function to load list of users that visit profile of current user the most (list of user profile visit)
    func loadListOfUserProfileVisit() {
        // Call the function to get list of user profile visit
        userStatsRepository.getListOfUserProfileVisit { (arrayOfUserProfileVisit) in
            // Update the array of user profile visit
            self.arrayOfUserProfileVisit += arrayOfUserProfileVisit
            
            // Reload the table view
            DispatchQueue.main.async {
                self.userStatsDetailView.reloadData()
            }
        }
    }
    //************************************ END USER STATS INFO LOAD ************************************
    
    //************************ IMPLEMENT ABSTRACT FUNCTIONS ************************
    // The function which will perform segue and take user to the view controller where the user can see profile detail of the user at the row
    func callSegueFromCellShowProfileDetailOfUser(userObject: User) {
        // Update selected user object to be the selected user
        UserStatsDetailViewController.selectedUserObjectToShowProfile = userObject
        
        // Perform the segue
        performSegue(withIdentifier: "userStatsDetailToProfileDetail", sender: self)
    }
    //************************ END IMPLEMENT ABSTRACT FUNCTIONS ************************
    
    //*********************************************** PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
    // Pass info to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Otherwise, destination view controller will be profile detail view controller
        // set userObject to be the currently logged in user because it will show info of the current user
        if (segue.identifier == "userStatsDetailToProfileDetail") {
            // Let vc be the Profile Detail view controller
            let vc = segue.destination as? ProfileDetailViewController
            
            // Set the userObject in the profile detail view controller to be the currently logged in uuser
            vc!.userObject = UserStatsDetailViewController.selectedUserObjectToShowProfile
        } // For other view controller, don't do anything
        else {
            return
        }
    }
    //*********************************************** END PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
}

// For the table view
extension UserStatsDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        Based on which detail stats info is shown to return right number of rows
        Should also + 1 (for the header)
         */
        if (userStatsInfoToLoad == "userInteraction") {
            return arrayOfUserInteraction.count + 1
        } else if (userStatsInfoToLoad == "userLikeInteraction") {
            return arrayOfUserLikeInteraction.count + 1
        } else if (userStatsInfoToLoad == "userCommentInteraction") {
            return arrayOfUserCommentInteraction.count + 1
        } else {
            return arrayOfUserProfileVisit.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        Based on which detail stats info is shown to return right set of rows
         */
        if (userStatsInfoToLoad == "userInteraction") {
            // First row will be the category
            if (indexPath.row == 0) {
                // Create a cell for the user stats category cell
                let cell = userStatsDetailView.dequeueReusableCell(withIdentifier: "userStatsCategoryCell", for: indexPath) as! UserStatsCategoryCell
                
                // Set content for the first category
                cell.userStatsCategoryTitle.text = "Who interact with you"
                
                // Return the cell
                return cell
            } // From second row, show list of users
            else {
                // Create a cell for the user stats content cell
                let cell = userStatsDetailView.dequeueReusableCell(withIdentifier: "userStatsContentCell", for: indexPath) as! UserStatsContentCell
                
                // User interaction object at this row
                let userInteractionObject = arrayOfUserInteraction[indexPath.row - 1]
                
                // Call the function to load info of the user at this row
                cell.loadUserInfoBasedOnId(userId: userInteractionObject.user)
                
                // Load content for the sub-content
                cell.userStatsContentSubContent.text = "\(userInteractionObject.interactionFrequency) interactions"
                
                // Update user id of the row
                cell.userId = userInteractionObject.user
                
                // Delegate the cell
                cell.delegateUserStatsDetail = self
                
                // Return the cell
                return cell
            }
        } else if (userStatsInfoToLoad == "userLikeInteraction") {
            // First row will be the category
            if (indexPath.row == 0) {
                // Create a cell for the user stats category cell
                let cell = userStatsDetailView.dequeueReusableCell(withIdentifier: "userStatsCategoryCell", for: indexPath) as! UserStatsCategoryCell
                
                // Set content for the first category
                cell.userStatsCategoryTitle.text = "Who like your posts"
                
                // Return the cell
                return cell
            } // From second row, show list of users
            else {
                // Create a cell for the user stats content cell
                let cell = userStatsDetailView.dequeueReusableCell(withIdentifier: "userStatsContentCell", for: indexPath) as! UserStatsContentCell
                
                // User like interaction object at this row
                let userLikeInteractionObject = arrayOfUserLikeInteraction[indexPath.row - 1]
                
                // Call the function to load info of the user at this row
                cell.loadUserInfoBasedOnId(userId: userLikeInteractionObject.likedBy)
                
                // Load content for the sub-content
                cell.userStatsContentSubContent.text = "\(userLikeInteractionObject.numOfLikes) likes"
                
                // Update user id of the row
                cell.userId = userLikeInteractionObject.likedBy
                
                // Delegate the cell
                cell.delegateUserStatsDetail = self
                
                // Return the cell
                return cell
            }
        } else if (userStatsInfoToLoad == "userCommentInteraction") {
            // First row will be the category
            if (indexPath.row == 0) {
                // Create a cell for the user stats category cell
                let cell = userStatsDetailView.dequeueReusableCell(withIdentifier: "userStatsCategoryCell", for: indexPath) as! UserStatsCategoryCell
                
                // Set content for the first category
                cell.userStatsCategoryTitle.text = "Who comment your posts"
                
                // Return the cell
                return cell
            } // From second row, show list of users
            else {
                // Create a cell for the user stats content cell
                let cell = userStatsDetailView.dequeueReusableCell(withIdentifier: "userStatsContentCell", for: indexPath) as! UserStatsContentCell
                
                // User comment interaction object at this row
                let userCommentInteractionObject = arrayOfUserCommentInteraction[indexPath.row - 1]
                
                // Call the function to load info of the user at this row
                cell.loadUserInfoBasedOnId(userId: userCommentInteractionObject.commentedBy)
                
                // Load content for the sub-content
                cell.userStatsContentSubContent.text = "\(userCommentInteractionObject.numOfComments) comments"
                
                // Update user id of the row
                cell.userId = userCommentInteractionObject.commentedBy
                
                // Delegate the cell
                cell.delegateUserStatsDetail = self
                
                // Return the cell
                return cell
            }
        } else {
            // First row will be the category
            if (indexPath.row == 0) {
                // Create a cell for the user stats category cell
                let cell = userStatsDetailView.dequeueReusableCell(withIdentifier: "userStatsCategoryCell", for: indexPath) as! UserStatsCategoryCell
                
                // Set content for the first category
                cell.userStatsCategoryTitle.text = "Who visit your profile"
                
                // Return the cell
                return cell
            } // From second row, show list of users
            else {
                // Create a cell for the user stats content cell
                let cell = userStatsDetailView.dequeueReusableCell(withIdentifier: "userStatsContentCell", for: indexPath) as! UserStatsContentCell
                
                // User profile visit object at this row
                let userProfileVisitObject = arrayOfUserProfileVisit[indexPath.row - 1]
                
                // Call the function to load info of the user at this row
                cell.loadUserInfoBasedOnId(userId: userProfileVisitObject.visitedBy)
                
                // Load content for the sub-content
                cell.userStatsContentSubContent.text = "\(userProfileVisitObject.numOfVisits) visits"
                
                // Update user id of the row
                cell.userId = userProfileVisitObject.visitedBy
                
                // Delegate the cell
                cell.delegateUserStatsDetail = self
                
                // Return the cell
                return cell
            }
        }
    }
}

// Protocol which will be used to enable the table view cell to perform segue
protocol UserStatsDetailCellDelegator {
    // The function which will take user to the view controller where the user can see profile detail of the user at the row
    func callSegueFromCellShowProfileDetailOfUser(userObject: User)
}
