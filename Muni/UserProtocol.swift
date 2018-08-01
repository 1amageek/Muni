//
//  UserProtocol.swift
//  Muni
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import FirebaseFirestore

/**
 Define the properties that the `User` object should have.
 */
public protocol UserProtocol {

    /// The display name of the user. The display name is used by InboxViewController and MessagesViewController.
    var name: String? { get set }

    /// thumbnail image.
    /// size 64x64@3x
    var thumbnailImage: File? { get set }
}
