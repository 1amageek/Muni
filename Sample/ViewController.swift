//
//  ViewController.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBAction func addRoom(_ sender: Any) {

        guard let user: FirebaseAuth.User = Auth.auth().currentUser else { return }

        guard let userID: String = textField.text else { return }

        let room: Room = Room()
        room.members.insert(userID)
        room.members.insert(user.uid)

        do {
            let config: RoomConfig = RoomConfig(id: userID)
            config.name = user.uid
            room.configs.insert(config)
        }

        do {
            let config: RoomConfig = RoomConfig(id: user.uid)
            config.name = userID
            room.configs.insert(config)
        }

        room.save { [weak self] (_, _) in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
