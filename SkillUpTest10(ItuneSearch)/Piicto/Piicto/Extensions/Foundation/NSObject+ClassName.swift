//
//  NSObject+ClassName.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/07.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

extension NSObject {

    /// クラス名を取得する
    static var className: String {
        return String(describing: self)
    }
}
