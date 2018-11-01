//
//  ExchangePhotos.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

/// 1枚目 -> サーバがFRDB更新
///
/// 2枚目以降 -> 送信者側はクライアント、受信者側はサーバがFRDB更新
struct ExchangePhotoEntity {

    var partnerID = ""
    var photo = Photo()

    init(partnerID: String, photo: Photo) {
        self.partnerID = partnerID
        self.photo = photo
    }

    init() {
        partnerID = ""
        photo = Photo()
    }
}

struct Photo {
    var photoID = ""
    var visible = false

    init(photoID: String, visible: Bool) {
        self.photoID = photoID
        self.visible = visible
    }

    init() {
        self.photoID = ""
        self.visible = false
    }
}

// photoIDを指定して、Photosから情報を取得する。
// visibleがtrueの写真だけCollectionViewに表示する
//// Photos.senderが自分である場合は、ハートをdisableにする
