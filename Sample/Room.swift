//
//  Room.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import Firebase

@objcMembers
class Room: Object, RoomProtocol {

    typealias TranscriptType = Transcript

    var hasNewMessages: Bool = false

    dynamic var name: String?
    dynamic var thumbnailImage: File?
    dynamic var members: [String] = []
    dynamic var recentTranscript: [String: Any] = [:]
    var viewers: NestedCollection<Viewer> = []
    var transcripts: NestedCollection<TranscriptType> = []
    dynamic var config: [String: Any] = [:]
    dynamic var isMessagingEnabled: Bool = true
    dynamic var isHidden: Bool = false
    dynamic var lastViewedTimestamps: [String : Timestamp] = [:]
}
