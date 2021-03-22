//
//  Source.swift
//  MobileNewsReader
//
//  Created by Vladimir on 17/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation

struct Sources: Codable {
    let status: String?
    var sources: [Source]
}

struct Source: Codable {
    let id: String?
    let name: String?
    let description: String?
    let url: String?
    let category: String?
    let language: String?
    let country: String?
    var favourite: Bool?
}
