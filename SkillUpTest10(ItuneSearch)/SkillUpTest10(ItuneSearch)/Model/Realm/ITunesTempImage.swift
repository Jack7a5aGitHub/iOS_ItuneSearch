//
//  ITunesTempImage.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/25.
//  Copyright © 2018 Jack. All rights reserved.
//

import Foundation
import RealmSwift

final class ITunesTempImage: Object {
    
    @objc dynamic var resultID = ""
    @objc dynamic var imageData: Data?
    
    override static func primaryKey() -> String? {
        return "resultID"
    }
    
}
