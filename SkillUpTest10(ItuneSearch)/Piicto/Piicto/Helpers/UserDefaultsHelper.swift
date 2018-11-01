//
//  UserDefaultsHelper.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Foundation

protocol KeyNamespaceable {
    func namespaced<T: RawRepresentable>(_ key: T) -> String
}

extension KeyNamespaceable {

    func namespaced<T: RawRepresentable>(_ key: T) -> String {
        return "\(Self.self).\(key.rawValue)"
    }
}

// MARK: - StringDefaultSettable

protocol StringDefaultSettable: KeyNamespaceable {
    associatedtype StringKey: RawRepresentable
}

extension StringDefaultSettable where StringKey.RawValue == String {

    func set(_ value: String, forKey key: StringKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }

    @discardableResult
    func string(forKey key: StringKey) -> String? {
        let key = namespaced(key)
        return UserDefaults.standard.string(forKey: key)
    }
}

extension UserDefaults: StringDefaultSettable {

    enum StringKey: String {
        
        case uid
    }
}

// MARK: - BoolDefaultSettable

protocol BoolDefaultSettable: KeyNamespaceable {
    associatedtype BoolKey: RawRepresentable
}

extension BoolDefaultSettable where BoolKey.RawValue == String {

    func set(_ value: Bool, forKey key: BoolKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }

    @discardableResult
    func bool(forKey key: BoolKey) -> Bool? {
        let key = namespaced(key)
        return UserDefaults.standard.bool(forKey: key)
    }
}

extension UserDefaults: BoolDefaultSettable {

    enum BoolKey: String {

        case completedFirstLaunch
    }
}

// MARK: - DoubleDefaultSettable

protocol DoubleDefaultSettable: KeyNamespaceable {
    associatedtype DoubleKey: RawRepresentable
}

extension DoubleDefaultSettable where DoubleKey.RawValue == String {
    
    func set(_ value: Double, forKey key: DoubleKey) {
        let key = namespaced(key)
        UserDefaults.standard.set(value, forKey: key)
    }
    
    @discardableResult
    func double(forKey key: DoubleKey) -> Double? {
        let key = namespaced(key)
        return UserDefaults.standard.double(forKey: key)
    }
}

extension UserDefaults: DoubleDefaultSettable {

    enum DoubleKey: String {

        case latitude

        case longitude
    }
}
