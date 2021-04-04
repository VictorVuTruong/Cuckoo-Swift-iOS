//
//  NotificationRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 3/7/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class NotificationRepository {
    // The decoder which will be used to decode the JSON array
    let decoder = JSONDecoder()
    
    // User repository
    let userRepository = UserRepository()
    
    // API operations performer
    let apiOperations = APIOperations()
    
    // The function to order in collection of latest notification in the database
    func getOrderInCollectionOfLatestNotification(completion: @escaping (Int) -> ()) {
        // Call the function to perform GET request
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooNotifications/getOrderInCollectionOfLatestNotification") { (responseData) in
            // Get the data (order in collection of latest notification)
            let dataFetched = responseData["data"] as! Int
            
            // Return order in collection of latest notification via callback function
            completion(dataFetched)
        }
    }
    
    // The function to load notifications for the currently logged in user
    func loadNotificationsForCurrentUser(currentLocationInList: Int, completion: @escaping ([Notification], Int) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Call the function to get info of the currently logged in user
            self.userRepository.getInfoOfCurrentUser { (userObject) in
                // Call the function to perform GET request
                self.apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooNotifications/getNotificationsForUser?userId=\(userObject._id)&currentLocationInList=\(currentLocationInList)") { (responseData) in
                    do {
                        // Get the data (list of notifications)
                        let dataFetched = responseData["data"] as! [[String: Any]]
                        
                        // Get the new current location in list for next load
                        let newCurrentLocationInList = responseData["newCurrentLocationInList"] as! Int
                        
                        // Convert list of notifications from database into JSON data
                        let arrayOfNotifications = try JSONSerialization.data(withJSONObject: dataFetched, options: [])
                        
                        // Convert the JSON data into array of notifications
                        let arrayOfNotificationsObjects = try self.decoder.decode([Notification].self, from: arrayOfNotifications)
                        
                        // Return array of notifications and order in collection for next load via callback function
                        completion(arrayOfNotificationsObjects, newCurrentLocationInList)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // The function to get notification detail
    func getNotificationDetail(content: String, userId: String, completion: @escaping (User, String) -> ()) {
        // Call the function to get info of user based on user id
        userRepository.getUserInfoBasedOnId(userId: userId) { (userObject) in
            // Notification content
            var notificationContent = ""
            
            // Based on content of the notification from database to create right content
            if (content == "liked") {
                // Update content for notification
                notificationContent = "\(userObject.fullName) has liked your post"
            } else if (content == "commented") {
                // Update content
                notificationContent = "\(userObject.fullName) has commented on your post"
            } else {
                // Update content
                notificationContent = "\(userObject.fullName) started following you"
            }
            
            // Return notification detail and user object that is associated with the notification
            completion(userObject, notificationContent)
        }
    }
}
