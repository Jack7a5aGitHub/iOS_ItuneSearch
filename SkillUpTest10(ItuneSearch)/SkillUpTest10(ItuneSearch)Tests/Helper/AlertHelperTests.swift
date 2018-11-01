//
//  AlertHelperTests.swift
//  SkillUpTest10(ItuneSearch)Tests
//
//  Created by Jack Wong on 2018/04/14.
//  Copyright © 2018 Jack. All rights reserved.
//

@testable import SkillUpTest10_ItuneSearch_
import XCTest

class AlertHelperTests: XCTestCase {
    // Test func we use in project whether or not return what we expect
    
    // ボタン1つのアラートを生成する処理をテスト
    func testBuildSingleButtonAlert() {
        
        let alert = AlertHelper.buildAlert(message: "メッセージ")
        // 左ものと右ものが一致するか確認
        XCTAssertEqual(alert.title, "")
        XCTAssertEqual(alert.message, "メッセージ")
        XCTAssertEqual(alert.actions.count, 1)
        XCTAssertEqual(alert.actions.first?.title, "OK")
        XCTAssertEqual(alert.actions.first?.style, .default)
    }
    
    // ボタン2つのアラートを生成する処理をテスト
    func testBuildAlert() {
        
        let alert = AlertHelper.buildAlert(title: "タイトル",
                                           message: "メッセージ",
                                           rightButtonTitle: "OK",
                                           leftButtonTitle: "Cancel",
                                           rightButtonAction: nil,
                                           leftButtonAction: nil)
        XCTAssertEqual(alert.title, "タイトル")
        XCTAssertEqual(alert.message, "メッセージ")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "OK")
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }
    
}
