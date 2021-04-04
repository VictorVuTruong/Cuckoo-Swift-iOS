//
//  PhotoRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 2/15/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class PhotoRepository {
    // The decoder which will be used to decode the JSON array
    let decoder = JSONDecoder()
    
    // User repository
    let userRepository = UserRepository()
    
    // API operations performer
    let apiOperations = APIOperations()
    
    // The function to load photos of the specified post id
    func loadPhotosOfPost(postId: String, completion: @escaping ([CuckooPostPhoto]) -> ()) {
        // Call the function to perform the GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhoto?postId=\(postId)") { (responseData) in
            do {
                // Get the data
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Convert dataFetched into JSON data so that it can be decoded into array of image objects
                let arrayOfPhotos = try JSONSerialization.data(withJSONObject: dataFetched["documents"] as! [[String: Any]], options: [])
                
                // Convert JSON data into array of post photo objects
                let arrayOfPhotoObjects = try self.decoder.decode([CuckooPostPhoto].self, from: arrayOfPhotos)
                
                // Return array of photo objects to view controller via callback function
                completion(arrayOfPhotoObjects)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    //******************************************* GET PHOTO LABELS SEQUENCE AND UDPATE USER LABEL VISIT *******************************************
    // The function to load photo labels of the photo with specified photo id
    func loadPhotoLabelsOfPhoto(photoId: String, completion: @escaping ([CuckooPostPhotoLabel]) -> ()) {
        // Call the function to perform the GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhotoLabel?imageID=\(photoId)") { (responseData) in
            do {
                // Get the data
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Convert dataFetched into JSON data so that it can be decoded into array of photo labels
                let arrayOfPhotoLabels = try JSONSerialization.data(withJSONObject: dataFetched["documents"] as! [[String: Any]], options: [])
                
                // Convert JSON data into array of photo label objects
                let arrayOfPhotoLabelObjects = try self.decoder.decode([CuckooPostPhotoLabel].self, from: arrayOfPhotoLabels)
                
                // Return array photo labels to the view controller via callback function
                completion(arrayOfPhotoLabelObjects)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to actually perform the API call to update photo label visit status of the user
    func updateUserPostPhotoLabelVisit(photoLabel: String) {
        // Call the function to get info of the currently logged in user
        self.userRepository.getInfoOfCurrentUser { (userObject) in
            // Call the function to perform the GET request
            self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhoto/createOrUpdatePhotoLabelVisit?userId=\(userObject._id)&photoLabel=\(photoLabel)") { (_) in }
        }
    }
    
    // The function to photo label visit status of the currently logged in user
    func updatePhotoLabelVisitOfCurrentUser(photoId: String) {
        // Call the function to load photo labels of the photo with specified id
        loadPhotoLabelsOfPhoto(photoId: photoId) { (arrayOfPhotoLabels) in
            // Loop through the array of photo labels and update their visit status
            for photoLabel in arrayOfPhotoLabels {
                // Call the function to update photo label visit
                self.updateUserPostPhotoLabelVisit(photoLabel: photoLabel.imageLabel)
            }
        }
    }
    //******************************************* GET PHOTO LABELS SEQUENCE AND UDPATE USER LABEL VISIT *******************************************
    
    // The function to add new post photo object to the database
    func addNewPostPhotoToDatabase(imageURL: String, postId: String, completion: @escaping (String) -> ()) {
        // Call the function to perform the POST request
        apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhoto", body: [
            "postId" : postId,
            "imageURL" : imageURL
        ]) { (responseData) in
            // Get the whole data from the JSON, it will be in the map format [String: Any]
            // And then get the user property of the data
            let dataFetched = ((responseData["data"] as! [String: Any])["tour"]) as! [String: Any]
            
            // Get id of the newly created post photo object
            let postPhotoId = dataFetched["_id"] as! String
            
            // Return post photo id of the newly created post photo object via callback function
            completion(postPhotoId)
        }
    }
    
    //******************************************* LABEL IMAGE SEQUENCE *******************************************
    // The function to label the image
    func labelImage(imageId: String, image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Create image object for the labeler
            let image = VisionImage(image: image)
            
            // The labeler
            let labeler = Vision.vision().cloudImageLabeler()
            
            // Start with labeling
            labeler.process(image) { labels, error in
                guard error == nil, let labels = labels else { return }

                // Loop through all labels of the image and add them to the database
                for label in labels {
                    // Get label of the image
                    let imageLabel = label.text
                    
                    // Call the function to upload image label to the database
                    self.uploadImageLabelToDatabase(imageId: imageId, imageLabel: imageLabel)
                }
            }
        }
    }
    
    // The function to upload image label to the database
    func uploadImageLabelToDatabase(imageId: String, imageLabel: String) {
        // Call the function to perform the POST request
        apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhotoLabel", body: [
            "imageID" : imageId,
            "imageLabel" : AdditionalFunctions.init().replaceStringOccurence(originalString: imageLabel, characterToReplace: " ", replaceCharacterWith: "-")
        ]) { (_) in }
    }
    //******************************************* END LABEL IMAGE SEQUENCE *******************************************
    
    // The function to get images created by user with specified user id
    func getImagesCreatedByUser(userId: String, completion: @escaping ([CuckooPostPhoto]) -> ()) {
        // Call the function to perform GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhoto/getPhotosOfUser?userId=\(userId)") { (responseData) in
            do {
                // Get the data (Array of image objects)
                let dataFetched = responseData["data"] as! [[String: Any]]
                
                // Convert dataFetched into JSON data so that it can be decoded into array of image objects
                let arrayOfPhotos = try JSONSerialization.data(withJSONObject: dataFetched, options: [])
                
                // Convert JSON data into array of post photo objects
                let arrayOfPhotoObjects = try self.decoder.decode([CuckooPostPhoto].self, from: arrayOfPhotos)
                
                // Return array of post photo via callback function
                completion(arrayOfPhotoObjects)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to add new comment photo to the database
    func addCommentPhoto(imageURL: String, commentId: String, completion: @escaping (Bool) -> ()) {
        // Call the function to perform POST request
        apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostCommentPhoto", body: [
            "commentId" : commentId,
            "imageURL" : imageURL
        ]) { (_) in
            // Let the view know that image URL has been uploaded
            completion(true)
        }
    }
    
    // The function to get order in collection of latest photo in collection
    func getOrderInCollectionOfLatestPhoto(completion: @escaping (Int) -> ()) {
        // Call the function to perform GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhoto/getLatestPhotoLabelOrderInCollection") { (responseData) in
            // Get the data (order in collection of latest post photo label)
            let orderInCollection = responseData["data"] as! Int
            
            // Return order in collection via callback function
            completion(orderInCollection)
        }
    }
    
    // The function to get recommended photos for currently logged in user
    func getRecommendedPhotosForUser(currentLocationInList: Int, completion: @escaping ([CuckooPostPhoto], Int) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET operation
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhoto/getRecommendedPhotosForUser?userId=\(userObject._id)&currentLocationInList=\(currentLocationInList)") { (responseData) in
                    do {
                        // Get the data (order in collection of latest post photo label)
                        let dataFetched = responseData["data"] as! [[String: Any]]
                        
                        // Get the new order in collection (location in list for next load)
                        let newCurrentLocationInList = responseData["newCurrentLocationInList"] as! Int
                        
                        // Convert data from the database to JSON data
                        let dataFromDatabaseJSON = try JSONSerialization.data(withJSONObject: dataFetched, options: [])
                        
                        // Convert JSON data into array of photos
                        let arrayOfImages = try self.decoder.decode([CuckooPostPhoto].self, from: dataFromDatabaseJSON)
                        
                        // Return array of images and location in list for next load via callback function
                        completion(arrayOfImages, newCurrentLocationInList)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // The function to get first photo of post with the specified post id
    func getFirstPhotoOfPost(postId: String, completion: @escaping (String) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostPhoto?postId=\(postId)") { (responseData) in
            do {
                // Get the data
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Convert dataFetched into JSON data so that it can be decoded into array of image objects
                let arrayOfPhotos = try JSONSerialization.data(withJSONObject: dataFetched["documents"] as! [[String: Any]], options: [])
                
                // Convert JSON data into array of post photo objects
                let arrayOfPhotoObjects = try self.decoder.decode([CuckooPostPhoto].self, from: arrayOfPhotos)
                
                if (arrayOfPhotoObjects.count != 0) {
                    // Get info of the first image
                    let firstImageInfo = arrayOfPhotoObjects[0]
                
                    // Get image URL of the first image
                    let firstImageURL = firstImageInfo.imageURL
                    
                    // Return image URL via callback function
                    completion(firstImageURL)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
