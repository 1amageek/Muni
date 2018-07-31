//
//  InboxViewCell.swift
//  Muni
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

class InboxViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.layer.cornerRadius = 32
        self.nameLabel.text = nil
        self.messageLabel.text = nil
        self.dateLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnailImageView.image = nil
        self.nameLabel.text = nil
        self.messageLabel.text = nil
        self.dateLabel.text = nil
    }
}
