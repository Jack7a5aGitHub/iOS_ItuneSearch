//
//  ITunesSearchDaoTest.swift
//  SkillUpTest10(ItuneSearch)Tests
//
//  Created by Jack Wong on 2018/04/14.
//  Copyright © 2018 Jack. All rights reserved.
//

@testable import SkillUpTest10_ItuneSearch_
import XCTest

final class ITunesSearchDaoTests: XCTestCase {
    
    /// Check return api data from Dao and dummy data
    func testITunesSearchDao() {
        
        let api = ITunesSearchDao()
        var myStr = ""
        api.test()
        let itunesResult = DummyResponse.ItunesResults()
        let result = DummyResponse.SearchResults(results: [itunesResult])
        
        XCTAssertEqual(result.resultCount, 50)
        XCTAssertEqual(result.results[0].artistName, "Nishino kana")
        XCTAssertEqual(result.results[0].artworkUrl100, "http://is2.mzstatic.com/image/thumb/Music/v4/7d/26/43/7d2643d8-e66f-7bb0-0e76-26b36531753f/source/100x100bb.jpg")
        XCTAssertEqual(result.results[0].trackId, 123456789)
        XCTAssertEqual(result.results[0].trackName, "BaBaPu")
    }
}
