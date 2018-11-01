//
//  Date+ToStr.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/26.
//  Copyright © 2018 Jack. All rights reserved.
//

import Foundation

extension Date {
    
    /// Date型をString型に変更する
    func toStr(dateFormat: String) -> String  {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale?
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: self)
    }
}
