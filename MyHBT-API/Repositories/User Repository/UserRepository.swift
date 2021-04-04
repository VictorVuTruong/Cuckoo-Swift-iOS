//
//  UserRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 2/14/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class UserRepository {
    // The decoder which will be used to decode the JSON array
    let decoder = JSONDecoder()
    
    // The object to perform API operations
    let apiOperations = APIOperations()
        
    // The function to get info of the currently logged in user
    func getInfoOfCurrentUser(completion: @escaping (User) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/users/getUserInfoBasedOnToken") { (responseData) in
            do {
                // Convert raw data from database into JSON data
                let userInfoFromDatabase = try JSONSerialization.data(withJSONObject: responseData["data"] as! [String: Any], options: [])
                
                // Convert the JSON data into user object
                let userObject = try self.decoder.decode(User.self, from: userInfoFromDatabase)
                
                // Return user object via callback function
                completion(userObject)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to get user info based on id
    func getUserInfoBasedOnId(userId: String, completion: @escaping (User) -> ()) {
        // Call the function to perform GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/users?_id=\(userId)") { (responseData) in
            do {
                // Get the data
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Convert raw data from database into JSON data
                let userInfoFromDatabase = try JSONSerialization.data(withJSONObject: (dataFetched["documents"] as! [[String: Any]])[0], options: [])
                
                // Convert the JSON data into user object
                let userObject = try self.decoder.decode(User.self, from: userInfoFromDatabase)
                
                // Return user object to the view controller cvia callback function
                completion(userObject)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to sign out current user
    func signOut(completion: @escaping () -> ()) {
        // Call the function to perform the POST request
        apiOperations.performPOSTRequest(url: "\(AppResource.init().APIURL)/api/v1/users/logout") { (_) in
            // Let view controller know that sign out is done via callback function
            completion()
        }
    }
    
    // The function to update avatar of the currently logged in user
    func updateCurrentUserAvatar(avatarURL: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform PATCH request
                self.apiOperations.performPATCHRequest(url: "\(AppResource.init().APIURL)/api/v1/users/updateMe?userId=\(userObject._id)", body: [
                    "avatarURL" : avatarURL
                ]) { (_) in }
            }
        }
    }
    
    // The function to update cover photo of the currently logged in user
    func updateCurrentUserCoverPhoto(coverURL: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform PATCH request
                self.apiOperations.performPATCHRequest(url: "\(AppResource.init().APIURL)/api/v1/users/updateMe?userId=\(userObject._id)", body: [
                    "coverURL" : coverURL
                ]) { (_) in }
            }
        }
    }
    
    // The function to search user based on full name
    func searchUser(searchQuery: String, completion: @escaping ([User]) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/users/searchUser?fullName=\(searchQuery)") { (responseData) in
            do {
                // Convert raw data from database into JSON data
                let arrayOfFoundUsersFromDatabase = try JSONSerialization.data(withJSONObject: responseData["data"] as! [[String: Any]], options: [])
                
                // Convert the JSON data into array of post objects
                let arrayOfFoundUserObjects = try self.decoder.decode([User].self, from: arrayOfFoundUsersFromDatabase)
                
                // Return array of users to view via callback function
                completion(arrayOfFoundUserObjects)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to get user bio
    func getUserBio(userId: String, completion: @escaping (String) -> ()) {
        // Call the function to perform GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/users?_id=\(userId)") { (responseData) in
            // Get the data
            let dataFetched = responseData["data"] as! [String: Any]
            
            // Get user info. This will be an array of users. But we will take the first one and there will be only one user in here
            let userInfo = (dataFetched["documents"] as! [[String: Any]])[0]
            
            // Get bio of the useer
            let bio = userInfo["description"] as! String
            
            // Return bio via callback function
            completion(bio)
        }
    }
    
    // The function to get list of user ids of users who follow user with specified user id
    func getListOfFollowers(following: String, completion: @escaping ([CuckooFollow]) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooFollow?following=\(following)") { (responseData) in
            do {
                // Get the data (list of followers)
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Get array of follows as raw data and convert into JSON data
                let arrayOfLikesJSONData = try JSONSerialization.data(withJSONObject: dataFetched["documents"] as! [[String: Any]], options: [])
                
                // Convert JSON data into array of follow objects
                let arrayOfFollowObjects = try self.decoder.decode([CuckooFollow].self, from: arrayOfLikesJSONData)
                
                // Return array of follows via callback function
                completion(arrayOfFollowObjects)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // The function to get list of user ids of users that user with specified user id is following
    func getListOfFollowing(follower: String, completion: @escaping ([CuckooFollow]) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooFollow?follower=\(follower)") { (responseData) in
            do {
                // Get the data (list of followers)
                let dataFetched = responseData["data"] as! [String: Any]
                
                // Get array of follows as raw data and convert into JSON data
                let arrayOfLikesJSONData = try JSONSerialization.data(withJSONObject: dataFetched["documents"] as! [[String: Any]], options: [])
                
                // Convert JSON data into array of follow objects
                let arrayOfFollowObjects = try self.decoder.decode([CuckooFollow].self, from: arrayOfLikesJSONData)
                
                // Return array of follows via callback function
                completion(arrayOfFollowObjects)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
