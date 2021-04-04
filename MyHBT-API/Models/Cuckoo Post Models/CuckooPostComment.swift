//
//  HBTGramPostComment.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 10/5/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

struct CuckooPostComment: Decodable {
    let _id: String
    let writer: String
    let content: String
    let postId: String
    let orderInCollection: Int
}
