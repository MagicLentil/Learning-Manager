//
//  DatabaseTableType.swift
//  xxxx
//
//  Created by leo on 2021/1/27.
//

import Foundation
import RxSwift
import RxCocoa
import MMKV

let kMMIDPrefix = "Learning_Manager"

// MARK: - DatabaseKeyIdentifiable

public protocol DatabaseKeyIdentifiable {
    var identity: String { get }
}

// MARK: - DatabaseTableType

public protocol DatabaseTableType: AnyObject {
    associatedtype RawKey: RawRepresentable where RawKey.RawValue == String

    var tableName: String { get }
}

public extension DatabaseTableType {
    func setup() {
    }
}

public extension DatabaseTableType {
    private var mmapID: String { "\(kMMIDPrefix)_\(tableName)" }

    private var mmkv: MMKV? { MMKV(mmapID: mmapID) }

    func clear() {
        mmkv?.clearAll()
    }

    func removeAll(prefix: RawKey) {
        removeAll(prefix: prefix.rawValue)
    }

    func removeAll(prefix: String) {
        guard let mmkv = mmkv else { return }
        guard let keys = mmkv.allKeys() as? [String] else { return }
        let targetKeys = keys.filter { $0.hasPrefix(prefix) }.compactMap { $0 }
        targetKeys.forEach { mmkv.removeValue(forKey: $0) }
    }

    func removeAll(suffix: RawKey) {
        removeAll(suffix: suffix.rawValue)
    }

    func removeAll(suffix: String) {
        guard let mmkv = mmkv else { return }
        guard let keys = mmkv.allKeys() as? [String] else { return }
        let targetKeys = keys.filter { $0.hasSuffix(suffix) }.compactMap { $0 }
        targetKeys.forEach { mmkv.removeValue(forKey: $0) }
    }
}

public extension DatabaseTableType {
    func createKey<T>(key: RawKey) -> DatabaseKey<T> {
        return createKey(key: key.rawValue)
    }

    func createKey<T>(key: String) -> DatabaseKey<T> {
        return .init(tableName: tableName, key: key)
    }

    func createKey<T>(key: RawKey, defaultValue: T) -> NonnullDatabaseKey<T> {
        return createKey(key: key.rawValue, defaultValue: defaultValue)
    }

    func createKey<T>(key: String, defaultValue: T) -> NonnullDatabaseKey<T> {
        return .init(tableName: tableName, key: key, defaultValue: defaultValue)
    }
}
