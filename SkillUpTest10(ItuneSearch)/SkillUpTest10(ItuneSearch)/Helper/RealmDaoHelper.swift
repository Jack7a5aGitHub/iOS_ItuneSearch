//
//  RealmDaoHelper.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/25.
//  Copyright © 2018 Jack. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmDaoHelperProtocol {
    associatedtype T: RealmSwift.Object
    
    var realm: Realm {get set}
    
    /// 新規主キー発行
    func newId() -> Int?
    
    /// レコードを追加
    func add(d :T)
    
    /// 全件取得
    func findAll() -> Results<T>
    
    /// 1件目のみ取得
    func findFirst() -> T?
    
    /// 指定キーのレコードを取得
    func findFirst(key: AnyObject) -> T?
    
    /// 最後のレコードを取得
    func findLast() -> T?
    
    /// レコードを更新する
    ///
    /// T: RealmSwift.Object で primaryKey()が実装されている時のみ有効
    func update(d: T, block:(() -> Void)?) -> Bool
    
    /// レコード削除
    func delete(d: T)
    
    /// レコード全削除
    func deleteAll()
}

final class RealmDaoHelper <T: RealmSwift.Object>: RealmDaoHelperProtocol {
    
    var realm: Realm
    
    init() {
        do {
            if BuildTargetChecker.isTesting() {
                // XCTest実行の場合はUT用のConfigurationを設定
                realm = try Realm(configuration: UTRealm.makeRealmConfig())
            } else {
                realm = try Realm()
            }
        } catch let error {
            print(error.localizedDescription)
            fatalError("RealmDaoHelper initialize error.")
        }
    }
    
    // MARK: - newId
    
    func newId() -> Int? {
        guard let key = T.primaryKey() else {
            //primaryKey未設定
            return nil
        }
        return (realm.objects(T.self).max(ofProperty: key) as Int? ?? 0) + 1
    }
    
    // MARK: - add
    
    func add(d :T) {
        do {
            try realm.write {
                realm.add(d)
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    // MARK: - find
    
    func findAll() -> Results<T> {
        return realm.objects(T.self)
    }
    
    func findFirst() -> T? {
        return findAll().first
    }
    
    func findFirst(key: AnyObject) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: key)
    }
    
    func findLast() -> T? {
        return findAll().last
    }
    
    // MARK: - update
    
    func update(d: T, block:(() -> Void)? = nil) -> Bool {
        do {
            try realm.write {
                block?()
                realm.add(d, update: true)
            }
            return true
        } catch let error {
            print("\(error.localizedDescription)")
        }
        return false
    }
    
    // MARK: - delete
    
    func delete(d: T) {
        do {
            try realm.write {
                realm.delete(d)
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    func deleteAll() {
        let objs = realm.objects(T.self)
        do {
            try realm.write {
                realm.delete(objs)
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}

