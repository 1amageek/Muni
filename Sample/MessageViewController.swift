//
//  MessageViewController.swift
//  Sample
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Toolbar
import Instantiate
import InstantiateStandard

class MessageViewController: Muni<User, Room, Transcript>.MessagesViewController {

    var sendBarItem: ToolbarItem!

    override var targetSection: Int {
        return 1
    }

    override var senderID: String? {
        return Auth.auth().currentUser!.uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        self.collectionView.registerNib(type: HeaderCell.self)
        self.sendBarItem = ToolbarItem(title: "Send", target: self, action: #selector(send))
        self.toolBar.setItems([ToolbarItem(customView: self.textView), self.sendBarItem], animated: false)
        self.listen()
    }

    override func transcript(_ transcript: Transcript, willSendTo room: Room) {
        guard let text: String = self.textView.text else { return }
        if text.isEmpty { return }
        transcript.text = text
        self.textView.text = nil
    }

    override func transcript(_ transcript: Transcript, didSend reference: DocumentReference?, error: Error?) {
        UIView.animate(withDuration: 0.3) {
            self.textViewDidChange(self.textView)
            self.textView.layoutIfNeeded()
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1:
            return self.dataSource.count
        default: return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 1:
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        default:
            return HeaderCell.dequeue(from: collectionView, for: indexPath)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            let cell: HeaderCell = HeaderCell.instantiate()
            var size: CGSize = cell.sizeThatFits(.zero)
            size.width = UIScreen.main.bounds.width
            return size
        case 1:
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        default: return .zero
        }
    }
}
