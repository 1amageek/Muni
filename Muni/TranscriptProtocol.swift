//
//  TranscriptProtocol.swift
//  Muni
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import FirebaseFirestore

public protocol TranscriptProtocol {

    associatedtype RoomType: Document
    associatedtype UserType: Document

    var to: Relation<RoomType> { get set }
    var from: Relation<UserType> { get set }

    var text: String? { get set }
    var image: File? { get set }
    var video: File? { get set }
    var audio: File? { get set }
    var location: FirebaseFirestore.GeoPoint? { get set }
    var sticker: String? { get set }
    var imageMap: [File] { get set }
}
