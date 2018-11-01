//
//  String+Path.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/26.
//  Copyright © 2018 Jack. All rights reserved.
//

import Foundation

extension String {
    
    private var nsString: NSString {
        return (self as NSString)
    }
    
    func appendingPathComponent(_ str: String) -> String {
        return nsString.appendingPathComponent(str)
    }
}
