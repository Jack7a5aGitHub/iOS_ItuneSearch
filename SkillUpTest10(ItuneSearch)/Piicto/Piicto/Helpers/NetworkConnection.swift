//
//  NetworkConnection.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/14.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation
import Reachability

final class NetworkConnection {
    
    /// ネットワーク接続状況確認
    ///
    /// - Returns: true: オンライン, false: オフライン
    static func isConnectable() -> Bool {

        guard let reachability = Reachability() else {
            return false
        }

        let connection = reachability.connection
        if connection != .none {
            return true
        }
        return false
    }
}
