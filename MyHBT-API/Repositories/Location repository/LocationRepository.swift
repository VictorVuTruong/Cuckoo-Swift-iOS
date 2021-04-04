//
//  LocationRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 3/10/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class LocationRepository {
    // The decoder which will be used to decode the JSON array
    let decoder = JSONDecoder()
    
    // User repository
    let userRepository = UserRepository()
    
    // The object to perform API operations
    let apiOperations = APIOperations()
    
    // The function to get location info of user based on user id
    func getLocationInfoOfUserBasedOnId(userId: String, completion: @escaping (String, String, Double, Double) -> ()) {
        // Call the function to perform GET operation
        self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/users?_id=\(userId)") { (responseData) in
            // Get the data
            let dataFetched = responseData["data"] as! [String: Any]
            
            // Get user info. This will be an array of users. But we will take the first one and there will be only one user in here
            let userInfo = (dataFetched["documents"] as! [[String: Any]])[0]
            
            // Get full name of the user
            let userFullName = userInfo["fullName"] as! String
            
            // Get location object of the user
            let userLocationObject = userInfo["location"] as! [String: Any]
            
            // Get location description of the user
            let userLocationDescription = userLocationObject["description"] as! String
            
            // Get latitude of the user
            let userLatitude = (userLocationObject["coordinates"] as! [Double])[1]
            
            // Get longitude of the user
            let userLongitude = (userLocationObject["coordinates"] as! [Double])[0]
            
            // Return location info via callback function
            completion(userFullName, userLocationDescription, userLatitude, userLongitude)
        }
    }
    
    // The function to update location of the currently logged in user
    func updateCurrentUserLocation(userLocationLongitude: Double, userLocationLatitude: Double, userLocationDescription: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // The URL to update user's info
                let updateUserInfoURL = URL(string: "\(AppResource.init().APIURL)/api/v1/users/updateMe?userId=\(userObject._id)")
                
                // Create request for updating user info
                var updateUserInfoRequest = URLRequest(url: updateUserInfoURL!)
                
                // Let the method for updating user info to be PATCH
                updateUserInfoRequest.httpMethod = "PATCH"
                updateUserInfoRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Parameters which will be sent to request body and submit to the API endpoint
                let jsonRequestBody : [String: Any] = [
                    "location" : [
                        "coordinates" : [userLocationLongitude, userLocationLatitude],
                        "description" : userLocationDescription,
                        "type" : "Point"
                    ]
                ]
                
                // Set body content for the request
                do {
                    updateUserInfoRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonRequestBody, options: .prettyPrinted)
                } catch let error {
                    print(error.localizedDescription)
                }
                
                // Perform the request and update user info
                let updateUserInfoTask = URLSession.shared.dataTask(with: updateUserInfoRequest) { (data, response, error) in
                    // Check for error
                    if let error = error {
                        // Report the error
                        print("There seem to be an error \(error)")

                        // Get out of the function
                        return
                    }
                    
                    if let response = response {
                        print(response)
                    }
                }
                
                // Resume the task
                updateUserInfoTask.resume()
            }
        }
    }
    
    // The function to get location info of last updated location of the currently logged in user
    func getLocationInfoOfLastUpdatedLocationOfCurrentUser(completion: @escaping (String, String, Double, Double) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET operation
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/users/getUserInfoBasedOnToken") { (responseData) in
                    // Get the data (sign up token)
                    let dataFetched = responseData["data"] as! [String: Any]
                    
                    // Get full name of the user
                    let userFullName = dataFetched["fullName"] as! String
                    
                    // Get location object of the user
                    let userLocationObject = dataFetched["location"] as! [String: Any]
                    
                    // Get location description of the user
                    let userLocationDescription = userLocationObject["description"] as! String
                    
                    // Get latitude of the user
                    let userLatitude = (userLocationObject["coordinates"] as! [Double])[1]
                    
                    // Get longitude of the user
                    let userLongitude = (userLocationObject["coordinates"] as! [Double])[0]
                    
                    // Return location info via callback function
                    completion(userFullName, userLocationDescription, userLatitude, userLongitude)
                }
            }
        }
    }
}
