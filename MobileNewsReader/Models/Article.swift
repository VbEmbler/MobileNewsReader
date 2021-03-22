//
//  Article.swift
//  MobileNewsReader
//
//  Created by Vladimir on 17/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation

struct Articles: Codable {
    let status: String?
    let totalResults: Int?
    var articles: [Article]
}

struct Article: Codable {
    let source: ArticleSource?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    var fromSearch: Bool?
    var imageData: Data?
}

struct ArticleSource: Codable {
    let id: String?
    let name: String?
}
