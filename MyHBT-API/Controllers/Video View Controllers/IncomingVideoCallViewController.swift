//
//  IncomingVideoCallViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 4/30/21.
//  Copyright © 2021 beta. All rights reserved.
//

import UIKit

class IncomingVideoCallViewController: UIViewController {
    var window: UIWindow?
    
    // User repository
    let userRepository = UserRepository()
    
    // Notification repository
    let notificationRepository = NotificationRepository()
    
    // Caller user id
    var callerUserId = ""
    
    // Chat room name
    var chatRoomName = ""
    
    // Avatar of the caller
    @IBOutlet weak var callerAvatar: UIImageView!
    
    // Name of the caller
    @IBOutlet weak var callerName: UILabel!
    
    // Accept call button
    @IBAction func acceptCallButton(_ sender: UIButton) {
        // Perform segue and take user to the view controller where user can start the video call
        //performSegue(withIdentifier: "incomingVideoCallToVideoCall", sender: self)
        
        let windowScene = UIApplication.shared
                        .connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .first
        if let windowScene = windowScene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
        }
        
        //let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let incomingCallViewController = storyboard!.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
        self.window?.frame = UIScreen.main.bounds
        self.window?.backgroundColor = .clear
        
        // Set the post object in the post detail view controller to be the one that the user selected
        incomingCallViewController.chatRoomName = self.chatRoomName
        
        // Set the call receiver user id in the video view controller to be the caller
        incomingCallViewController.callReceiverUserId = self.callerUserId
        
        self.window?.rootViewController = incomingCallViewController
        self.window?.makeKeyAndVisible()
        
        dismiss(animated: true, completion: nil)
    }
    
    // Decline call button
    @IBAction func declineCallButton(_ sender: Any) {
        // Dismiss the incoming call view controller
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Call the function to make the avatar look round
        AdditionalFunctions.init().makeRounded(image: callerAvatar)
        
        // Call the function to get info of the caller
        loadInfoOfCaller(callerUserId: callerUserId)
    }
    
    // The function to load info of the caller
    func loadInfoOfCaller(callerUserId: String) {
        // Call the function to get user info based on id
        userRepository.getUserInfoBasedOnId(userId: callerUserId) { (userObject) in
            DispatchQueue.main.async {
                // Load user name into the label
                self.callerName.text = userObject.fullName
                
                // Load user avatar into the image view
                self.callerAvatar.sd_setImage(with: URL(string: userObject.avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
            }
        }
    }
    
    //*********************************************** PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
    // Pass info to the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check which segue is used
        if (segue.identifier == "incomingVideoCallToVideoCall") {
            // If the segue will take user to the video view controller,
            // set the chat room name to be the one that the 2 users will be in
            let vc = segue.destination as? VideoViewController
            
            // Set the chat room name in the video view controller to be the one that the 2 users will be in
            vc!.chatRoomName = self.chatRoomName
            
            // Set the call receiver user id in the video view controller to be the caller
            vc!.callReceiverUserId = self.callerUserId
        }
    }
    //*********************************************** END PREPARE INFO FOR THE NEXT VIEW CONTROLLERS ***********************************************
    
    static func endCall() {
        print("Hello")
        
    }
}
