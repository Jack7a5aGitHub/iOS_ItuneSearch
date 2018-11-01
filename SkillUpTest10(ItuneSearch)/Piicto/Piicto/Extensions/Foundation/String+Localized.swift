//
//  String+Localized.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/14.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

extension String {

    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
