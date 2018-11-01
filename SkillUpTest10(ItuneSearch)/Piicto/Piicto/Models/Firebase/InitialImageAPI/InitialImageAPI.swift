//
//  InitialImageAPI.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/28.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation
import ObjectMapper

/// APIステータス
///
/// - loading: ロード中
/// - loaded: ロード完了
/// - offline: オフライン
/// - error: エラー
enum InitialImageAPIStatus {
    case loadingThen
    case loadedThen(response: InitialImageAPIResponse)
    case offlineThen
    case errorThen
}

/// APIの結果を通知するプロトコル
protocol InitialImageLoadable: class {
    func apiStatus(status: InitialImageAPIStatus)
}

final class InitialImageAPI {

    weak var loadable: InitialImageLoadable?

    private var isLoading = false

    func post(photoID: String, latitude: Double, longitude: Double) {

        // 通信状況判定
        if !APIClient.isReachable() {
            // ステータスに「オフライン」を設定
            loadable?.apiStatus(status: .offlineThen)
            return
        }

        // ステータスに「ロード中」を設定
        loadable?.apiStatus(status: .loadingThen)

        guard let uid = UserDefaults.standard.string(forKey: .uid) else {
            return
        }

        let parameters = InitialImageAPIParamsBuilder.build(senderID: uid,
                                                            photoID: photoID,
                                                            latitude: latitude,
                                                            longitude: longitude)
        let router = Router.initialImageAPI(parameters)
        APIClient.request(router: router) { [weak self] response in

            switch response {
            case .success(let result):

                if let response = Mapper<InitialImageAPIResponse>().map(JSONObject: result) {
                    // ステータスに「ロード完了」を設定
                    self?.loadable?.apiStatus(status: .loadedThen(response: response))
                }

            case .failure(let error):

                print("error_code: \((error as NSError).code)")
                print("error_description: \((error as NSError).description)")

                // ステータスに「エラー」を設定
                self?.loadable?.apiStatus(status: .errorThen)
            }
        }
    }
}
