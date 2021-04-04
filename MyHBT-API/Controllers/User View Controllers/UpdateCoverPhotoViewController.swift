//
//  UpdateCoverPhotoViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/25/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import Firebase

class UpdateCoverPhotoViewController: UIViewController {
    // User repository
    let userRepository = UserRepository()
    
    // Additional assets
    let additionalAssets = AdditionalAssets()
    
    // The button to choose new cover photo
    @IBAction func choosePhotoButton(_ sender: UIButton) {
        // Call the function to open the image chooser
        showImagePickerController()
    }
    
    // The button to update cover photo
    @IBAction func updatePhotoButton(_ sender: Any) {
        // Call the function to update cover photo
        updateCoverPhoto()
    }
    
    // The image view where cover photo of the user is previewed
    @IBOutlet weak var previewCoverPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Call the functiont to load cover photo of the current user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Load cover photo of the current user into the ImageView
            DispatchQueue.main.async {
                self.previewCoverPhoto.sd_setImage(with: URL(string: userObject.coverURL), placeholderImage: UIImage(named: "placeholder.jpg"))
            }
        }
    }
    
    // The function to update cover photo
    func updateCoverPhoto() {
        // Call the function to upload new cover photo of current user to the storage
        additionalAssets.uploadPhotoToDatabase(reference: "cover", image: self.previewCoverPhoto.image!) { (downloadURL) in
            // Call the function to put update new cover photo URL in the database
            self.updateCoverPhotoURLInDatabase(coverURL: downloadURL)
        }
    }
    
    // The function to update avatar URL in the database
    func updateCoverPhotoURLInDatabase(coverURL: String) {
        // Call the function to update cover photo URL for the current user
        userRepository.updateCurrentUserCoverPhoto(coverURL: coverURL)
    }
}

// Extension for the image file chooser by which the user can pick the new avatar
extension UpdateCoverPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // The function to show the image chooser to the user
    func showImagePickerController() {
        // The image picker object
        let imagePicker = UIImagePickerController()
        
        // Let the delegate to the self and let the user edit the image so that the user can crop or do other things
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Present the image file chooser
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Set the image that has just been picked and editted from library into the image view
            self.previewCoverPhoto.image = image
        } else if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Set the image that has been picked from library into the image view
            self.previewCoverPhoto.image = originalImage
        }
        
        // Dismiss the image file chooser when the image selection is done
        dismiss(animated: true, completion: nil)
    }
}
