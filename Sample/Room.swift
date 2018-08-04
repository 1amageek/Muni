//
//  Room.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring

@objcMembers
class Room: Object, RoomProtocol {
    dynamic var name: String?
    dynamic var thumbnailImage: File?
    dynamic var members: [String] = []
    dynamic var recentTranscript: [String: Any] = [:]
    dynamic var config: [String: Any] = [:]
}
