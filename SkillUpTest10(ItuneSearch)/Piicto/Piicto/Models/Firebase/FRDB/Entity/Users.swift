//
//  Users.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

struct UserEntityKey {

    private init() {}

    static let userID = "user_id"
    static let name = "name"
    static let profileImgURL = "profile_img_url"
    static let longitude = "longitude"
    static let latitude = "latitude"
    static let totalHeart = "total_heart"
    static let facebookID = "facebook_id"
    static let instagramID = "instagram_id"
    static let token = "token"
}

struct UserEntity {

    /// user.uid
    var userID = ""
    /// User name of SNS. (FaceBook, Instagram)
    var name = ""
    /// SNS profile image path.
    var profileImgURL = ""
    var longitude = Double(0)
    var latitude = Double(0)
    var totalHeart = 0
    var facebookID = 0
    var instagramID = 0
    var token = ""
}

// 自分のUserIDを指定して、totalHeartを取得する -> ok
// FaceBookの認証が通ったら、name, profileImgURL, facebookIDを更新する
// Instagramの認証が通ったら、name, profileImgURL, instagramIDを更新する
// 写真をスワイプしたら、longitude, latitudeを更新する
