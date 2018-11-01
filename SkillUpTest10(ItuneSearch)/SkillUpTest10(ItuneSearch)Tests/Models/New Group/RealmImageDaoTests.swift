//
//  RealmImageDaoTests.swift
//  SkillUpTest10(ItuneSearch)Tests
//
//  Created by Jack Wong on 2018/04/14.
//  Copyright © 2018 Jack. All rights reserved.
//

@testable import SkillUpTest10_ItuneSearch_
import XCTest

final class RealmImageDaoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UTRealm.removeUTDirectory()
    }
    
    override func tearDown() {
        UTRealm.removeUTDirectory()
        super.tearDown()
    }
    
    // add dummy data and find it
    
    func testAddAndFind() {
        ITunesTempImageDao.add(model: dummyModel())
        let addedModel = ITunesTempImageDao.findByID(resultID: "240558470661799936")
        
        XCTAssertNotNil(addedModel)
        XCTAssertEqual(addedModel?.resultID, "240558470661799936")
        XCTAssertEqual(addedModel?.imageData, Data())
    
    }
    
    // MARK: - private
    
    // Song Icon Imageのダミー
    private func dummyModel() -> ITunesTempImage {
        let model = ITunesTempImage()
        model.resultID = "240558470661799936"
        model.imageData = Data()
        
        return model
    }
    
}
