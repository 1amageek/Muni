//
//  UserProtocol.swift
//  Muni
//
//  Created by 1amageek on 2018/07/31.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import Pring
import FirebaseFirestore

public protocol UserProtocol {
    var name: String? { get set }
    var thumbnailURL: URL? { get set }
}
