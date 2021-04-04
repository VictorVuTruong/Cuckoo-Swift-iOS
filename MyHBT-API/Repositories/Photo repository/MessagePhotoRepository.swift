//
//  MessagePhotoRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 3/13/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class MessagePhotoRepository {
    // The object to perform API operations
    let apiOperations = APIOperations()
    
    // The function to get message photo of message based on message id
    func getMessagePhotoBasedOnMessageId(messageId: String, completion: @escaping (String) -> ()) {
        // Call the function to perform GET operation
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/messagePhoto?messageId=\(messageId)") { (responseData) in
            // Get the data (this will include the image URL we are looking for)
            let dataFetched = (((responseData["data"] as! [String: Any])["documents"]) as! [[String: Any]])[0]
            
            // Get image URL of the image belongs to the message
            let imageURL = dataFetched["imageURL"] as! String
            
            // Return image URL of message via callback function
            completion(imageURL)
        }
    }
}
