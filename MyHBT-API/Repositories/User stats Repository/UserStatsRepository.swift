//
//  UserStatsRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 2/26/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class UserStatsRepository {
    // The decoder which will be used to decode the JSON array
    let decoder = JSONDecoder()
    
    // User repository
    let userRepository = UserRepository()
    
    // The object to perform api operations
    let apiOperations = APIOperations()
    
    // The function to update user profile visit between the currently logged in user and user with the specified user id
    func updateUserProfileVisit(userId: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform the GET request
                self.apiOperations.performPOSTRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooAccountStats/updateProfilevisit?visitorUserId=\(userObject._id)&visitedUserId=\(userId)") { (_) in
                    
                }
            }
        }
    }
    
    // The function to get brief user stats of currently logged in user
    func getBriefUserStatsOfCurrentUser(completion: @escaping ([UserInteraction], [UserLikeInteraction], [UserCommentInteraction], [UserProfileVisit]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET request
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooAccountStats/getBriefAccountStats?userId=\(userObject._id)") { (responseData) in
                    do {
                        // Get the data (user stats info). And convert it to JSON data
                        let arrayOfUserInteraction = try JSONSerialization.data(withJSONObject: responseData["arrayOfUserInteraction"] as! [[String: Any]], options: [])
                        let arrayOfUserLikeInteraction = try JSONSerialization.data(withJSONObject: responseData["arrayOfUserLikeInteraction"] as! [[String: Any]], options: [])
                        let arrayOfUserCommentInteraction = try JSONSerialization.data(withJSONObject: responseData["arrayOfUserCommentInteraction"] as! [[String: Any]], options: [])
                        let arrayOfUserProfileVisit = try JSONSerialization.data(withJSONObject: responseData["arrayOfUserProfileVisit"] as! [[String: Any]], options: [])
                        
                        // Convert those JSON datas into array of user stats objects
                        let arrayOfUserInteractionObjects = try self.decoder.decode([UserInteraction].self, from: arrayOfUserInteraction)
                        let arrayOfUserLikeInteractionObjects = try self.decoder.decode([UserLikeInteraction].self, from: arrayOfUserLikeInteraction)
                        let arrayOfUserCommentInteractionObjects = try self.decoder.decode([UserCommentInteraction].self, from: arrayOfUserCommentInteraction)
                        let arrayOfUserProfileVisitObjects = try self.decoder.decode([UserProfileVisit].self, from: arrayOfUserProfileVisit)
                        
                        // Return these arrays to view controller via callback function
                        completion(arrayOfUserInteractionObjects, arrayOfUserLikeInteractionObjects, arrayOfUserCommentInteractionObjects, arrayOfUserProfileVisitObjects)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // The function to load list of users who interact with currently logged in user
    func getListOfUserInteraction(completion: @escaping ([UserInteraction]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET operation
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooAccountStats/getUserInteractionStatusForUser?userId=\(userObject._id)&limit=0") { (responseData) in
                    do {
                        // Get the data (array of user interaction). And convert it to JSON data
                        let arrayOfUserInteraction = try JSONSerialization.data(withJSONObject: responseData["data"] as! [[String: Any]], options: [])
                        
                        // Convert those JSON datas into array of user interaction objects
                        let arrayOfUserInteractionObjects = try self.decoder.decode([UserInteraction].self, from: arrayOfUserInteraction)
                        
                        // Return array of user interaction via callback function
                        completion(arrayOfUserInteractionObjects)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // The function to load list of users who like posts of the currently logged in user
    func getListOfUserLikeInteraction(completion: @escaping ([UserLikeInteraction]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET operation
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooAccountStats/getUserLikeInteractionStatus?userId=\(userObject._id)&limit=0") { (responseData) in
                    do {
                        // Get the data (array of user like interaction). And convert it to JSON data
                        let arrayOfUserLikeInteraction = try JSONSerialization.data(withJSONObject: responseData["data"] as! [[String: Any]], options: [])
                        
                        // Convert those JSON datas into array of user like interaction objects
                        let arrayOfUserLikeInteractionObjects = try self.decoder.decode([UserLikeInteraction].self, from: arrayOfUserLikeInteraction)
                        
                        // Return array of user like interaction via callback function
                        completion(arrayOfUserLikeInteractionObjects)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // The function to load list of users who comment posts of the currently logged in user
    func getListOfUserCommentInteration(completion: @escaping ([UserCommentInteraction]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET operation
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooAccountStats/getUserCommentInteractionStatus?userId=\(userObject._id)&limit=0") { (responseData) in
                    do {
                        // Get the data (array of user comment interaction). And convert it to JSON data
                        let arrayOfUserCommentInteraction = try JSONSerialization.data(withJSONObject: responseData["data"] as! [[String: Any]], options: [])
                        
                        // Convert those JSON datas into array of user comment interaction objects
                        let arrayOfUserCommentInteractionObjects = try self.decoder.decode([UserCommentInteraction].self, from: arrayOfUserCommentInteraction)
                        
                        // Return array of user comment interaction via callback function
                        completion(arrayOfUserCommentInteractionObjects)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // The function to load list of users who visit profile of the currently logged in user
    func getListOfUserProfileVisit(completion: @escaping ([UserProfileVisit]) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET request
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooAccountStats/getProfileVisitStatus?userId=\(userObject._id)&limit=0") { (resposeData) in
                    do {
                        // Get the data (array of user profile visit). And convert it to JSON data
                        let arrayOfUserProfileVisit = try JSONSerialization.data(withJSONObject: resposeData["data"] as! [[String: Any]], options: [])
                        
                        // Convert those JSON datas into array of user profile visit objects
                        let arrayOfUserProfileVisitObjects = try self.decoder.decode([UserProfileVisit].self, from: arrayOfUserProfileVisit)
                        
                        // Return array of user profile visit via callback function
                        completion(arrayOfUserProfileVisitObjects)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
