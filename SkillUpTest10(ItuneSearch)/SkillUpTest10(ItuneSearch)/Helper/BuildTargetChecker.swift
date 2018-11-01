//
//  BuildTargetChecker.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/25.
//  Copyright © 2018 Jack. All rights reserved.
//

import Foundation

final class BuildTargetChecker {
    
    /// XCTest実行中かどうかチェックする
    ///
    /// - Returns: true: XCTest実行中, false: XCTest実行中でない
    static func isTesting() -> Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
