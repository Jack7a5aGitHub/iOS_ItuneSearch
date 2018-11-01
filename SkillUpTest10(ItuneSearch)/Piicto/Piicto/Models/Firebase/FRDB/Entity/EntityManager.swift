//
//  EntityManager.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/22.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

final class EntityManager {

    static let shared = EntityManager()

    private init() {}

    deinit {
        users = []
        exchangePhotos = []
        photos = []
    }

    let exchangePhotosDao = ExchangePhotosDao()
    let photosDao = PhotosDao()
    let usersDao = UsersDao()

    var exchangePhotos =  [ExchangePhotoEntity]()
    var partnerIDArray = [String]()
    var photos = [PhotoEntity]()
    var users = [UserEntity]()
}
