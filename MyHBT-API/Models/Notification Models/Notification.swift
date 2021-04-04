//
//  Notification.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 1/1/21.
//  Copyright © 2021 beta. All rights reserved.
//

import Foundation

struct Notification: Codable {
    let _id: String
    let content: String
    let fromUser: String
    let image: String
    let forUser: String
    let orderInCollection: Int
    let postId: String
}
