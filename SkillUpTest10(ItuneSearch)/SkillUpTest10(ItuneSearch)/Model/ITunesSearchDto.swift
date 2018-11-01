//
//  ITunesSearchDto.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/18.
//  Copyright © 2018 Jack. All rights reserved.
//

import UIKit

struct SearchResults: Codable {
    
    let resultCount : Int?
    let results : [ItunesResults]
    
}
struct ItunesResults: Codable {
    
    let artistName : String?
    let artworkUrl100 : String?
    let trackName : String?
    let trackId: Int?
}

struct TestDummy: Codable {
    let email : String
    let return_code : Int
    let message: String
}

struct DumDum: Codable {
    let message : String
}
