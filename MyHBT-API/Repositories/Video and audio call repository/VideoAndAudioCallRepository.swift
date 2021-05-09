//
//  VideoAndAudioCallRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 5/2/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class VideoAndAudioCallRepository {
    // The decoder which will be used to decode the JSON array
    let decoder = JSONDecoder()
    
    // User repository
    let userRepository = UserRepository()
    
    // API operations performer
    let apiOperations = APIOperations()
    
    // The function to get access token to get into video chat room for user with specified user id and room name
    func getAccessTokenIntoVideoChatRoom(chatRoomName: String, userId: String, completion: @escaping (String) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/videoChat/getAccessToken?userId=\(userId)&roomId=\(chatRoomName)") { (responseData) in
            // Get access token from response data
            let accessToken = responseData["accessToken"] as! String
            
            // Return access token to the view via callback function
            completion(accessToken)
        }
    }
    
    // The function to create video chat room with specified name
    func createVideoChatRoom(chatRoomName: String, completion: @escaping (Bool) -> ()) {
        // Call the function to perform POST request
        apiOperations.performPOSTRequest(url: "\(AppResource.init().APIURL)/api/v1/videoChat/createRoom?chatRoomName=\(chatRoomName)") { (responseData) in
            // Get status of the call
            let status = responseData["status"] as! String
            
            // Check status to see if room is created or already existed
            if (status == "Success. Room created") {
                // Call the function and let the view know that room has been created
                completion(false)
            } else {
                // Call the function and let the view know that room is already existed
                completion(true)
            }
        }
    }
    
    // The function to delete video chat room
    func deleteVideoChatRoom(chatRoomName: String, completion: @escaping (Bool) -> ()) {
        // Call the function to perform POST request
        apiOperations.performDELETERequest(url: "\(AppResource.init().APIURL)/api/v1/videoChat/endRoom?chatRoomName=\(chatRoomName)") { (isRemoved) in
            // Call the function to let the view know that room has been removed or not
            completion(isRemoved)
        }
    }
}
