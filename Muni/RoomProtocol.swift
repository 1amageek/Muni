//
//  RoomProtocol.swift
//  Muni
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import FirebaseFirestore

public final class Viewer: Object {

}

/**
 Define the properties that the `Room` object should have.
 */
public protocol RoomProtocol: Document {

    associatedtype TranscriptType: Object

    /// Room gets a new message.
    /// This property is not saved to Firestore.
    /// It should not be a property of Dynamic.
    var hasNewMessages: Bool { get set }

    /// It is the display name of the room.
    var name: String? { get set }

    /// It is the thumbnail image of the room.
    var thumbnailImage: File? { get set }

    /// It is a member who can see the conversation.
    var members: [String] { get set }

    /// Holds the ID of the viewer of the most recent message.
    var viewers: NestedCollection<Viewer> { get set }

    /// Record the last time the viewer saw it.
    var lastViewedTimestamps: [String: Timestamp] { get set }

    /// The message most recently spoken is stored.
    var recentTranscript: [String: Any] { get set }

    /// Return the conversation in this room.
    var transcripts: NestedCollection<TranscriptType> { get set }

    /// Returns if message is possible. default true.
    var isMessagingEnabled: Bool { get set }

    /// If it is false, it is not displayed in InBoxViewController.
    var isHidden: Bool { get set }

    /// It keeps the settings for each user.
    /// For example, in case of two people chatting, if you want to show each other's name and thumbnail, set here.
    /// ```
    /// let userConfig: [String: Any] = config[user.id]
    /// let name: String = userConfig[Room.configNameKey]
    /// ```
    var config: [String: Any] { get set }

    /// NameKey used in Config
    static var configNameKey: String? { get }

    /// ThumbnailImageURLKey used in Config
    static var configThumbnailImageURLKey: String? { get }
}

public extension RoomProtocol {

    public static var configNameKey: String? {
        return "name"
    }

    public static var configThumbnailImageURLKey: String? {
        return "thumbnailImageURL"
    }
}
