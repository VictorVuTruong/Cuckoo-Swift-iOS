//
//  ExploreViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/30/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, ProfileDetailCellDelegator, PostDetailCellDelegator {
    // The table view to show explore album
    @IBOutlet weak var exploreView: UITableView!
    
    // User id of the currently logged in user
    var currentUserId = ""
    
    // Location in list so that the server will know from where to load
    var currentLocationInList = 0
    
    // HBTGram post object of the selected post (used in case user need to go to view controller where the user can see post detail of the selected
    // photo associated with the post)
    var hbtGramPostObject = CuckooPost(content: "", writer: "", _id: "", numOfImages: 0, orderInCollection: 0, dateCreated: "")
    
    // Array of photos to show to the users
    var arrayOfImages: [CuckooPostPhoto] = []
    
    // Photo repository
    let photoRepository = PhotoRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate method to get data for the table view
        exploreView.dataSource = self
        
        // Register the header for the table view
        exploreView.register(UINib(nibName: "RecommentPhotoHeaderCell", bundle: nil), forCellReuseIdentifier: "recommentPhotoHeaderCell")
        
        // Register the photo cell for the table view
        exploreView.register(UINib(nibName: "ProfileDetailPhotoCell", bundle: nil), forCellReuseIdentifier: "profileDetailPhotoCell")
        
        // Register the load more cell for the table view
        exploreView.register(UINib(nibName: "HBTGramPostLoadMoreCell", bundle: nil), forCellReuseIdentifier: "hbtGramPostLoadMoreCell")
        
        // Call the function to get info of the currently logged in user
        //getInfoOfCurrentUserAndLoadFurtherInfo()
        
        // Call the function to load list of recommended photos for the currently logged in user for the first time
        loadRecommendedPhotosForUserFirstLoad()
    }
    
    //********************************* GET PHOTOS FOR USER SEQUENCE *********************************
    /*
     In this sequence, we will do 2 things
     1. Get order in collection of latest post photo label in collection
     2. Get recommended photos for the user (if need to reload, don't need to load latest photo label again)
     */
    
    // The function to load list of recommended photos for the currently logged in user for the first time
    func loadRecommendedPhotosForUserFirstLoad() {
        // Call the function to location in list of latest photo in
        photoRepository.getOrderInCollectionOfLatestPhoto { (orderInCollectionOfLatestPhoto) in
            // Update current location in list
            self.currentLocationInList = orderInCollectionOfLatestPhoto
            
            // Call the function to load recommended photos for the currently logged in user for the first time
            self.photoRepository.getRecommendedPhotosForUser(currentLocationInList: self.currentLocationInList) { (arrayOfImages, locationForNextLoad) in
                // Update list of photos
                self.arrayOfImages += arrayOfImages
                
                // Update the new current location in list
                self.currentLocationInList = locationForNextLoad
                
                // Reload the table view
                DispatchQueue.main.async {
                    self.exploreView.reloadData()
                }
            }
        }
    }
    
    // The function to load more recommended photos
    func loadMoreRecommendedPhotos() {
        // Call the function to load more recommended photos based on current location in list of the user
        photoRepository.getRecommendedPhotosForUser(currentLocationInList: self.currentLocationInList) { (arrayOfImages, locationForNextLoad) in
            // Update list of photos
            self.arrayOfImages += arrayOfImages
            
            // Update the new current location in list
            self.currentLocationInList = locationForNextLoad
            
            // Reload the table view
            DispatchQueue.main.async {
                self.exploreView.reloadData()
            }
        }
    }
    //********************************* END GET PHOTOS FOR USER SEQUENCE *********************************
    
    //*********************************************** PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
    // Pass info to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check which segue is used
        if (segue.identifier == "exploreToPostDetail") {
            // If the segue will take user to the post detail view controller,
            // set the post object in the post detail view controller to be the one that the user selected
            let vc = segue.destination as? PostDetailViewController
            
            // Set the post object in the post detail view controller to be the one that the user selected
            vc!.cuckooPostObject = self.hbtGramPostObject
        }
    }
    //*********************************************** END PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
    
    //*********************************** IMPLEMENT FUNCTIONS FOR THE TABLE VIEW ***********************************
    //----------------------- Functions of the profile detail protocol -----------------------
    func callSegueFromCellGotoEditProfile(myData dataobject: AnyObject) {}
    
    func callSegueFromCellGotoChat() {}
    
    func callSegueFromCellGotoPostDetail(postObject: CuckooPost) {
        // Update the post object
        self.hbtGramPostObject = postObject
        
        // Perform segue and take user to the post detail view controller
        self.performSegue(withIdentifier: "exploreToPostDetail", sender:self)
    }
    
    func callSegueFromCellGotoListOfFollowers (myData dataobject: AnyObject) {}
    
    func callSegueFromCellGotoListOfFollowings (myData dataobject: AnyObject) {}
    
    func updateChatRoomObject(chatRoomObject: MessageRoom) {}
    
    // The function to udpate post object before going to the view controller where user can see post detail of the selected post
    func updateSelectedPostObject (postObject: CuckooPost) {
        // Update the post object
        self.hbtGramPostObject = postObject
    }
    
    //----------------------- Functions of the explore protocol -----------------------
    func callSegueFromCellShowPostDetail(postObject: CuckooPost) {}
    
    func callSegueFromCellShowProfileDetailOfPostWriter(userObject: User) {}
    
    func callFunctionToLoadMorePost(myData dataobject: AnyObject) {
        // Call the function to load more photos
        loadMoreRecommendedPhotos()
    }
    //*********************************** END IMPLEMENT FUNCTIONS FOR THE TABLE VIEW ***********************************
}

