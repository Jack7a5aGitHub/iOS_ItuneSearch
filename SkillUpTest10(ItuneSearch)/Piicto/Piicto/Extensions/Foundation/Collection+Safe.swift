//
//  Collection+Safe.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/22.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
