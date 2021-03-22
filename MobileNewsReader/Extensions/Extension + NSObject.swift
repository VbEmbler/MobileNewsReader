//
//  Extension + NSObject.swift
//  MobileNewsReader
//
//  Created by Vladimir on 16/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation

extension NSObject: NameDescribable {}

protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension NameDescribable {
    var typeName: String {
        String(describing: type(of: self))
    }
    
    static var typeName: String {
        String(describing: self)
    }
}
