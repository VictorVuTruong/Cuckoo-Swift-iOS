//
//  AuthenticationRepository.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 3/14/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation
import Firebase

class AuthenticationRepository {
    // The object to perform API operation
    let apiOperations = APIOperations()
    
    // Instance of the Firebase Auth
    let mAuth = Auth.auth()
    
    // The function to sign up a user
    func signUp(firstName: String, middleName: String, lastName: String, email: String, role: String, password: String, rePassword: String, classCode: String, completion: @escaping (Bool) -> ()) {
        // Call the function to perform POST operation
        apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/users/signup", body: [
            "firstName": firstName,
            "middleName": middleName,
            "lastName": lastName,
            "email": email,
            "role": "user",
            "password": password,
            "passwordConfirm": rePassword,
            "avatarURL": "avatar",
            "coverURL": "cover"
        ]) { (responseData) in
            // Check status of the response. If it is nil, it means that sign up is not done correctly
            let status = responseData["status"]
            
            if (status == nil) {
                // Let the view know that sign up is not successful via callback function
                completion(false)
            } // Otherwise, it seems to be done
            else {
                // Let the view know that sign up is done via callback function
                completion(true)
            }
        }
    }
    
    // The function to log a user in
    func login(email: String, password: String, completion: @escaping (Bool) -> ()) {
        // Call the function to perform POST operation
        apiOperations.performPOSTRequestWithBody(url: "\(AppResource.init().APIURL)/api/v1/users/login", body: [
            "email": email,
            "password": password
        ]) { (responseData) in
            // Check status of the response. If it is nil, it means that user may entered the wrong credentials
            let status = responseData["status"]
            
            if (status == nil) {
                // Let the view know that login is not successful via callback function
                completion(false)
            } // Otherwise, it seems to be done
            else {
                // Let the view know that login is done via callback function
                completion(true)
            }
        }
    }
    
    // The function to validate login token to see if it is still valid or not
    func validateLoginToken(completion: @escaping (Bool) -> ()) {
        // Call the function to perform POST operation
        apiOperations.performPOSTRequest(url: "\(AppResource.init().APIURL)/api/v1/users/validateLoginToken") { (responseData) in
            // Let the view know that token is still valid via callback function
            completion(true)
        }
    }
    
    // The function to sign user in with Firebase in order to grant access to the storage
    func signInWithFirebase(completion: @escaping (Bool) -> ()) {
        mAuth.signIn(withEmail: "allowedusers@email.com", password: "AllowedUser") { authResult, error in
            // Report the error if any
            if let error = error {
                print("There seem to be an error \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
