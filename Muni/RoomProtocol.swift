//
//  RoomProtocol.swift
//  Muni
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import FirebaseFirestore

/**
 Define the properties that the `Room` object should have.
 */
public protocol RoomProtocol {

    associatedtype TranscriptType: Object

    /// It is the display name of the room.
    var name: String? { get set }

    /// It is the thumbnail image of the room.
    var thumbnailImage: File? { get set }

    /// It is a member who can see the conversation.
    var members: [String] { get set }

    /// Holds the ID of the viewer of the most recent message.
    var viewers: [String] { get set }

    /// The message most recently spoken is stored.
    var recentTranscript: [String: Any] { get set }

    var transcripts: NestedCollection<TranscriptType> { get set }

    /// It keeps the settings for each user.
    /// For example, in case of two people chatting, if you want to show each other's name and thumbnail, set here.
    /// ```
    /// let userConfig: [String: Any] = config[user.id]
    /// let name: String = userConfig[MuniRoomConfigNameKey]
    /// ```
    var config: [String: Any] { get set }
}

public let MuniRoomRecentTranscriptTextKey: String = "text"

public let MuniRoomConfigNameKey: String = "name"

public let MuniRoomConfigThumbnailImageKey: String = "thumbnailImage"
