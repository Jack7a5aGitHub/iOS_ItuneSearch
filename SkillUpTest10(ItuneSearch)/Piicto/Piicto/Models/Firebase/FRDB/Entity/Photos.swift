//
//  Photos.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

struct PhotoEntityKey {

    private init() {}

    static let photoID = "photo_id"
    static let photoPath = "photo_path"
    static let heart = "heart"
    static let sender = "sender"
    static let longitude = "longitude"
    static let latitude = "latitude"
}

struct PhotoEntity {

    /// FRDB AutoId
    var photoID = ""
    var photoPath = ""
    var heart = false
    /// 送信者のUUID
    var sender = ""
    /// 送信時の位置情報
    var longitude = Double(0)
    var latitude = Double(0)
}
