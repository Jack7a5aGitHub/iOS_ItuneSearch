//
//  ResultCellTests.swift
//  SkillUpTest10(ItuneSearch)Tests
//
//  Created by Jack Wong on 2018/04/14.
//  Copyright © 2018 Jack. All rights reserved.
//

@testable import SkillUpTest10_ItuneSearch_
import XCTest

final class ResultCellTests: XCTestCase {
    
    let dataSource = FakeDataSource()
    var tableView: UITableView!
    var cell: ITunesSearchTableViewCell!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "ITunesSearch", bundle: nil)
        guard let itunesVC = storyboard.instantiateViewController(
            withIdentifier: "itunesVC") as? ITunesViewController else {
                XCTFail("ITunesViewControllerのインスタンス生成失敗")
                return
        }
        itunesVC.loadView()
        
        tableView = itunesVC.resultTableView
        tableView.dataSource = dataSource
        
        cell = tableView?.dequeueReusableCell(withIdentifier: "searchCell",
                                              for: IndexPath(row: 0, section: 0)) as! ITunesSearchTableViewCell
    }
    
    // ResultCell上のラベルの文言を確認するテスト
    
    func testSetResult() {
        let result =  DummyResponse.ItunesResults()
       
        cell.trackNameLabel.text = result.artistName
        
        XCTAssertEqual(cell.trackNameLabel.text, "Nishino kana")
        
    }
}

extension ResultCellTests {
    
    final class FakeDataSource: NSObject, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
    }
}
