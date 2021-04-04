//
//  HBTGramPostPhoto.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/15/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

struct CuckooPostPhoto: Codable {
    let _id: String
    let postId: String
    let imageURL: String
    let orderInCollection: Int
}
