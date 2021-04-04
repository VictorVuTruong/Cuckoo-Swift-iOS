//
//  LocationPageViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/28/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class LocationPageViewController: UITableViewController {
    // The view which wrap around the see friends location button
    @IBOutlet weak var seeFriendsLocationView: UIView!
    
    // The view which wrap around the update location button
    @IBOutlet weak var updateLocationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create tap gesture recognizer which will take user to the view controller where the user can see friends location
        let tapGestureSeeFriendsLocation = UITapGestureRecognizer(target: self, action: #selector(viewTappedSeeFriendsLocation(gesture:)))
        
        // Create tap gesture recognizer which will take user to the view controller where the user can update location
        let tapGestureUpdateLocation = UITapGestureRecognizer(target: self, action: #selector(viewTappedUpdateLocation(gesture:)))
        
        // Add tap gesture to the view
        seeFriendsLocationView.addGestureRecognizer(tapGestureSeeFriendsLocation)
        updateLocationView.addGestureRecognizer(tapGestureUpdateLocation)
    }
    
    //***************************************** VIEW TAPPED FUNCTIONS *****************************************
    // The function which will take user to the view controller where the user can see friends location
    @objc func viewTappedSeeFriendsLocation(gesture: UIGestureRecognizer) {
        if (gesture.view) != nil {
            // Perform the segue and take user to the view controller where the user can see friends location
            performSegue(withIdentifier: "locationPageToSeeFriendsLocation", sender: self)
        }
    }
    
    // The function which will take user to the view controller where the user can update location
    @objc func viewTappedUpdateLocation(gesture: UIGestureRecognizer) {
        if (gesture.view) != nil {
            // Perform the segue and take user to the view controller where the user can update location
            performSegue(withIdentifier: "locationPageToUpdateLocation", sender: self)
        }
    }
    //***************************************** END VIEW TAPPED FUNCTIONS *****************************************
}
