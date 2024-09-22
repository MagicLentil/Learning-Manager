//
//  DatabaseKey.swift
//  xxxx
//
//  Created by leo on 2021/5/20.
//

import Foundation
import RxSwift
import RxCocoa
import MMKV

// MARK: - DatabaseKey

public final class DatabaseKey<T> {
    public let key: String
    public let tableName: String

    public init(tableName: String, key: String) {
        self.tableName = tableName
        self.key = key
    }

    private var mmapID: String { "\(kMMIDPrefix)_\(tableName)" }

    public var mmkv: MMKV? { MMKV(mmapID: mmapID) }
}

// MARK: - NonnullDatabaseKey

public final class NonnullDatabaseKey<T> {
    public let databaseKey: DatabaseKey<T>
    public let defaultValue: T

    public init(tableName: String, key: String, defaultValue: T) {
        self.defaultValue = defaultValue
        self.databaseKey = DatabaseKey(tableName: tableName, key: key)
    }
}

// MARK: - DatabaseKeyWrapperProtocol

public protocol DatabaseKeyWrapperProtocol: RawRepresentable {
    static var table: String { get }
}

// MARK: - DatabaseKeyWrapperProtocol

@propertyWrapper
public final class DatabaseKeyWrapper<Value> {
    public var wrappedValue: Value {
        get {
            readValue()
        }
        set {
            writeValue(newValue)
            relay?.accept(newValue)
        }
    }

    public lazy var projectedValue: Observable<Value> = {
        relay = BehaviorRelay(value: readValue())
        return relay!.asObservable()
    }()
    private let readValue: () -> Value
    private let writeValue: (Value) -> Void
    private var relay: BehaviorRelay<Value>?

    public init<T: DatabaseKeyWrapperProtocol>(key: T, _ defaultValue: Value) where T.RawValue == String, Value: Codable {
        let valueDAO = DatabaseKey<Value>(tableName: T.table, key: key.rawValue)
        readValue = {
            valueDAO.value ?? defaultValue
        }
        writeValue = {
            valueDAO.value = $0
        }
    }
}
