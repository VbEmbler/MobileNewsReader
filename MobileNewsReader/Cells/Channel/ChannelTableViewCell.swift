//
//  ChannelTableViewCell.swift
//  MobileNewsReader
//
//  Created by Vladimir on 16/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    //MARK: - IB outlets
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelDescriptionLabel: UILabel!
    @IBOutlet weak var favouriteImageView: UIImageView!
    
    //MARK: - Overrides Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}
