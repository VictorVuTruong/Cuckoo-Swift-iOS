//
//  MenuViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/17/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

enum MenuType: Int {
    case overview
    case firstcategory
    case dashboard
    case chat
    case create
    case profile
    case explore
    case notification
    case signout
    case secondcategory
    case findfriends
    case personalprofilepage
    case userstats
    case thirdcategory
    case locations
    case blank
    case close
}

class MenuViewController: UITableViewController {
    // The URL to get info of the currently logged in user
    let getCurrentUserInfoURL = URL(string: "\(AppResource.init().APIURL)/api/v1/users/getUserInfoBasedOnToken")
    
    // The view which will take up the whole screen
    var transparentView = UIView ()
    
    // Avatar of the currently logged in user
    @IBOutlet weak var userAvatar: UIImageView!
    
    // Full name of the currently logged in user
    @IBOutlet weak var userFullName: UILabel!
    
    var didTapMenuType: ((MenuType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the function to make the avatar look round
        AdditionalFunctions.init().makeRounded(image: userAvatar)
    
        // Call the function to load full name and avatar for the currently logged in user
        getInfoOfCurrentUser()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else {
            return
        }
        
        dismiss(animated: true) {[weak self] in
            print("Dismissing")
            self?.didTapMenuType?(menuType)
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
                        let firstName = dataFetched["firstName"] as! String
                        let middleName = dataFetched["middleName"] as! String
                        let lastName = dataFetched["lastName"] as! String
                        // Combine them all to get the full name
                        let fullName = "\(lastName) \(middleName) \(firstName)"
                        
                        // Get avatar URL of the user
                        let avatarURL = dataFetched["avatarURL"] as! String
                        
                        DispatchQueue.main.async {
                            // Set full name to the label
                            self.userFullName.text = fullName
                            
                            // Load avatar into the ImageView for the user
                            self.userAvatar.sd_setImage(with: URL(string: avatarURL), placeholderImage: UIImage(named: "placeholder.jpg"))
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
}
