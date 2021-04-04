//
//  UpdateAvatarViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/25/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import Firebase

class UpdateAvatarViewController: UIViewController {
    // The image view where avatar of the user is previewed
    @IBOutlet weak var previewAvatar: UIImageView!
    
    // User repository
    let userRepository = UserRepository()
    
    // Additional assets
    let additionalAssets = AdditionalAssets()
    
    // The button to choose new photo
    @IBAction func chooseNewPhotoButton(_ sender: UIButton) {
        // Call the function to open the image chooser
        showImagePickerController()
    }
    
    // The button to update avatar
    @IBAction func updatePhotoButton(_ sender: UIButton) {
        // Call the function to update avatar for the current user
        updateAvatar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Call the function to load avatar for the current user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Load avatar of the current user into the ImageView
            DispatchQueue.main.async {
                self.previewAvatar.sd_setImage(with: URL(string: userObject.avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
            }
        }
        
        // Call the function to make avatar look round
        AdditionalFunctions.init().makeRounded(image: previewAvatar)
    }
    
    // The function to update avatar
    func updateAvatar() {
        // Call the function to upload new avatar of the current user to the storage
        additionalAssets.uploadPhotoToDatabase(reference: "avatar", image: self.previewAvatar.image!) { (downloadURL) in
            // Call the function to put update new avatar URL in the database
            self.updateAvatarURLInDatabase(avatarURL: downloadURL)
        }
    }
    
    // The function to update avatar URL in the database
    func updateAvatarURLInDatabase(avatarURL: String) {
        // Call the function to update avatar for the currently logged in user
        userRepository.updateCurrentUserAvatar(avatarURL: avatarURL)
    }
}

// Extension for the image file chooser by which the user can pick the new avatar
extension UpdateAvatarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            self.previewAvatar.image = image
        } else if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Set the image that has been picked from library into the image view
            self.previewAvatar.image = originalImage
        }
        
        // Dismiss the image file chooser when the image selection is done
        dismiss(animated: true, completion: nil)
    }
}
