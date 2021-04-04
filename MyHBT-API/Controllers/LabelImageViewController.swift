//
//  LabelImageViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/24/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import Firebase

class LabelImageViewController: UIViewController {
    // Image view which will show image to be labeled
    @IBOutlet weak var imageToLabel: UIImageView!
    
    // The button to choose image to label
    @IBAction func chooseImageButton(_ sender: UIButton) {
        // Call the function to show the file picker so that the user can pick the image to post
        showImagePickerController()
    }
    
    // The button to start labeling
    @IBAction func labelButton(_ sender: UIButton) {
        // Call the function to start labeling
        labelImage(image: imageToLabel.image!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // The function to start labeling image
    func labelImage(image: UIImage) {
        // Create image object for the labeler
        let image = VisionImage(image: image)
        
        // The labeler
        let labeler = Vision.vision().cloudImageLabeler()
        
        // Start with labeling
        labeler.process(image) { labels, error in
            guard error == nil, let labels = labels else { return }

            for label in labels {
                let labelText = label.text
                let entityId = label.entityID
                let confidence = label.confidence
                
                print("\(labelText) \(entityId) \(confidence)")
            }
        }
    }
}

// Extension for the image picker
extension LabelImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        //test()
        //print(imageURL)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Load image to label into the image view
            imageToLabel.image = image
        } else if let originalImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // Load image to label into the image view
            imageToLabel.image = originalImage
        }
        
        // Dismiss the image file chooser when the image selection is done
        dismiss(animated: true, completion: nil)
    }
}
