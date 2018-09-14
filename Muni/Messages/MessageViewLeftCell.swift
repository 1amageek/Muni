//
//  MessageViewLeftCell.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

open class MessageViewLeftCell: MessageViewCell {
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var textLabel: UILabel!
    @IBOutlet public weak var thumbnailImageView: UIImageView!
    @IBOutlet public weak var balloonView: UIView!
    @IBOutlet public weak var dateLabel: UILabel!

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.layer.cornerRadius = 12
        self.balloonView.layer.cornerRadius = 16
        self.titleLabel.text = nil
        self.textLabel.text = nil
        self.dateLabel.text = nil
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.textLabel.text = nil
        self.dateLabel.text = nil
    }
}
