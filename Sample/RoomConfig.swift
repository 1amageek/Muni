//
//  RoomConfig.swift
//  Sample
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import Muni

@objcMembers
class RoomConfig: Object, RoomConfigProtocol {
    dynamic var room: String?
    dynamic var name: String?
    dynamic var profileImage: File?
}