// Extension for the table view
extension ExploreViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return number of rows needed to hold all images + row for the header
        if (arrayOfImages.count % 4 != 0) {
            // Return the number of rows
            return (arrayOfImages.count / 4) + 1 + 1 + 1
        } else {
            // Return the number of rows
            return (arrayOfImages.count / 4) + 1 + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get number of rows needed for all images
        var numOfRowsForImages = 0
        if (arrayOfImages.count % 4 != 0) {
            // Return the number of rows
            numOfRowsForImages = (arrayOfImages.count / 4) + 1
        } else {
            // Return the number of rows
            numOfRowsForImages = (arrayOfImages.count / 4)
        }
        
        // First row should be the header
        if (indexPath.row == 0) {
            // Create the cell for the header cell
            let cell = exploreView.dequeueReusableCell(withIdentifier: "recommentPhotoHeaderCell", for: indexPath) as! RecommentPhotoHeaderCell
            
            // Return the cell
            return cell
        }
        
        // After that, show the album
        else if (indexPath.row >= 1 && indexPath.row <= numOfRowsForImages){
            // Create the cell for the photo cell
            let cell = exploreView.dequeueReusableCell(withIdentifier: "profileDetailPhotoCell", for: indexPath) as! ProfileDetailPhotoCell
            
            // Get the remaining number of images
            let remainingNumOfImages = arrayOfImages.count - (indexPath.row - 1) * 4
            
            // Delegate the cell
            cell.delegate = self
            
            // If the remaining number of images is greater than or equal to 4, all columns in the row will be filled
            if (remainingNumOfImages >= 4) {
                // Set up all images in the row
                cell.loadImage1(imageURL: arrayOfImages[((indexPath.row - 1) * 4)].imageURL)
                cell.loadImage2(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 1].imageURL)
                cell.loadImage3(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 2].imageURL)
                cell.loadImage4(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 3].imageURL)
                
                // Set up the post id which go with the picture as well
                cell.image1PostId = arrayOfImages[((indexPath.row - 1) * 4)].postId
                cell.image2PostId = arrayOfImages[((indexPath.row - 1) * 4 + 1)].postId
                cell.image3PostId = arrayOfImages[((indexPath.row - 1) * 4 + 2)].postId
                cell.image4PostId = arrayOfImages[((indexPath.row - 1) * 4 + 3)].postId
            } // If the remaing number of images is 3, just fill in 3 of them
            else if (remainingNumOfImages == 3) {
                // Set up all images in the row
                cell.loadImage1(imageURL: arrayOfImages[((indexPath.row - 1) * 4)].imageURL)
                cell.loadImage2(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 1].imageURL)
                cell.loadImage3(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 2].imageURL)
                
                // Set up the post id which go with the picture as well
                cell.image1PostId = arrayOfImages[((indexPath.row - 1) * 4)].postId
                cell.image2PostId = arrayOfImages[((indexPath.row - 1) * 4 + 1)].postId
                cell.image3PostId = arrayOfImages[((indexPath.row - 1) * 4 + 2)].postId
            } // If the remaining number of image is 2, just fill in 2 of them
            else if (remainingNumOfImages == 2) {
                // Set up all images in the row
                cell.loadImage1(imageURL: arrayOfImages[((indexPath.row - 1) * 4)].imageURL)
                cell.loadImage2(imageURL: arrayOfImages[((indexPath.row - 1) * 4) + 1].imageURL)
                
                // Set up the post id which go with the picture as well
                cell.image1PostId = arrayOfImages[((indexPath.row - 1) * 4)].postId
                cell.image2PostId = arrayOfImages[((indexPath.row - 1) * 4 + 1)].postId
            } // If the remaining number of images is 1, just fill in 1 of them
            else if (remainingNumOfImages == 1) {
                // Set up all images in the row
                cell.loadImage1(imageURL: arrayOfImages[((indexPath.row - 1) * 4)].imageURL)
                
                // Set up the post id which go with the picture as well
                cell.image1PostId = arrayOfImages[((indexPath.row - 1) * 4)].postId
            }
            
            // Return the cell
            return cell
        }
        
        // For the last row, show the load more
        else {
            // Create a cell for the hbt gram post load more button
            let cell = exploreView.dequeueReusableCell(withIdentifier: "hbtGramPostLoadMoreCell", for: indexPath) as! CuckooPostLoadMoreCell
            
            // Set the delegate property in the cell to be self so that the cell can call the segue
            cell.delegate = self
            
            // Hide the is loading activity indicator view
            cell.loadMoreActivityIndicatorView.isHidden = true
            
            // Return the cell
            return cell
        }
    }
}
