//
//  MessagesView.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

open class MessagesView: UICollectionView {

    internal var safeAreaTopInset: CGFloat {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets.top
        } else {
            return 0
        }
    }

    internal var safeAreaBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets.bottom
        } else {
            return 0
        }
    }

    open var visibleRectHeight: CGFloat {
        return self.bounds.height - self.contentInset.top - self.contentInset.bottom - safeAreaBottomInset
    }

    open func scrollToBottom(animated: Bool = false) {
        let collectionViewContentHeight: CGFloat = collectionViewLayout.collectionViewContentSize.height
        let visibleRectHeight: CGFloat = self.visibleRectHeight
        if collectionViewContentHeight > visibleRectHeight {
            let offsetY: CGFloat = collectionViewContentHeight - visibleRectHeight
            self.performBatchUpdates(nil) { _ in
                self.setContentOffset(CGPoint(x: 0, y: offsetY), animated: animated)
            }
        }
    }
}
