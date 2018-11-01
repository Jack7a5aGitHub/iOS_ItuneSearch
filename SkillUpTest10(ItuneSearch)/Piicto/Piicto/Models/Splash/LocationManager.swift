//
//  LocationManager.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import CoreLocation
import UIKit

protocol LocationDelegate: class {
    func didUpdateLocations()
}

final class LocationManager: NSObject {

    weak var delegate: LocationDelegate?
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {

    /// 位置情報の許可状態が変更された時に呼ばれる
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {

            /*
             位置情報を使用する許可を得る
             (ステータスがnotDeterminedの場合しかユーザに許可を求めるアラートは表示されない)
             */
        case .notDetermined:
            print("まだ位置情報の利用を許可する確認をしていない")

            // アプリ使用中のみ位置情報の利用を許可する確認を行う
            manager.requestWhenInUseAuthorization()

        case .restricted:
            print("設定/一般/機能制限 で位置情報サービスが制限されている")

        case .denied:
            print("位置情報の設定が「許可しない」になっている")

        case .authorizedAlways:
            print("位置情報の設定が「このAppの使用中のみ許可」になっている")
            // 現在地の更新を開始する
            manager.requestLocation()

        case .authorizedWhenInUse:
            print("位置情報の設定が「常に許可」になっている")
            // 現在地の更新を開始する
            manager.requestLocation()
        }
    }

    /// 位置情報が更新された時の処理
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        print("緯度:\(String(describing: manager.location?.coordinate.latitude))")
        print("経度:\(String(describing: manager.location?.coordinate.longitude))")

        guard
            let newLat = manager.location?.coordinate.latitude,
            let newLon = manager.location?.coordinate.longitude else {
                return
        }

        let latitudeStr = String(round(newLat * 100_000.0) / 100_000.0)
        let longitudeStr = String(round(newLon * 100_000.0) / 100_000.0)

        guard
            let latitude = Double(latitudeStr),
            let longitude = Double(longitudeStr) else {
                return
        }

        // 緯度経度をUserDefaultsに保存
        UserDefaults.standard.set(latitude, forKey: .latitude)
        UserDefaults.standard.set(longitude, forKey: .longitude)

        if AppLaunch.isFirstTime() {
            UsersDao.writeInitialUserData(latitude: latitude, longitude: longitude) { error, _ in
                if let error = error {
                    print("\(error.localizedDescription)")
                    return
                }
                self.delegate?.didUpdateLocations()
            }
        } else {
            guard let uid = UserDefaults.standard.string(forKey: .uid) else {
                return
            }
            UsersDao.userInfo(userID: uid, completionBlock: { userEntity in

                var newUserEntity = userEntity
                newUserEntity.latitude = latitude
                newUserEntity.longitude = longitude
                UsersDao.update(userEntity: newUserEntity, completionBlock: { error, _ in

                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self.delegate?.didUpdateLocations()
                })
            })
        }
    }

    /// 位置情報の取得に失敗した時の処理
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: - 位置情報の取得に失敗した場合の処理を書く
        print("\(error.localizedDescription)")
    }
}
