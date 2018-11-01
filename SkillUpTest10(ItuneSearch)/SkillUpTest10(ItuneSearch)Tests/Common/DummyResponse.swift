//
//  DummyResponse.swift
//  SkillUpTest10(ItuneSearch)Tests
//
//  Created by Jack Wong on 2018/04/14.
//  Copyright © 2018 Jack. All rights reserved.
//

import Foundation

final class DummyResponse {
    
    // Searchした後、取得APIのDummy Response
    
    struct SearchResults: Codable {
        
        let resultCount = 50
        let results : [ItunesResults]
        
    }
    
    struct ItunesResults: Codable {
        
        let artistName = "Nishino kana"
        let artworkUrl100 = "http://is2.mzstatic.com/image/thumb/Music/v4/7d/26/43/7d2643d8-e66f-7bb0-0e76-26b36531753f/source/100x100bb.jpg"
        let trackName = "BaBaPu"
        let trackId = 123456789
    }
  
}

