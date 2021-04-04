//
//  AdditionalAssets.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 2/26/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AdditionalAssets {
    // Instance of the Firebase storage
    let storage = Storage.storage()
    
    // The function to upload photos to the database
    func uploadPhotoToDatabase(reference: String, image: UIImage, completion: @escaping (String) -> ()) {
        // Generate name for the image which is going to be added to the database and storage
        let imageName = AppResource().randomString(length: 20)
        
        // Do it asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            // Get the image data
            let imageData = image.jpegData(compressionQuality: 0.1)!
            
            // Create the reference to the storage to save the photo
            let imageRef = self.storage.reference().child("\(reference)/\(imageName).jpg")
            
            // Begin with the uploading process
            imageRef.putData(imageData, metadata: nil) {(metadata, error) in
                // Get the download URL of the image when done
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error \(error)")
                    }
                    
                    guard let downloadURL = url else {
                        return
                    }
                    
                    // Return download URL of the uploaded photo via callback function
                    completion(downloadURL.absoluteString)
                }
            }
        }
    }
}
