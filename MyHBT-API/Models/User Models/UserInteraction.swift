//
//  UserInteraction.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/22/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

struct UserInteraction : Codable {
    let _id: String
    let user: String
    let interactWith: String
    let interactionFrequency: Int
}
