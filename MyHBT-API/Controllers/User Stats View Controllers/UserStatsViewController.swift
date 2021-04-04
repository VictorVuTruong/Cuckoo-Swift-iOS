//
//  UserStatsViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/22/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class UserStatsViewController: UIViewController, UserStatsCellDelegator {
    // Array of user interaction
    var arrayOfUserInteraction: [UserInteraction] = []
    
    // Array of user like interaction
    var arrayOfUserLikeInteraction: [UserLikeInteraction] = []
    
    // Array of user comment interaction
    var arrayOfUserCommentInteraction: [UserCommentInteraction] = []
    
    // Array of user profile visit
    var arrayOfUserProfileVisit: [UserProfileVisit] = []
    
    // The selected user object to show profile detail of (user interact with the current user)
    // This one is specified by the user stats content cell
    var selectedUserObjectToShowProfile = User(fullName: "", _id: "", email: "", avatarURL: "", coverURL: "")
    
    // User id of the currently logged in user
    var currentUserId = ""
    
    // User stats repository
    let userStatsRepository = UserStatsRepository()
    
    // The variable which will keep track of which kind of user stats info to load
    // This ine is specified by the user stats see more cell
    var selectedUserStatsInfoToLoad = ""
    
    // The table view which will display user stats info
    @IBOutlet weak var userStatsView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate method to get data for the table view
        userStatsView.dataSource = self
        
        // Register the userStatsCategoryCell for the table view
        userStatsView.register(UINib(nibName: "UserStatsCategoryCell", bundle: nil), forCellReuseIdentifier: "userStatsCategoryCell")
        
        // Register the userStatsContentCell for the table view
        userStatsView.register(UINib(nibName: "UserStatsContentCell", bundle: nil), forCellReuseIdentifier: "userStatsContentCell")
        
        // Register the userStatsSeeMoreCell for the table view
        userStatsView.register(UINib(nibName: "UserStatsSeeMoreCell", bundle: nil), forCellReuseIdentifier: "userStatsSeeMoreCell")
        
        // Call the function to load user stats info for the user
        loadBriefAccountStats()
    }
    
    //************************ GET USER STATS SEQUENCE ************************
    /*
     In this sequence, we will do 2 things
     1. Get info of the currently logged in user
     2. Get brief account stats info of the user
     */
    
    // The function to load brief account stats
    func loadBriefAccountStats() {
        // Call the function to load brief account stats of the current user
        userStatsRepository.getBriefUserStatsOfCurrentUser { (arrayOfUserInteraction, arrayOfUserLikeInteraction, arrayOfUserCommentInteraction, arrayOfUserProfileVisit) in
            // Update arrays of user stats objects
            self.arrayOfUserInteraction += arrayOfUserInteraction
            self.arrayOfUserLikeInteraction += arrayOfUserLikeInteraction
            self.arrayOfUserCommentInteraction += arrayOfUserCommentInteraction
            self.arrayOfUserProfileVisit += arrayOfUserProfileVisit
            
            // Reload the table view
            DispatchQueue.main.async {
                self.userStatsView.reloadData()
            }
        }
    }
    //************************ END GET USER STATS SEQUENCE ************************
    
    //************************ IMPLEMENT ABSTRACT FUNCTIONS ************************
    // The function which will perform segue and take user to the view controller where the user can see profile detail of the user at the row
    func callSegueFromCellShowProfileDetailOfUser(userObject: User) {
        // Update the selected user object
        self.selectedUserObjectToShowProfile = userObject
        
        // Perform the segue
        performSegue(withIdentifier: "userStatsToProfileDetail", sender: self)
    }
    
    // The function which will perform segue and take user to the view controller where the user can see user stats detail
    func callSegueFromCellShowUserStatsDetail(userStatsCategory: String) {
        // Update the selected user stats category
        self.selectedUserStatsInfoToLoad = userStatsCategory
        
        // Perform the segue
        performSegue(withIdentifier: "userStatsToUserStatsDetail", sender: self)
    }
    //************************ END IMPLEMENT ABSTRACT FUNCTIONS ************************
    
    //*********************************************** PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
    // Pass info to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check which segue is used
        if (segue.identifier == "userStatsToUserStatsDetail") {
            // If the segue will take user to the user stats detail view controller,
            // let the view controller know which kind of user stats info to show
            let vc = segue.destination as? UserStatsDetailViewController
            
            // Let the view controller know which kind of user stats info to load
            vc!.userStatsInfoToLoad = self.selectedUserStatsInfoToLoad
        }
        // Otherwise, destination view controller will be profile detail view controller
        // set userObject to be the currently logged in user because it will show info of the current user
        if (segue.identifier == "userStatsToProfileDetail") {
            // Let vc be the Profile Detail view controller
            let vc = segue.destination as? ProfileDetailViewController
            
            // Set the userObject in the profile detail view controller to be the currently logged in uuser
            vc!.userObject = self.selectedUserObjectToShowProfile
        } // For other view controller, don't do anything
        else {
            return
        }
    }
    //*********************************************** END PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
}

