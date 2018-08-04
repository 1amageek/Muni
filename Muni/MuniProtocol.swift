//
//  MuniProtocol.swift
//  Muni
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import FirebaseFirestore
import FirebaseStorage

/**
 Muni is the core class of chat function.

 In order to use the chat function, it is necessary to conform to the protocol of
 User Protocol, Room Protocol, Transcript Protocol.
 */
public class Muni<
    UserType: UserProtocol,
    RoomType: RoomProtocol & Object,
    TranscriptType: TranscriptProtocol & Object
    >: NSObject where UserType == TranscriptType.UserType, RoomType == TranscriptType.RoomType
{

    public class func createRoom(userIDs: [String], name: String? = nil, thumanailImage: File? = nil, confg: [String: Any] = [:], block: ((DocumentReference?, Error?) -> Void)? = nil) -> [String: StorageUploadTask] {
        let room: Room = Room()
        room.members = userIDs
        room.name = name
        room.config = confg
        room.thumbnailImage = thumanailImage
        return room.save(block)
    }
}
