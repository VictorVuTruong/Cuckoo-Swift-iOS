//
//  CommentRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 2/15/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class CommentAndLikeRepository {
    // User repository
    let userRepository = UserRepository()
    
    // The decoder which will be used to decode the JSON array
    let decoder = JSONDecoder()
    
    // The object to perform API operations
    let apiOperations = APIOperations()
    
    // The function to load comments for the post with specified post id
    func loadComments(postId: String, completion: @escaping ([CuckooPostComment]) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostComment?postId=\(postId)") { (responseData) in
            do {
                // Get the data
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Get array of comments of the post and convert it to JSON data
                let arrayOfComments = try JSONSerialization.data(withJSONObject: dataFetched["documents"] as! [[String: Any]], options: [])
                
                // Convert JSON data into array of post photo objects
                let arrayOfCommentObjects = try self.decoder.decode([CuckooPostComment].self, from: arrayOfComments)
                
                // Return array of comments to view controller via callback function
                completion(arrayOfCommentObjects)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to create new comment for the post with specified post id by a currently logged in user
    func createComment(postId: String, commentContent: String, completion: @escaping (CuckooPostComment) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform POST operation
                self.apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostComment", body: [
                    "content": commentContent,
                    "postId": postId,
                    "writer": userObject._id
                ]) { (responseData) in
                    // Get the whole data from the JSON, it will be in the map format [String: Any]
                    let dataFetched = (responseData["data"] as! [String: Any])["tour"] as! [String: Any]
                    
                    // Get id of the newly created comment
                    let newCommentId = dataFetched["_id"] as! String
                    
                    // Create the new comment object based on info of the new comment
                    let newCommentObject = CuckooPostComment(_id: newCommentId, writer: userObject._id, content: commentContent, postId: "", orderInCollection: 0)
                    
                    // Return new comment object to view controller via callback function
                    completion(newCommentObject)
                }
            }
        }
    }
    
    // The function to create new like by the currently logged in user
    func createNewLike(postId: String, completion: @escaping (Bool) -> ())  {
        // Call the function to get info of the currently logged in user
        self.userRepository.getInfoOfCurrentUser { (userObject) in
            // Call the function to perform POST operation
            self.apiOperations.performPOSTRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostLike/checkLikeStatusAndCreateLike?postId=\(postId)&whoLike=\(userObject._id)") { (responseData) in
                // Get status of the procedure (like created or like removed)
                let status = responseData["status"] as! String
                
                // Return like status via callback function
                // Based on status of the procedure to set the right image for the like button
                if (status == "Done. New like added") {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    // The function to get like status between current user and post with specified user id
    func getLikeStatus(postId: String, completion: @escaping (Bool) -> ()) {
        // Call the function to get info of the currently logged in user
        self.userRepository.getInfoOfCurrentUser { (userObject) in
            // Call the function to perform GET operation
            self.apiOperations.performPOSTRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostLike/checkLikeStatus?postId=\(postId)&whoLike=\(userObject._id)") { (responseData) in
                // Get status of the response (Like status)
                let likeStatus = responseData["status"] as! String
                
                // If like status is "Done. User has liked the post", return true
                if (likeStatus == "Done. User has liked post") {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    // The function to delete a comment
    func deleteComment(commentId: String, completion: @escaping (Bool) -> ()) {
        // Call the function to perform DELETE operation
        apiOperations.performDELETERequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostComment/deleteCommentWithId?commentId=\(commentId)") { (isDeleted) in
            // If comment has been deleted, notify the view
            if (isDeleted) {
                // Let the view controller know that comment has been deleted via callback function
                completion(true)
            }
        }
    }
    
    // The function to get list of user ids of users who like post with the specified post id
    func getListOfLikesOfPost(postId: String, completion: @escaping ([CuckooPostLike]) -> ()) {
        // Call the function to perform GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostLike?postId=\(postId)") { (responseData) in
            do {
                // Get the data
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Get array of like as raw data and convert into JSON data
                let arrayOfLikesJSONData = try JSONSerialization.data(withJSONObject: dataFetched["documents"] as! [[String: Any]], options: [])
                
                // Convert JSON data into array of post like objects
                let arrayOfLikeObjects = try self.decoder.decode([CuckooPostLike].self, from: arrayOfLikesJSONData)
                
                // Return array of likes via callback function
                completion(arrayOfLikeObjects)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to get number of likes of post with specified post id
    func getNumOfLikesOfPost(postId: String, completion: @escaping (Int) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostLike?postId=\(postId)") { (responseData) in
            // Get number of likes
            let numOfLikes = responseData["results"] as! Int
            
            // Return number of likes via callback function
            completion(numOfLikes)
        }
    }
    
    // The function to get number of comments of psot with specified post id
    func getNumOfCommentsOfPost(postId: String, completion: @escaping (Int) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostComment?postId=\(postId)") { (responseData) in
            // Get number of comments
            let numOfComments = responseData["results"] as! Int
            
            // Return number of comments via callback function
            completion(numOfComments)
        }
    }
}
