//
//  MessageViewLeftCell.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit

open class MessageViewLeftCell: MessageViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var textLabel: UILabel!
    @IBOutlet public weak var thumbnailImageView: UIImageView!
    @IBOutlet public weak var balloonView: UIView!
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    public var viewers: [String] = [] {
        didSet {
            self.collectionView.isHidden = viewers.count == 0
            self.collectionView.reloadData()
            self.setNeedsLayout()
        }
    }

    private let viewersCellSize: CGSize = CGSize(width: 14, height: 14)
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbnailImageView.layer.cornerRadius = 12
        self.balloonView.layer.cornerRadius = 16
        self.titleLabel.text = nil
        self.textLabel.text = nil
        self.dateLabel.text = nil
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(MessageViewViewersCell.self, forCellWithReuseIdentifier: "MessageViewViewersCell")
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.textLabel.text = nil
        self.dateLabel.text = nil
        self.collectionView.isHidden = true
        self.viewers = []
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewers.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MessageViewViewersCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageViewViewersCell", for: indexPath) as! MessageViewViewersCell
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.viewersCellSize
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        let count: CGFloat = CGFloat(self.viewers.count)
//        let leftInset: CGFloat = UIScreen.main.bounds.width - (viewersCellSize.width * count) - (2 * max((count - 1), 0)) - 8
//        return UIEdgeInsets(top: 2, left: leftInset, bottom: 2, right: 8)
//    }


}
