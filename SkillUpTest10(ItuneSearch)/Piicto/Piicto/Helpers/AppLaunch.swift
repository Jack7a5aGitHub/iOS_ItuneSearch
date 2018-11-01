//
//  AppLaunch.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/06.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

final class AppLaunch: NSObject {

    /// アプリ初回起動済みの状態を保存する
    static func completedFirstLaunch() {
        UserDefaults().set(true, forKey: .completedFirstLaunch)
    }

    /// アプリ初回起動かどうか判定する
    ///
    /// - Returns: true: 初回起動, false: 非初回起動
    static func isFirstTime() -> Bool {
        guard let completedFirstLaunch = UserDefaults().bool(forKey: .completedFirstLaunch) else {
            return true
        }
        return !completedFirstLaunch
    }
}
