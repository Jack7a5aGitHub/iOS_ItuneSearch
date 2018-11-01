//
//  InstagramAPIResponse.swift
//  Piicto
//
//  Created by kawaharadai on 2018/02/01.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import ObjectMapper

struct InstagramUserDataResponse: Mappable {
    
    var userID = ""
    var userName = ""
    var profilePicture = ""
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        userID <- map["data.id"]
        userName <- map["data.username"]
        profilePicture <- map["data.profile_picture"]
    }
}

struct InstagramUserPhotosResponse: Mappable {
    
    var userPhotoData: [Images] = []
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        userPhotoData <- map["data"]
    }
}

struct Images: Mappable {
    
    var imageURLString = ""
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        imageURLString <- map["images.standard_resolution.url"]
    }
}
