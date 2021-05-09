//
//  APIOperations.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 3/1/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

class APIOperations {
    // The function to perform GET request
    func performGETRequest(url: String, completion: @escaping (NSDictionary) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // The URL to perform GET request
            let getURL = URL(string: url)
            
            // Create the request
            var getRequest = URLRequest(url: getURL!)
            
            // Let the method to be GET
            getRequest.httpMethod = "GET"
            
            // Get task
            let getTask = URLSession.shared.dataTask(with: getRequest) { (data, response, error) in
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
                            // Return the response data via callback function
                            completion(convertedJSONIntoDict)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
            
            // Resume the task
            getTask.resume()
        }
    }
    
    // The function to perform POST request
    func performPOSTRequest(url: String, completion: @escaping (NSDictionary) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // The URL to perform POST request
            let postURL = URL(string: url)
            
            // Create the request
            var postRequest = URLRequest(url: postURL!)
            
            // Let the method to get first image of the post be GET
            postRequest.httpMethod = "POST"
            
            // Post task
            let postTask = URLSession.shared.dataTask(with: postRequest) { (data, response, error) in
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
                            // Return the response data via callback function
                            completion(convertedJSONIntoDict)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
            
            // Resume the task
            postTask.resume()
        }
    }
    
    // The function to perform POST request with request body
    func performPOSTRequestWithBody(url: String, body: [String: Any], completion: @escaping (NSDictionary) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // The URL to perform POST request
            let postURL = URL(string: url)
            
            // Create the request
            var postRequest = URLRequest(url: postURL!)
            
            // Let the method for updating user info to be POST
            postRequest.httpMethod = "POST"
            postRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // Set body content for the request
            postRequest.httpBody = body.percentEncoded()
            
            // Perform the request and update user info
            let postTask = URLSession.shared.dataTask(with: postRequest) { (data, response, error) in
                // Check for error
                if let error = error {
                    // Report the error
                    print("There seem to be an error \(error)")

                    // Get out of the function
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    if (response.statusCode >= 400) {
                        completion([:])
                    } else {
                        // Get data from the response
                        if let data = data {
                            // Convert the JSON data string into the NSDictionary
                            do {
                                if let convertedJSONIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as?
                                    NSDictionary {
                                    // Return the response data via callback function
                                    completion(convertedJSONIntoDict)
                                }
                            } catch let error as NSError {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            
            // Resume the task
            postTask.resume()
        }
    }
    
    // The function to perform PATCH request
    func performPATCHRequest(url: String, body: [String: Any], completion: @escaping (NSDictionary) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // The URL to perform PATCH request
            let patchURL = URL(string: url)
            
            // Create the request
            var patchRequest = URLRequest(url: patchURL!)
            
            // Let the method for updating user info to be POST
            patchRequest.httpMethod = "PATCH"
            patchRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // Set body content for the request
            patchRequest.httpBody = body.percentEncoded()
            
            // Perform the PATCH request
            let patchTask = URLSession.shared.dataTask(with: patchRequest) { (data, response, error) in
                // Check for error
                if let error = error {
                    // Report the error
                    print("There seem to be an error \(error)")

                    // Get out of the function
                    return
                }
                
                // Get data from the response
                if let data = data {
                    // Convert the JSON data string into the NSDictionary
                    do {
                        if let convertedJSONIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as?
                            NSDictionary {
                            // Return the response data via callback function
                            completion(convertedJSONIntoDict)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
            
            // Resume the task
            patchTask.resume()
        }
    }
    
    // The function to perform DELETE request
    func performDELETERequest(url: String, completion: @escaping (Bool) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            // The URL to perform the DELETE operation
            let deleteURL = URL(string: url)
            
            // Create request
            var deleteRequest = URLRequest(url: deleteURL!)
            
            // Let the method to be DELETE
            deleteRequest.httpMethod = "DELETE"
            
            // Delete task
            let deleteTask = URLSession.shared.dataTask(with: deleteRequest) { (data, response, error) in
                // Check for error
                if let error = error {
                    // Report the error
                    print("There seem to be an error \(error)")
                }
                
                if let response = response as? HTTPURLResponse {
                    // Read the response
                    // If the code is 200, show alert to the user and let user know that delete was a success
                    if (response.statusCode == 200 || response.statusCode == 204) {
                        // Let the view controller know that delete was a success via callback function
                        completion(true)
                    }
                }
            }
            
            // Resume the task
            deleteTask.resume()
        }
    }
}
