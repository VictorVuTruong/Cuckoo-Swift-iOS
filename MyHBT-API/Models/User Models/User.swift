//
//  User.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/8/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

struct User: Codable {
    let fullName: String
    let _id: String
    let email: String
    let avatarURL: String
    let coverURL: String
}
