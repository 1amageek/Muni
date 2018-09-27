//
//  InboxViewCell.swift
//  Muni
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

open class InboxViewCell: UITableViewCell {

    public enum Format {
        case normal
        case bold
    }

    open var format: Format = .normal {
        didSet {
            switch format {
            case .normal:
                self.messageLabel.font = UIFont.systemFont(ofSize: 14)
                self.messageLabel.textColor = UIColor.darkGray
            case .bold:
                self.messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
                self.messageLabel.textColor = UIColor.darkText
            }
            self.setNeedsLayout()
        }
    }
    
    @IBOutlet open weak var thumbnailImageView: UIImageView!
    @IBOutlet open weak var nameLabel: UILabel!
    @IBOutlet open weak var messageLabel: UILabel!
    @IBOutlet open weak var dateLabel: UILabel!

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.layer.cornerRadius = 32
        self.nameLabel.text = nil
        self.messageLabel.text = nil
        self.dateLabel.text = nil
    }

   open override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnailImageView.image = nil
        self.nameLabel.text = nil
        self.messageLabel.text = nil
        self.dateLabel.text = nil
        self.format = .normal
    }
}
