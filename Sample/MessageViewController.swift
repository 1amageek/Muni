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

    override var senderID: String? {
        return Auth.auth().currentUser!.uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
}
