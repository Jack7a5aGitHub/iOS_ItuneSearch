//
//  RealmImageTests.swift
//  SkillUpTest10(ItuneSearch)Tests
//
//  Created by Jack Wong on 2018/04/14.
//  Copyright © 2018 Jack. All rights reserved.
//

@testable import SkillUpTest10_ItuneSearch_
import XCTest

final class RealmImageTests: XCTestCase {
    
    // 初期化のテスト
    // To Ensure set nil for image data and no result id at the beginning
    func testInit() {
        let itunesTempImage = ITunesTempImage()
        
        // Verify
        XCTAssertEqual(itunesTempImage.resultID, "")
        XCTAssertEqual(itunesTempImage.imageData, nil)
    }
    
    // プライマリキーを確認するテスト
    //check the setting of realm primary 
    func testPrimaryKey() {
        // Verify
        XCTAssertEqual(ITunesTempImage.primaryKey(), "resultID")
    }
}
