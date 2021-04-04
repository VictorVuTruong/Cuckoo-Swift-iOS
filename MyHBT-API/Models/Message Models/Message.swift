//
//  Message.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/29/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

struct Message: Decodable {
    let sender: String
    let receiver: String
    let content: String
    let _id: String
}
