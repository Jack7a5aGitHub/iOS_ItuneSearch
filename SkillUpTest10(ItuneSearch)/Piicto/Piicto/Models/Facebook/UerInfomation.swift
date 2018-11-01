//
//  UerInfomation.swift
//  Piicto
//
//  Created by kawaharadai on 2018/01/26.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

struct Person {
    
    var userId: String?
    var name: String?
    var email: String?
    var gender: String?
    var birthday: String?
    var profilePic: String?
    var photos: DataList?
    
    init(userId: String?,
         name: String?,
         email: String?,
         gender: String?,
         birthday: String?,
         profilePic: String?,
         photos: DataList?) {
        
        self.userId = userId
        self.name = name
        self.email = email
        self.gender = gender
        self.birthday = birthday
        self.profilePic = profilePic
        self.photos = photos
    }
}

struct DataList {
    
    var dataList = [ImageData?]()
    
    init(dataList: [ImageData?]) {
        self.dataList = dataList
    }
}

struct ImageData {
    var imageId: String?
    var link: String?
    
    init(imageId: String?, link: String?) {
        self.imageId = imageId
        self.link = link
    }
}
