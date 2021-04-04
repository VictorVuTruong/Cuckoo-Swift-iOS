//
//  UserCommentInteraction.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/22/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

struct UserCommentInteraction: Codable {
    let _id: String
    let user: String
    let commentedBy: String
    let numOfComments: Int
}
