//
//  FollowRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 2/28/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class FollowRepository {
    // User repository
    let userRepository = UserRepository()
    
    // The object to perform API operations
    let apiOperations = APIOperations()
    
    // The function to get number of followers of user with specified user id
    func getNumOfFollowers(userId: String, completion: @escaping (Int) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooFollow?following=\(userId)") { (responseData) in
            // Get number of followers
            let numOfFollowers = responseData["results"] as! Int
            
            // Return number of followers via callback function
            completion(numOfFollowers)
        }
    }
    
    // The function to get number of followings of user with specified user id
    func getNumOfFollowings(userId: String, completion: @escaping (Int) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooFollow?follower=\(userId)") { (responseData) in
            // Get number of followings
            let numOfFollowings = responseData["results"] as! Int
            
            // Return number of followings via callback function
            completion(numOfFollowings)
        }
    }
    
    // The function to create a follow between current user and user with the specified user id
    func createAFollowBetween2Users(userId: String, completion: @escaping (Bool) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform POST operation
                self.apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/cuckooFollow", body: [
                    "follower" : userObject._id,
                    "following" : userId
                ]) { (responseData) in
                    // Call the function to send notification to the user that get followed
                    AdditionalFunctions.init().sendNotification(forUser: userId, fromUser: userObject._id, content: "followed", image: "none", postId: "none")
                    
                    // Let view know that follow has been created via callback function
                    completion(true)
                }
            }
        }
    }
    
    // The function to check follow status between current user and user with specified user id
    func checkFollowStatusBetween2Users(userId: String, completion: @escaping (Bool) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET operation
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooFollow/checkFollowStatus?follower=\(userObject._id)&following=\(userId)") { (responseData) in
                    // Get the data (follow status)
                    let dataFetched = responseData["data"] as! String
                    
                    // Check the follow status
                    if (dataFetched == "Yes") {
                        // Let the view know that the 2 users follow each other via callback function
                        completion(true)
                    } else {
                        // Otherwise, return false
                        completion(false)
                    }
                }
            }
        }
    }
    
    // The function to remove a follow between current user and user with specified user id
    func removeAFollowBetween2Users(userId: String, completion: @escaping (Bool) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform DELETE operation
                self.apiOperations.performDELETERequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooFollow/deleteCuckooFollowBetween2Users?follower=\(userObject._id)&following=\(userId)") { (isDeleted) in
                    // Check if follow is removed or not
                    // set content of the follow button to be "  Follow  "
                    if (isDeleted) {
                        // Let the view know that follow between the 2 users has been removed
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
}
