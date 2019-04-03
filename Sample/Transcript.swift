//
//  Transcript.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import FirebaseFirestore

@objcMembers
class Transcript: Object, TranscriptProtocol {

    var to: Relation<Room> = .init()

    var from: Relation<User> = .init()

    dynamic var text: String?

    dynamic var image: File?

    dynamic var video: File?

    dynamic var audio: File?

    dynamic var location: GeoPoint?

    dynamic var sticker: String?

    dynamic var imageMap: [File] = []
}
