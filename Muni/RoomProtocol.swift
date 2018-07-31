//
//  RoomProtocol.swift
//  Muni
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import FirebaseFirestore

public protocol RoomProtocol {

    associatedtype Config: RoomConfigProtocol
    var name: String? { get set }
    var profileImage: File? { get set }
    var members: Set<String> { get set }
    var recentTranscript: [String: Any] { get set }
    var config: [String: Any] { get set }
    var configs: NestedCollection<Config> { get set }
}

public protocol RoomConfigProtocol: Document {
    var room: String? { get set }
    var name: String? { get set }
    var profileImage: File? { get set }
}
