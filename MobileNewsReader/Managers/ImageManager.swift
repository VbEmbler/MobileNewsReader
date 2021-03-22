//
//  ImageManager.swift
//  MobileNewsReader
//
//  Created by Vladimir on 19/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation

class ImageManager {
    //MARK: - Public Properties
    static let shared = ImageManager()
    
    //MARK: - Initializers
    private init() {}
    
    //Public Methods
    func fetchImage(from url: String?) -> Data? {
        guard let stringURL = url else { return nil }
        guard let imageURL = URL(string: stringURL) else { return nil }
        return try? Data(contentsOf: imageURL)
    }
}
