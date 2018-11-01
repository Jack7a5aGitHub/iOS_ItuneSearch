//
//  ITunesTempImageDao.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/25.
//  Copyright © 2018 Jack. All rights reserved.
//

import RealmSwift

final class ITunesTempImageDao {
    
    static let dao = RealmDaoHelper<ITunesTempImage>()
    // MARK: - find
    
    /// プロフィール画像を取得する
    ///
    /// - Parameter profileId: プロフィールID
    /// - Returns: プロフィール画像の情報
    static func findByID(resultID: String) -> ITunesTempImage? {
        guard let object = dao.findFirst(key: resultID as AnyObject) else { return nil }
        return ITunesTempImage(value: object)
    }
    
    // MARK: - add
    /// プロフィール画像を登録する
    ///
    /// - Parameter model: プロフィール画像の情報
    static func add(model: ITunesTempImage) {
        
        // 登録済みであればreturn
        if let _ = findByID(resultID: model.resultID) { return }
        let newObject = ITunesTempImage()
        newObject.resultID = model.resultID
        newObject.imageData = model.imageData
        dao.add(d: newObject)
        // Databaseの保存Path
        print("Path: \(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
    }
    
    
}
