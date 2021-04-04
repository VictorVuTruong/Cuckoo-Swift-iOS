//
//  CreateAccountViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 9/18/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    // First, middle, last name of the user from the previous view controller
    var userFirstName = ""
    var userMiddleName = ""
    var userLastName = ""
    
    // Class code of the user from previous view controller
    var userClassCode = ""
    
    // User id of the user from previpus view controller
    var userId = ""
    
    // User role from the previous view controller
    var userRole = ""
    
    // Sign up token from the previous view controller
    var signUpToken = ""
    
    // Text field where user can enter first name
    @IBOutlet weak var firstNameField: UITextField!
    
    // Text field where user can enter middle name
    @IBOutlet weak var middleNameField: UITextField!
    
    // Text field where user can enter last name
    @IBOutlet weak var lastNameField: UITextField!
    
    // Text field where user can enter the email
    @IBOutlet weak var emailTextField: UITextField!
    
    // Text field where user can enter the password
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Text field where user can confirm the password
    @IBOutlet weak var reEnterPasswordTextField: UITextField!
    
    // The object to perform API operations
    let apiOperations = APIOperations()
    
    // Authentication repository
    let authenticationRepository = AuthenticationRepository()
    
    // The finish button
    @IBAction func finishButton(_ sender: UIButton) {
        // Call the function to start the sign up procedure
        signUp(firstName: firstNameField.text!, middleName: middleNameField.text!, lastName: lastNameField.text!, email: emailTextField.text!, role: userRole, password: passwordTextField.text!, rePassword: reEnterPasswordTextField.text!, classCode: userClassCode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Let the password fields be secure input
        passwordTextField.isSecureTextEntry = true
        reEnterPasswordTextField.isSecureTextEntry = true
    }
    
    // The function to perform sign up procedure
    func signUp(firstName: String, middleName: String, lastName: String, email: String, role: String, password: String, rePassword: String, classCode: String) {
        // Call the function to sign user up
        authenticationRepository.signUp(firstName: firstName, middleName: middleName, lastName: lastName, email: email, role: role, password: password, rePassword: rePassword, classCode: classCode) { isDone in
            // Check the done status
            if (isDone) {
                // Perform segue and go to the next view controller
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "signUpToDoneSignUp", sender: self)
                }
            } else {
                // Show the alert
                DispatchQueue.main.async {
                    self.showAlert(title: "Sign up failed", message: "Something is not right while signing you up")
                }
            }
        }
    }
    
    // The function to show alert
    func showAlert(title: String, message: String) {
        // Create the alert object with the specified title and message
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        // Add the button to the alert which will dismiss the alert when clicked
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
