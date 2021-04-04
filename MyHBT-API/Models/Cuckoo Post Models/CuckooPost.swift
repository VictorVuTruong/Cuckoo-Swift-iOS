//
//  HBTGramPost.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/4/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

struct CuckooPost: Codable {
    let content: String
    let writer: String
    let _id: String
    let numOfImages: Int
    let orderInCollection: Int
    let dateCreated: String
}
