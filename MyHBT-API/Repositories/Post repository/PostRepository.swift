//
//  PostRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 2/15/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class PostRepository {
    // The user repository
    let userRepository = UserRepository()
    
    // The object to perform API operations
    let apiOperations = APIOperations()
    
    // The decoder which will be used to decode the JSON array
    let decoder = JSONDecoder()
    
    // The function to get order in collection of latest post in the database
    func getOrderInCollectionOfLatestPost(completion: @escaping (Int) -> ()) {
        // Call the function to perform the GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPost/getLatestPostInCollection") { (responseData) in
            // Get the data (order in collection of latest post)
            let orderInCollectionOfLatestPost = responseData["data"] as! Int
            
            // Return order in collection of latest post via callback function
            completion(orderInCollectionOfLatestPost)
        }
    }
    
    // The function to load all posts for the currently logged in user
    func getPostsForCurrentUser(currentLocationInList: Int, completion: @escaping ([CuckooPost], Int) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform POST request
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPost/getCuckooPostForUser?userId=\(userObject._id)&currentLocationInList=\(currentLocationInList)") { (responseData) in
                    do {
                        // Get array of posts and convert it to JSON data so that it can be decoded in to post object
                        let arrayOfPosts = try JSONSerialization.data(withJSONObject: responseData["data"] as! [[String: Any]], options: [])
                                                
                        // Convert the JSON data into array of post objects
                        let arrayOfPostObjects = try self.decoder.decode([CuckooPost].self, from: arrayOfPosts)
                        
                        // Get order in collection of the of the point from which next posts should be loaded
                        let orderInCollectionForNextLoad = responseData["newCurrentLocationInList"] as! NSNumber
                        
                        // Return array of posts and order in collection for next load via callback function
                        completion(arrayOfPostObjects, orderInCollectionForNextLoad.intValue)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // The function to check and see if post is accessible or not
    func checkPost(postId: String, completion: @escaping (Bool) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to perform GET request
            self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPost?_id=\(postId)") { (responseData) in
                // Get the status
                let status = responseData["status"] as! String
                
                // Check to see if post is available or not
                if (status == "success") {
                    // Let the view controller know that post is accessible via callback function
                    completion(true)
                } else {
                    // Let the view controller know that post is not accessible via callback function
                    completion(false)
                }
            }
        }
    }
    
    // The function to delete a post with the specified post id
    func deletePost(postId: String, completion: @escaping (Bool) -> ()) {
        // Call the function to delete a post
        apiOperations.performDELETERequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPost?postId=\(postId)") {(isDeleted) in
            // If post was deleted, return response to the client
            if (isDeleted) {
                // Let the view know that post has been deleted via callback function
                completion(true)
            }
        }
    }
    
    // The function to create new post in the database. Created by the currently logged in user
    func createNewPost(postContent: String, numOfImages: Int, completion: @escaping (String) -> ()) {
        // Call the function to perform POST request
        apiOperations.performPOSTRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPost") { (responseData) in
            // Get the whole data from the JSON, it will be in the map format [String: Any]
            // And then get the user property of the data
            let dataFetched = ((responseData["data"] as! [String: Any])["tour"]) as! [String: Any]
            
            // Get post id of the newly created post
            let newPostId = dataFetched["_id"] as! String
            
            // Return post id of the newly created post via callback function
            completion(newPostId)
        }
    }
    
    // The function to get number of posts created by user with specified user id
    func getNumOfPostsCreatedByUser(userId: String, completion: @escaping (Int) -> ()) {
        // Call the function to perform the GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPost?writer=\(userId)") { (responseData) in
            // Get number of posts created by user with specified user id
            let numOfPosts = responseData["results"] as! Int
            
            // Return number of posts via callback function
            completion(numOfPosts)
        }
    }
    
    // The function to get post object of post with specified post id
    func getPostObjectBasedOnPostId(postId: String, completion: @escaping (CuckooPost) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPost?_id=\(postId)") { (responseData) in
            do {
                // Get the data (includes found post)
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Get array of posts
                // We will take first element of this array
                if ((dataFetched["documents"] as! [[String: Any]]).count != 0) {
                    // Get array of posts
                    // We will take first element of this array
                    let postObjectFromDatabase = (dataFetched["documents"] as! [[String: Any]])[0]
                    
                    // Convert array of posts from the database to JSON data
                    let postObjectFromDatabaseJSON = try JSONSerialization.data(withJSONObject: postObjectFromDatabase, options: [])
                    
                    // Convert JSON data into post object
                    let postObject = try self.decoder.decode(CuckooPost.self, from: postObjectFromDatabaseJSON)
                    
                    // Return post object via callback function
                    completion(postObject)
                } else {
                    // Return the blank post object
                    completion(CuckooPost(content: "", writer: "", _id: "", numOfImages: 0, orderInCollection: 0, dateCreated: ""))
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
