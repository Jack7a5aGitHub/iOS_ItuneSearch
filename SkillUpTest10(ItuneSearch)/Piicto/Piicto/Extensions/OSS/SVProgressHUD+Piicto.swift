//
//  SVProgressHUD+Piicto.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/23.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import SVProgressHUD

public extension SVProgressHUD {

    /// ユーザー操作に関する状態
    enum ManipulationType {
        /// ユーザー操作可能
        case permit
        /// ユーザー操作禁止
        case prohibited
    }

    /// 独自メソッド定義（独自メソッドはPiicto経由で使う）
    enum Piicto {

        /// マスクのタイプを指定してインジケータを表示する
        /// - デフォルトはユーザー操作禁止・文言なし
        ///
        /// - Parameter manipulationType: ユーザー操作に関する状態 (default: .prohibited)
        /// - Parameter message: インジケータに表示する文字列 (default: nil)
        static func show(manipulationType: ManipulationType = .prohibited,
                         message: String? = nil) {

            switch manipulationType {
            case .permit:
                SVProgressHUD.setDefaultMaskType(.none)
            case .prohibited:
                SVProgressHUD.setDefaultMaskType(.black)
            }

            if let message = message {
                SVProgressHUD.show(withStatus: message)
            } else {
                SVProgressHUD.show()
            }
        }
    }
}
