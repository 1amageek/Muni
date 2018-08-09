//
//  MessagesTitleView.swift
//  Muni
//
//  Created by 1amageek on 2018/08/06.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

open class MessagesTitleView: UIView {

    @IBOutlet public weak var thumbnailImageView: UIImageView!
    @IBOutlet public weak var nameLabel: UILabel!

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.layer.cornerRadius = 16
        self.thumbnailImageView.image = nil
        self.nameLabel.text = nil
    }
}
