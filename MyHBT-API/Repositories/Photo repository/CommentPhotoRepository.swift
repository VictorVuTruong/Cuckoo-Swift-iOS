//
//  CommentPhotoRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 3/13/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class CommentPhotoRepository {
    // The object to perform API operations
    let apiOperations = APIOperations()
    
    // The function to get comment photo URL based on comment id
    func getCommentPhotoBasedOnCommentId(commentId: String, completion: @escaping (String) -> ()) {
        // Call the function to perform GET operations
        apiOperations.performGETRequest(url: "\(AppResource.init().APIURL)/api/v1/cuckooPostCommentPhoto?commentId=\(commentId)") { (responseData) in
            // Get the data (this will include the image URL we are looking for)
            let dataFetched = (((responseData["data"] as! [String: Any])["documents"]) as! [[String: Any]])[0]
            
            // Get image URL of the image belongs to the message
            let imageURL = dataFetched["imageURL"] as! String
            
            // Return image URL via callback function
            completion(imageURL)
        }
    }
}
