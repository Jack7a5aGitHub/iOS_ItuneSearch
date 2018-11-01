//
//  String+Localized.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/26.
//  Copyright © 2018 Jack. All rights reserved.
//

import Foundation

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
