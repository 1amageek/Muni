//
//  MessageViewViewersCell.swift
//  Muni
//
//  Created by 1amageek on 2018/10/16.
//  Copyright © 2018 1amageek. All rights reserved.
//

import UIKit

open class MessageViewViewersCell: UICollectionViewCell {

    public let imageView: UIImageView = UIImageView(frame: .zero)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        self.imageView.clipsToBounds = true
        self.imageView.backgroundColor = UIColor.lightGray
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.imageView.layer.cornerRadius = self.bounds.width / 2
    }
}
