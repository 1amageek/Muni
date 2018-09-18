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
import Muni

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
        self.sendBarItem = ToolbarItem(title: "Send", target: self, action: #selector(send))
        self.toolBar.setItems([ToolbarItem(customView: self.textView), self.sendBarItem], animated: false)
        self.listen()
    }

    override func transcript(willSend transcript: Transcript) -> Bool {
        guard let text: String = self.textView.text else { return false }
        if text.isEmpty { return false }
        transcript.text = text
        self.textView.text = nil
        return true
    }

    override func transcript(didSend transcript: Transcript, reference: DocumentReference?, error: Error?) {
        print(reference?.path)
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
            let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.backgroundView?.backgroundColor = UIColor.green
            return cell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 1:
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        default:
            return CGSize(width: UIScreen.main.bounds.size.width, height: 100)
        }
    }
}
