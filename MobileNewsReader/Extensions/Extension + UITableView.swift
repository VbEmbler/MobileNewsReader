//
//  Extension + UITableView.swift
//  MobileNewsReader
//
//  Created by Vladimir on 16/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

extension UITableView {
    func registerNib(with type: NameDescribable.Type) {
        self.register(UINib(nibName: type.typeName, bundle: nil),
                      forCellReuseIdentifier: type.typeName)
    }
    
    func registerHeaderFooterNib(with type: NameDescribable.Type) {
        self.register(UINib(nibName: type.typeName, bundle: nil),
                      forHeaderFooterViewReuseIdentifier: type.typeName)
    }
    
    func dequeueReusableCell<T: NameDescribable>(with type: T.Type) -> T {
        self.dequeueReusableCell(withIdentifier: type.typeName) as! T
    }
    
    func dequeueReusableHeaderFooterView<T: NameDescribable>(with type: T.Type) -> T {
        self.dequeueReusableHeaderFooterView(withIdentifier: type.typeName) as! T
    }
}
