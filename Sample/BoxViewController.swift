//
//  BoxViewController.swift
//  Sample
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit
import Muni
import Pring
import FirebaseAuth
import Muni

class BoxViewController: Muni<User, Room, Transcript>.InboxViewController {

    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Room", style: .done, target: self, action: #selector(addRoom))
    }

    @objc func addRoom() {
        let storyboard: UIStoryboard = UIStoryboard(name: "ViewController", bundle: nil)
        let viewController: ViewController = storyboard.instantiateInitialViewController() as! ViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    override func messageViewController(with room: Room) -> Muni<User, Room, Transcript>.MessagesViewController {
        return MessageViewController(roomID: room.id)
    }
}
