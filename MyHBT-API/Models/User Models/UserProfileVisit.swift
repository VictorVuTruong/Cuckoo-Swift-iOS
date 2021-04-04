//
//  UserProfileVisit.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/22/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

struct UserProfileVisit: Codable {
    let _id: String
    let user: String
    let visitedBy: String
    let numOfVisits: Int
}
