//
//  MessageViewController.swift
//  Sample
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit
import FirebaseAuth
import Toolbar

class MessageViewController: Muni<User, Room, RoomConfig, Transcript>.MessagesViewController {

    var sendBarItem: ToolbarItem!

    override var senderID: String? {
        return Auth.auth().currentUser!.uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendBarItem = ToolbarItem(title: "Send", target: self, action: #selector(send))
    }
}
