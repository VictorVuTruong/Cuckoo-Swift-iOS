//
//  HBTGramPostPhotoLabel.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/25/20.
//  Copyright © 2020 beta. All rights reserved.
//

import Foundation

struct CuckooPostPhotoLabel: Decodable {
    let _id: String
    let imageID: String
    let imageLabel: String
    let orderInCollection: Int
}
