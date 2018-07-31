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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.balloonView.layer.cornerRadius = 16
    }
}
