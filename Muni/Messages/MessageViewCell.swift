//
//  MessageViewCell.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

open class MessageViewCell: UICollectionViewCell {

    open private(set) var cacheSize: CGSize?

    open func resetCacheSize() {
        self.cacheSize = nil
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.cacheSize = nil
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        if let size: CGSize = self.cacheSize {
            return size
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
        var size: CGSize = UIScreen.main.bounds.size
        size.height = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        self.cacheSize = size
        return size
    }
}