// For the table view
extension UserStatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        We will have these rows
        1. First category (user interact with the most)
        2. List of users interact with the most
        3. See more users interact with the most
        4. Second category (user like the most)
        5. List of users like the most
        6. See more users like the most
        7. Third category (user comment the most)
        8. List of users comment the most
        9. See more users comment the most
        10. Fourth category (user visit profile the most)
        11. List of users visit profile the most
        12. See more users visit profile the most
         */
        return 1 + arrayOfUserInteraction.count + 1 + 1 + arrayOfUserLikeInteraction.count + 1 +
                1 + arrayOfUserCommentInteraction.count + 1 + 1 + arrayOfUserProfileVisit.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // First row will be the first category
        if (indexPath.row == 0) {
            // Create a cell for the user stats category cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsCategoryCell", for: indexPath) as! UserStatsCategoryCell
            
            // Set content for the first category
            cell.userStatsCategoryTitle.text = "User interact with you the most"
            
            // Return the cell
            return cell
        } // From second row, show list of users interact with the most
        else if (indexPath.row >= 1 && indexPath.row <= arrayOfUserInteraction.count) {
            // Create a cell for the user stats content cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsContentCell", for: indexPath) as! UserStatsContentCell
            
            // User interaction object at this row
            let userInteractionObject = arrayOfUserInteraction[indexPath.row - 1]
            
            // Call the function to load info of the user at this row
            cell.loadUserInfoBasedOnId(userId: userInteractionObject.user)
            
            // Load content for the sub-content
            cell.userStatsContentSubContent.text = "\(userInteractionObject.interactionFrequency) interactions"
            
            // Update user id of the row
            cell.userId = userInteractionObject.user
            
            // Delegate the cell
            cell.delegate = self
            
            // Return the cell
            return cell
        } // After that, show the load more row
        else if (indexPath.row == arrayOfUserInteraction.count + 1) {
            // Create a cell for the user stats content cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsSeeMoreCell", for: indexPath) as! UserStatsSeeMoreCell
            
            // Delegate the cell
            cell.delegate = self
            
            // Let the cell know that it should load array of user interaction
            cell.userStatsInfoToLoad = "userInteraction"
            
            // Return the cell
            return cell
        }
        
        // After that, show the second category
        else if (indexPath.row == arrayOfUserInteraction.count + 2) {
            // Create a cell for the user stats category cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsCategoryCell", for: indexPath) as! UserStatsCategoryCell
            
            // Set content for the first category
            cell.userStatsCategoryTitle.text = "User like your posts the most"
            
            // Return the cell
            return cell
        } // After that, show list of users like posts the most
        else if (indexPath.row >= arrayOfUserInteraction.count + 3 && indexPath.row <= arrayOfUserInteraction.count + arrayOfUserLikeInteraction.count + 2) {
            // Create a cell for the user stats content cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsContentCell", for: indexPath) as! UserStatsContentCell
            
            // User like interaction object at this row
            let userLikeInteractionObject = arrayOfUserLikeInteraction[indexPath.row - arrayOfUserInteraction.count - 3]
            
            // Call the function to load info of the user at this row
            cell.loadUserInfoBasedOnId(userId: userLikeInteractionObject.likedBy)
            
            // Load content for the sub-content
            cell.userStatsContentSubContent.text = "\(userLikeInteractionObject.numOfLikes) likes"
            
            // Update user id of the row
            cell.userId = userLikeInteractionObject.likedBy
            
            // Delegate the cell
            cell.delegate = self
            
            // Return the cell
            return cell
        } // After that, show the load more row
        else if (indexPath.row == arrayOfUserInteraction.count + arrayOfUserLikeInteraction.count + 3) {
            // Create a cell for the user stats content cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsSeeMoreCell", for: indexPath) as! UserStatsSeeMoreCell
            
            // Delegate the cell
            cell.delegate = self
            
            // Let the cell know that it should load array of user like interaction
            cell.userStatsInfoToLoad = "userLikeInteraction"
            
            // Return the cell
            return cell
        }
        
        // After that, show the third category
        else if (indexPath.row == arrayOfUserInteraction.count + arrayOfUserLikeInteraction.count + 4) {
            // Create a cell for the user stats category cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsCategoryCell", for: indexPath) as! UserStatsCategoryCell
            
            // Set content for the first category
            cell.userStatsCategoryTitle.text = "User comment your posts the most"
            
            // Return the cell
            return cell
        } // After that, show list of users comment posts the most
        else if (indexPath.row >= arrayOfUserInteraction.count + arrayOfUserLikeInteraction.count + 5 && indexPath.row <= arrayOfUserInteraction.count + arrayOfUserLikeInteraction.count + arrayOfUserCommentInteraction.count + 4) {
            // Create a cell for the user stats content cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsContentCell", for: indexPath) as! UserStatsContentCell
            
            // User comment interaction object at this row
            let userCommentInteractionObject = arrayOfUserCommentInteraction[indexPath.row - arrayOfUserInteraction.count - arrayOfUserLikeInteraction.count - 5]
            
            // Call the function to load info of the user at this row
            cell.loadUserInfoBasedOnId(userId: userCommentInteractionObject.commentedBy)
            
            // Load content for the sub-content
            cell.userStatsContentSubContent.text = "\(userCommentInteractionObject.numOfComments) comments"
            
            // Update user id at this row
            cell.userId = userCommentInteractionObject.commentedBy
            
            // Delegate the cell
            cell.delegate = self
            
            // Return the cell
            return cell
        } // After that, show the load more row
        else if (indexPath.row == arrayOfUserInteraction.count + arrayOfUserLikeInteraction.count + arrayOfUserCommentInteraction.count + 5) {
            // Create a cell for the user stats content cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsSeeMoreCell", for: indexPath) as! UserStatsSeeMoreCell
            
            // Delegate the cell
            cell.delegate = self
            
            // Let the cell know that it should load array of user comment interaction
            cell.userStatsInfoToLoad = "userCommentInteraction"
            
            // Return the cell
            return cell
        }
        
        // After that, show the fourth category
        else if (indexPath.row == arrayOfUserInteraction.count + arrayOfUserLikeInteraction.count + arrayOfUserCommentInteraction.count + 6) {
            // Create a cell for the user stats category cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsCategoryCell", for: indexPath) as! UserStatsCategoryCell
            
            // Set content for the first category
            cell.userStatsCategoryTitle.text = "User visit your profile the most"
            
            // Return the cell
            return cell
        } // After that, show list of users visit profile the most
        else if (indexPath.row >= arrayOfUserInteraction.count + arrayOfUserLikeInteraction.count + arrayOfUserCommentInteraction.count + 7 && indexPath.row <= arrayOfUserInteraction.count + arrayOfUserLikeInteraction.count + arrayOfUserCommentInteraction.count + arrayOfUserProfileVisit.count + 6) {
            // Create a cell for the user stats content cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsContentCell", for: indexPath) as! UserStatsContentCell
            
            // User profile visit object at this row
            let userProfileVisitObject = arrayOfUserProfileVisit[indexPath.row - arrayOfUserInteraction.count - arrayOfUserLikeInteraction.count - arrayOfUserCommentInteraction.count - 7]
            
            // Call the function to load info of the user at this row
            cell.loadUserInfoBasedOnId(userId: userProfileVisitObject.visitedBy)
            
            // Load content for the sub-content
            cell.userStatsContentSubContent.text = "\(userProfileVisitObject.numOfVisits) visits"
            
            // Update user id at this row
            cell.userId = userProfileVisitObject.visitedBy
            
            // Delegate the cell
            cell.delegate = self
            
            // Return the cell
            return cell
        } // After that, show the load more row
        else {
            // Create a cell for the user stats content cell
            let cell = userStatsView.dequeueReusableCell(withIdentifier: "userStatsSeeMoreCell", for: indexPath) as! UserStatsSeeMoreCell
            
            // Delegate the cell
            cell.delegate = self
            
            // Let the cell know that it should load array of user profile visit
            cell.userStatsInfoToLoad = "userProfileVisit"
            
            // Return the cell
            return cell
        }
    }
}

// Protocol which will be used to enable the table view cell to perform segue
protocol UserStatsCellDelegator {
    // The function which will take user to the view controller where the user can see profile detail of the user at the row
    func callSegueFromCellShowProfileDetailOfUser(userObject: User)
    
    // The function which will take user to the view controller where the user can see user stats detail
    func callSegueFromCellShowUserStatsDetail(userStatsCategory: String)
}
