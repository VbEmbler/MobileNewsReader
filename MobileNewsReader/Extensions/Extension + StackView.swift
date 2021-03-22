//
//  Extension + StackView.swift
//  MobileNewsReader
//
//  Created by Vladimir on 22/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

extension UIStackView {
    func addBackgroundColorAndBottomCornersRadius() {
        let subView = UIView(frame: bounds)
        subView.layer.cornerRadius = 20
        subView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        subView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
