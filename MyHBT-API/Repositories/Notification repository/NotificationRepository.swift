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
    
    // The function to update or create notification socket for currently logged in user
    func createOrUpdateNotificationSocket(socketId: String, deviceModel: String, completion: @escaping () -> ()) {
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Call the function to perform PATCH request
            self.apiOperations.performPATCHRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooNotificationSocket/updateNotificationSocket", body: [
                "userId": userObject._id,
                "deviceModel": deviceModel,
                "socketId": socketId
            ]) { (responseData) in
                // Get status of the operation
                let status = responseData["status"] as! String
                
                // If the status is "Done", call let the view know that operation is done via callback function
                if (status == "Done") {
                    completion()
                }
            }
        }
    }
    
    // The function to delete a notification socket
    func deleteNotificationSocket(deviceModel: String, socketId: String, completion: @escaping () -> ()) {
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Call the function to perform the DELETE request
            self.apiOperations.performDELETERequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooNotificationSocket/deleteNotificationSocket?userId=\(userObject._id)&socketId=\(socketId)&deviceModel=\(deviceModel)") { (isDone) in
                // If the deletion is done, call the callback function to get the view know that
                if (isDone) {
                    completion()
                }
            }
        }
    }
    
    // The function to send notification to user with specified user id
    func sendNotificationToUser(userId: String, notificationContent: String, notificationTitle: String, completion: @escaping () -> ()) {
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Call the function to perform POST operation with request body
            self.apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/cuckooNotifications/sendNotificationToUserBasedOnUserId", body: [
                "userId": userId,
                "notificationContent": notificationContent,
                "notificationTitle": notificationTitle,
                "notificationSender": userObject._id
            ]) { (responseData) in
                // Get status of the operation
                let status = responseData["status"] as! String
                
                // If the status is "Done", let the view know that the operation is done via callback function
                if (status == "Done") {
                    completion()
                }
            }
        }
    }
    
    // The function to send data notification to user with specified user id
    func sendDataNotificationToUser(userId: String, notificationContent: String, notificationTitle: String, completion: @escaping () -> ()) {
        // Call the function to perform POST operation with request body
        apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/cuckooNotifications/sendDataNotificationToUserBasedOnUserId", body: [
            "userId": userId,
            "notificationContent": notificationContent,
            "notificationTitle": notificationTitle
        ]) { (responseData) in
            // Get status of the operation
            let status = responseData["status"] as! String
            
            // If the status is "Done", let the view know that the operation is done via callback function
            if (status == "Done") {
                completion()
            }
        }
    }
}
