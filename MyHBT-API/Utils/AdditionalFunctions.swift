//
//  AdditionalFunctions.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/25/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class AdditionalFunctions {
    // The function to make the round image view for the avatar
    func makeRounded (image: UIImageView) {
        let radius = image.frame.width / 2.0
        image.layer.cornerRadius = radius
        image.layer.masksToBounds = true
    }
    
    // The function to load full name and avatar of the message sender based on user id
    func getUserFullNameAndAvatar(userId: String, senderFullName: UILabel, senderAvatar: UIImageView) {
        print(userId)
        
        // The URL to get info of the user based on user id
        let getUserInfoURL = URL(string: "\(AppResource.init().APIURL)/api/v1/users?_id=\(userId)")
                
        // Create request for getting user info based on the specified user id
        var getUserInfoRequest = URLRequest(url: getUserInfoURL!)
        
        // Let the method to get user info be GET
        getUserInfoRequest.httpMethod = "GET"
        
        // Get user info task
        let getUserInfoTask = URLSession.shared.dataTask(with: getUserInfoRequest) { (data, response, error) in
            // Check for error
            if let error = error {
                // Report the error
                print("There seem to be an error \(error)")
            }
            
            // Get data from the response
            if let data = data {
                // Convert the JSON data string into the NSDictionary
                do {
                    if let convertedJSONIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as?
                        NSDictionary {
                        // Get the data
                        let dataFetched = convertedJSONIntoDict["data"] as! [String: Any]
                        
                        // Get user info. This will be an array of users. But we will take the first one and there will be only one user in here
                        let userInfo = (dataFetched["documents"] as! [[String: Any]])[0]
                        
                        // Get full name of the user
                        let fullName = userInfo["fullName"] as! String
                        
                        // Get avatar URL of the user
                        let avatarURL = userInfo["avatarURL"] as! String
                        
                        DispatchQueue.main.async {
                            // Load full name into the label
                            senderFullName.text = fullName
                            
                            // Load avatar into the ImageView
                            senderAvatar.sd_setImage(with: URL(string: avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        
        // Resume the task
        getUserInfoTask.resume()
    }
    
    // The function to replace an occurence of a string with a specified character
    func replaceStringOccurence(originalString: String, characterToReplace: String, replaceCharacterWith: String) -> String {
        // Return a string which has already been replaced
        return originalString.replacingOccurrences(of: characterToReplace, with: replaceCharacterWith)
    }
    
    // The function to send notification to other user
    func sendNotification(forUser: String, fromUser: String, content: String, image: String, postId: String) {
        // The URL to create new notification
        let createNewNotificationURL = URL(string: "\(AppResource.init().APIURL)/api/v1/cuckooNotifications?content=\(content)&forUser=\(forUser)&fromUser=\(fromUser)&image=\(image)&postId=\(postId)")
        
        // Create request to perform the call
        var createNewNotificationRequest = URLRequest(url: createNewNotificationURL!)
        
        // Let the to be GET
        createNewNotificationRequest.httpMethod = "POST"
        createNewNotificationRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Parameters which will be sent to request body and submit to the API endpoint
        let jsonRequestBody : [String: Any] = [
            "content": content,
            "forUser": forUser,
            "fromUser": fromUser,
            "image": image,
            "postId": postId
        ]
        
        // Set body content for the request
        createNewNotificationRequest.httpBody = jsonRequestBody.percentEncoded()
        
        // The task to perform the call
        let createNewNotificationTask = URLSession.shared.dataTask(with: createNewNotificationRequest) { (data, response, error) in
            // Check for error
            if let error = error {
                // Report the error
                print("There seem to be an error \(error)")
            }
        }
        
        // Resume the task
        createNewNotificationTask.resume()
    }
    
    // The function to delete a photo in the storage
    func deletePhotoInStorage(photoURL: String, parentFolder: String) {
        // Firebase storage reference
        let imageRef = Storage.storage()
        
        // Get image name based on URL
        var imageURL = photoURL
        imageURL = imageURL.replacingOccurrences(of: "%2F", with: "!")

        let startOfName = imageURL.firstIndex(of: "!")!
        let endOfName = imageURL.firstIndex(of: "?")!
        var name = imageURL[startOfName..<endOfName]
        name.remove(at: name.firstIndex(of: "!")!)
                
        // Create reference to the image to be deleted
        // and delete it
        DispatchQueue.main.async {
            imageRef.reference().child("\(parentFolder)/\(name)")
            .delete { error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print("There seem to be an error \(error)")
                } else {
                    // File deleted successfully
                }
            }
        }
    }
    
    // The function to generate a random 10 character string
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
