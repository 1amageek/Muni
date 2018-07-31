//
//  MuniProtocol.swift
//  Muni
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import FirebaseFirestore

public class Muni<UserType: UserProtocol, RoomType: RoomProtocol & Object, RoomConfigType: RoomConfigProtocol, TranscriptType: TranscriptProtocol & Object>: NSObject where
    UserType == TranscriptType.UserType, RoomType == TranscriptType.RoomType, RoomConfigType == RoomType.Config
{
    
}



//public protocol UserProtocol {
//    var name: String? { get set }
//    var thumbnailURL: URL? { get set }
//}
//
//public protocol RoomProtocol {
//    var recentTranscript: [String: Any] { get set }
//    var members: Set<String> { get set }
//}
//
//public protocol TranscriptProtocol {
//
//    associatedtype RoomType: Document
//    associatedtype UserType: Document
//
//    var to: Relation<RoomType> { get set }
//    var from: Relation<UserType> { get set }
//
//    var text: String? { get set }
//    var image: File? { get set }
//    var video: File? { get set }
//    var audio: File? { get set }
//    var location: FirebaseFirestore.GeoPoint? { get set }
//    var sticker: String? { get set }
//    var imageMap: [File] { get set }
//}
