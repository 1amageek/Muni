//
//  MessagesTitleView.swift
//  Muni
//
//  Created by 1amageek on 2018/08/06.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

class MessagesTitleView: UIView {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.layer.cornerRadius = 16
        self.thumbnailImageView.image = nil
        self.nameLabel.text = nil
    }
}
