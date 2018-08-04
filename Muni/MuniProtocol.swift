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
{ }
