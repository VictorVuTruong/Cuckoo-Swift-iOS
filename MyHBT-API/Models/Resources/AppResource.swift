//
//  AppResource.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/17/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

class AppResource {
    //let APIURL = "http://127.0.0.1:3000"
    let APIURL = "https://myhbt-api.herokuapp.com"
    
    // The function to generate a random 10 character string
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
