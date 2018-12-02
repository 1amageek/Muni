//
//  HeaderCell.swift
//  Sample
//
//  Created by 1amageek on 2018/10/04.
//  Copyright © 2018 1amageek. All rights reserved.
//

import UIKit
import Instantiate
import InstantiateStandard

class HeaderCell: MessageViewCell, NibType, Reusable, NibInstantiatable {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cellBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        cellBackgroundView.clipsToBounds = false
        cellBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cellBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cellBackgroundView.layer.shadowRadius = 8
        cellBackgroundView.layer.shadowOpacity = 0.24
    }
}
