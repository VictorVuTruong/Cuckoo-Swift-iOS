//
//  ProfilePageViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/24/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class ProfilePageViewController: UITableViewController {
    // The URL to get info of the currently logged in user
    let getCurrentUserInfoURL = URL(string: "\(AppResource.init().APIURL)/api/v1/users/getUserInfoBasedOnToken")
    
    // User id of the currently logged in user
    var userId = ""
    
    // Cover photo of the user
    @IBOutlet weak var userCoverPhoto: UIImageView!
    
    // Avatar of the user
    @IBOutlet weak var userAvatar: UIImageView!
    
    // The view which surround the user avtar
    @IBOutlet weak var userAvatarView: UIView!
    
    // The view which surround the user cover photo
    @IBOutlet weak var userCoverPhotoView: UIView!
    
    // The text field which will show the full name
    @IBOutlet weak var fullNameTextField: UITextField!
    
    // The text field which will show the phone number
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    // The text field which will show the email
    @IBOutlet weak var emailTextField: UITextField!
    
    // The text field which will show the facebook id
    @IBOutlet weak var facebookTextField: UITextField!
    
    // The text field which will show the instagram id
    @IBOutlet weak var instagramTextField: UITextField!
    
    // The text field which will show the zalo id
    @IBOutlet weak var zaloTextField: UITextField!
    
    // The text field which will show the twitter id
    @IBOutlet weak var twitterTextField: UITextField!
    
    // The text field which will show bio of the user
    @IBOutlet weak var bioTextField: UITextView!
    
    // Update buttons
    @IBAction func update1(_ sender: UIButton) {
        // Call the function to update user info
        updateUserInfo(phoneNumber: phoneNumberTextField.text!, facebook: facebookTextField.text!, instagram: instagramTextField.text!, zalo: zaloTextField.text!, twitter: twitterTextField.text!, userId: userId, bio: bioTextField.text!)
    }
    @IBAction func update2(_ sender: UIButton) {
        // Call the function to update user info
        updateUserInfo(phoneNumber: phoneNumberTextField.text!, facebook: facebookTextField.text!, instagram: instagramTextField.text!, zalo: zaloTextField.text!, twitter: twitterTextField.text!, userId: userId, bio: bioTextField.text!)
    }
    @IBAction func update3(_ sender: UIButton) {
        // Call the function to update user info
        updateUserInfo(phoneNumber: phoneNumberTextField.text!, facebook: facebookTextField.text!, instagram: instagramTextField.text!, zalo: zaloTextField.text!, twitter: twitterTextField.text!, userId: userId, bio: bioTextField.text!)
    }
    @IBAction func update4(_ sender: UIButton) {
        // Call the function to update user info
        updateUserInfo(phoneNumber: phoneNumberTextField.text!, facebook: facebookTextField.text!, instagram: instagramTextField.text!, zalo: zaloTextField.text!, twitter: twitterTextField.text!, userId: userId, bio: bioTextField.text!)
    }
    @IBAction func update5(_ sender: UIButton) {
        // Call the function to update user info
        updateUserInfo(phoneNumber: phoneNumberTextField.text!, facebook: facebookTextField.text!, instagram: instagramTextField.text!, zalo: zaloTextField.text!, twitter: twitterTextField.text!, userId: userId, bio: bioTextField.text!)
    }
    @IBAction func update6(_ sender: UIButton) {
        // Call the function to update user info
        updateUserInfo(phoneNumber: phoneNumberTextField.text!, facebook: facebookTextField.text!, instagram: instagramTextField.text!, zalo: zaloTextField.text!, twitter: twitterTextField.text!, userId: userId, bio: bioTextField.text!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Call the function to set up the profile page
        getInfoOfCurrentUser()
        
        // Call the function to make the avatar look round
        makeRounded()
        
        // Create tap gesture recognizer which will take user to the view controller where the user can update avatar
        let tapGestureUpdateAvatarView = UITapGestureRecognizer(target: self, action: #selector(viewTappedUpdateAvatar(gesture:)))
        
        // Create tap gesture recognizer which will take user to the view controller where the user can update cover photo
        let tapGestureUpdateCoverPhotoView = UITapGestureRecognizer(target: self, action: #selector(viewTappedUpdateCoverPhoto(gesture:)))
        
        // Add tap gesture to the view which surrounds user avatar
        userAvatarView.addGestureRecognizer(tapGestureUpdateAvatarView)
        
        // Add tap gesture to the view which surrounds user cover photo
        userCoverPhotoView.addGestureRecognizer(tapGestureUpdateCoverPhotoView)
    }
    
    // The function which will take user to the view controller where the user can update avatar
    @objc func viewTappedUpdateAvatar(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Perform the segue and take user to the view controller where the user can update avatar
            performSegue(withIdentifier: "profilePageToUpdateAvatar", sender: self)
        }
    }
    
    // The function which will take user to the view controller where the user can update cover photo
    @objc func viewTappedUpdateCoverPhoto(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view) != nil {
            // Perform the segue and take user to the view controller where the user can update cover photo
            performSegue(withIdentifier: "profilePageToUpdateCoverPhoto", sender: self)
        }
    }
    
    // The function to get info of the currently logged in user
    func getInfoOfCurrentUser() {
        // Create the request for getting info of the currently logged in user
        var getCurrentUserInfoRequest = URLRequest(url: getCurrentUserInfoURL!)
        
        // Let the method to get user info be GET
        getCurrentUserInfoRequest.httpMethod = "GET"
        
        // Get user info task
        let getCurrentUserInfoTask = URLSession.shared.dataTask(with: getCurrentUserInfoRequest) { (data, response, error) in
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
                        // Get the data (sign up token)
                        let dataFetched = convertedJSONIntoDict["data"] as! [String: Any]
                        
                        // Get name of the user
                        let fullName = dataFetched["fullName"] as! String
                        
                        // Get user id in the database of the user
                        let userId = dataFetched["_id"] as! String
                        self.userId = userId
                        
                        // Get avatar URL of the user
                        let avatarURL = dataFetched["avatarURL"] as! String
                        
                        // Get cover photo URL of the user
                        let coverURL = dataFetched["coverURL"] as! String
                        
                        // Get phone number of the user
                        let phoneNumber = dataFetched["phoneNumber"] as! String
                        
                        // Get email of the user
                        let email = dataFetched["email"] as! String
                        
                        // Get facebook id of the user
                        let facebookId = dataFetched["facebook"] as! String
                        
                        // Get instagram id of the user
                        let instagramId = dataFetched["instagram"] as! String
                        
                        // Get zalo id of the user
                        let zaloId = dataFetched["zalo"] as! String
                        
                        // Get twitterId of the user
                        let twitterId = dataFetched["twitter"] as! String
                        
                        // Get bio of the user
                        let bio = dataFetched["description"] as! String
                        
                        DispatchQueue.main.async {
                            // Set full name to the label
                            self.fullNameTextField.text = fullName
                            
                            // Set phone number to the label
                            self.phoneNumberTextField.text = phoneNumber
                            
                            // Set email to the label
                            self.emailTextField.text = email
                            
                            // Set facebook id to the label
                            self.facebookTextField.text = facebookId
                            
                            // Set instagram id to the label
                            self.instagramTextField.text = instagramId
                            
                            // Set zalo id to the label
                            self.zaloTextField.text = zaloId
                            
                            // Set twitter id to the label
                            self.twitterTextField.text = twitterId
                            
                            // Set bio to the text field
                            self.bioTextField.text = bio
                            
                            // Load avatar into the ImageView for the user
                            self.userAvatar.sd_setImage(with: URL(string: avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
                            
                            // Load cover photo into the ImageView for the user
                            self.userCoverPhoto.sd_setImage(with: URL(string: coverURL), placeholderImage: UIImage(named: "placeholder.jpg"))
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }

            }
        }
        
        // Resume the get user info task
        getCurrentUserInfoTask.resume()
    }
    
    // The function to update user info
    func updateUserInfo(phoneNumber: String, facebook: String, instagram: String, zalo: String, twitter: String, userId: String, bio: String) {
        // The URL to update user's info
        let updateUserInfoURL = URL(string: "\(AppResource.init().APIURL)/api/v1/users/updateMe?userId=\(userId)")
        
        // Create request for updating user info
        var updateUserInfoRequest = URLRequest(url: updateUserInfoURL!)
        
        // Let the method for updating user info to be PATCH
        updateUserInfoRequest.httpMethod = "PATCH"
        updateUserInfoRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Parameters which will be sent to request body and submit to the API endpoint
        let jsonRequestBody : [String: Any] = [
            "phoneNumber" : phoneNumber,
            "facebook" : facebook,
            "instagram" : instagram,
            "twitter" : twitter,
            "zalo" : zalo,
            "description" : bio
        ]
        
        // Set body content for the request
        updateUserInfoRequest.httpBody = jsonRequestBody.percentEncoded()
        
        // Perform the request and update user info
        let updateUserInfoTask = URLSession.shared.dataTask(with: updateUserInfoRequest) { (data, response, error) in
            // Check for error
            if let error = error {
                // Report the error
                print("There seem to be an error \(error)")

                // Get out of the function
                return
            }
            
            if let response = response {
                print(response)
            }
        }
        
        // Resume the task
        updateUserInfoTask.resume()
    }
    
    // The function to make the round image view for the avatar
    func makeRounded () {
        let radius = userAvatar.frame.width / 2.0
        userAvatar.layer.cornerRadius = radius
        userAvatar.layer.masksToBounds = true
    }
}
