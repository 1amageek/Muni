//
//  MessagesView.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

public class MessagesView: UICollectionView {

    internal var safeAreaBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets.bottom
        } else {
            return 0
        }
    }

    public func scrollToBottom(animated: Bool = false) {
        let collectionViewContentHeight: CGFloat = collectionViewLayout.collectionViewContentSize.height
        let visibleRectHeight: CGFloat = (self.bounds.height - self.contentInset.top - self.contentInset.bottom - safeAreaBottomInset)
        if collectionViewContentHeight > visibleRectHeight {
            let offsetY: CGFloat = collectionViewContentHeight - visibleRectHeight
            self.performBatchUpdates(nil) { _ in
                self.setContentOffset(CGPoint(x: 0, y: offsetY), animated: animated)
            }
        }
    }
}
