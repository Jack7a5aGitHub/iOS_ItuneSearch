//
//  InitialImageAPIParamsBuilder.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/28.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

final class InitialImageAPIParamsBuilder {

    /// リクエストパラメータを生成する
    ///
    /// - Parameters:
    ///   - sender_id: 送信者ID
    ///   - photo_id: 送信画像のID
    ///   - latitude: 送信目標の緯度 小数点以下5桁 ex. 35.46675
    ///   - longitude: 送信目標の経度 小数点以下5桁 ex. 135.45671
    /// - Returns: Dictionary
    static func build(senderID: String, photoID: String, latitude: Double, longitude: Double) -> [String: Any] {

        return [
            "sender_id": senderID,
            "photo_id": photoID,
            "latitude": String(format: "%.5f", latitude),
            "longitude": String(format: "%.5f", longitude)
        ]
    }
}
