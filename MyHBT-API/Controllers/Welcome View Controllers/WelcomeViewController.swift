//
//  WelcomeViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 9/18/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    // The login button
    @IBAction func loginButton(_ sender: UIButton) {
        // Perform segue and take user to the view controller where the user can login
        performSegue(withIdentifier: "welcomeToLogin", sender: self)
    }
    
    // The sign up button
    @IBAction func signUpButton(_ sender: UIButton) {
        // Perform segue and take user to the view controller where the user can sign up
        performSegue(withIdentifier: "welcomeToSignUp", sender: self)
    }
    
    // Authentication repository
    let authenticationRepository = AuthenticationRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Hide the back button
        navigationItem.hidesBackButton = true
        
        // Call the function to start with validating the login token
        validateLoginToken()
    }

    // The function to validate login token to see if it is still valid or not
    func validateLoginToken() {
        // Call the function to validate log in token
        authenticationRepository.validateLoginToken() { isValid in
            DispatchQueue.main.async {
                // If token is still valid, perform segue and take user to the main view controller (dashboard view controller)
                self.performSegue(withIdentifier: "welcomeToMainMenu", sender: self)
            }
        }
    }
}
