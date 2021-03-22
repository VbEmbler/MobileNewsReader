//
//  NewsTableViewCell.swift
//  MobileNewsReader
//
//  Created by Vladimir on 16/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    //MARK: - IB Outlets
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsDescriptionLabel: UILabel!
    @IBOutlet weak var labelsStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Overrides Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        labelsStackView.addBackgroundColorAndBottomCornersRadius()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
    }
}
