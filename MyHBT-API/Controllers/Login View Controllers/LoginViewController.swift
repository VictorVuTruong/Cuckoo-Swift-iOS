//
//  LoginViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 9/18/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    // Instance of the FirebaseAuth
    let mAuth = Auth.auth()
    
    // The URL to log the user in using POST method
    let loginURL = URL(string: "\(AppResource.init().APIURL)/api/v1/users/login")

    // Authentication repository
    let authenticationRepository = AuthenticationRepository()
    
    // The email text field
    @IBOutlet weak var emailTextField: UITextField!
    
    // The password text field
    @IBOutlet weak var passwordTextField: UITextField!
    
    // The login button
    @IBAction func loginButton(_ sender: UIButton) {
        // Call the function to perform login procedure
        login(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate the fields so that it will push keyboard away when done
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        // Let the password text field be secure input
        passwordTextField.isSecureTextEntry = true
    }
    
    // The function to perform the login task
    func login(email: String, password: String) {
        // Call the function to start signing user in
        authenticationRepository.login(email: email, password: password) { (isDone) in
            if (isDone) {
                // Sign in with Firebase
                self.authenticationRepository.signInWithFirebase { (isDone) in
                    // Take user to the main view controller (dashboard view controller)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "loginToMainMenu", sender: self)
                    }
                }
            } else {
                // Let the user know that login was not successful
                DispatchQueue.main.async {
                    self.showAlert(title: "Login failed", message: "Email or password may not right")
                }
            }
        }
    }
    
    // The function to show alert m
    func showAlert(title: String, message: String) {
        // Create the alert object with the specified title and message
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // Add the button to the alert which will dismiss the alert when clicked
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
