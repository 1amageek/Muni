//
//  MessageViewRightCell.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

class MessageViewRightCell: MessageViewCell {
    
    @IBOutlet weak var balloonView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.balloonView.layer.cornerRadius = 16
        self.textLabel.text = nil
        self.dateLabel.text = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.textLabel.text = nil
        self.dateLabel.text = nil
    }
}
