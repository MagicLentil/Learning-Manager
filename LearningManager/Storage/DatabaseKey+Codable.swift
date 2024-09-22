//
//  DatabaseTableType+Codable.swift
//  xxxx
//
//  Created by leo on 2021/1/27.
//

import UIKit

// MARK: Single Codable

public extension DatabaseKey where T: Codable {
    var value: T? {
        get {
            return getObject(with: key)
        }
        set {
            setObject(newValue, with: key)
        }
    }

    private func getObject(with key: String) -> T? {
        guard let data = mmkv?.data(forKey: key) else { return nil }
        do {
            let wrapper = try JSONDecoder().decode([T].self, from: data)
            return wrapper.first
        } catch {
            return nil
        }
    }

    private func setObject(_ object: T?, with key: String) {
        guard let object = object else {
            mmkv?.removeValue(forKey: key)
            return
        }

        do {
            let data = try JSONEncoder().encode([object])
            mmkv?.set(data, forKey: key)
        } catch {
            return
        }
    }
}

public extension NonnullDatabaseKey where T: Codable {
    var value: T {
        get { return databaseKey.value ?? defaultValue }
        set { databaseKey.value = newValue }
    }
}

// MARK: Identifiable Codable

public extension DatabaseKey where T: Codable & DatabaseKeyIdentifiable {

    var count: Int {
        guard let keys = mmkv?.allKeys() as? [String] else { return 0 }
        return keys.filter { $0.hasPrefix(key) }.compactMap { $0 }.count
    }

    var allObjects: [T] {
        get {
            guard let mmkv = mmkv else { return [] }
            guard let keys = mmkv.allKeys() as? [String] else { return [] }
            let targetKeys = keys.filter { $0.hasPrefix(key) }.compactMap { $0 }
            return targetKeys
                    .map { mmkv.data(forKey: $0) }
                    .compactMap { $0 }
                    .compactMap { try? JSONDecoder().decode(T.self, from: $0) }
        }
        set {
            deleteAll()
            add(objects: newValue)
        }
    }

    func get(with identity: String) -> T? {
        let key = "\(self.key)_\(identity)"
        guard let data = mmkv?.data(forKey: key) else { return nil }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    func get(with identities: [String]) -> [T] {
        guard let mmkv = mmkv else { return [] }
        let keys = identities.map { "\(key)_\($0)" }
        return keys
                .map { mmkv.data(forKey: $0) }
                .compactMap { $0 }
                .compactMap { try? JSONDecoder().decode(T.self, from: $0) }
    }

    @discardableResult
    func add(object: T) -> Bool {
        let key = "\(self.key)_\(object.identity)"

        do {
            let data = try JSONEncoder().encode(object)
            return mmkv?.set(data, forKey: key) ?? false
        } catch {
            return false
        }
    }

    func add(objects: [T]) {
        objects.forEach {
            add(object: $0)
        }
    }

    @discardableResult
    func delete(object: DatabaseKeyIdentifiable) -> Bool {
        return delete(with: object.identity)
    }

    @discardableResult
    func delete(objects: [DatabaseKeyIdentifiable]) -> Bool {
        return delete(with: objects.map { $0.identity })
    }

    @discardableResult
    func delete(with identities: [String]) -> Bool {
        guard let mmkv = mmkv else { return false }
        let keys = identities.map { "\(key)_\($0)" }
        mmkv.removeValues(forKeys: keys)
        return true
    }

    @discardableResult
    func delete(with identity: String) -> Bool {
        guard let mmkv = mmkv else { return false }
        let targetKey = "\(key)_\(identity)"
        mmkv.removeValue(forKey: targetKey)
        return true
    }

    @discardableResult
    func deleteAll() -> Bool {
        guard let keys = mmkv?.allKeys() as? [String] else { return false }
        let targetKeys = keys.filter { $0.hasPrefix(key) }.compactMap { $0 }
        mmkv?.removeValues(forKeys: targetKeys)
        return true
    }

}

public extension NonnullDatabaseKey where T: Codable & DatabaseKeyIdentifiable {
    var count: Int {
        return databaseKey.count
    }

    var allObjects: [T] {
        get {
            return databaseKey.allObjects
        }
        set {
            databaseKey.allObjects = newValue
        }
    }

    func get(with identity: String) -> T? {
        return databaseKey.get(with: identity)
    }

    @discardableResult
    func add(object: T) -> Bool {
        return databaseKey.add(object: object)
    }

    @discardableResult
    func delete(object: DatabaseKeyIdentifiable) -> Bool {
        return databaseKey.delete(object: object)
    }

    @discardableResult
    func delete(objects: [DatabaseKeyIdentifiable]) -> Bool {
        return databaseKey.delete(objects: objects)
    }

    @discardableResult
    func delete(with identities: [String]) -> Bool {
        return databaseKey.delete(with: identities)
    }

    @discardableResult
    func delete(with identity: String) -> Bool {
        return databaseKey.delete(with: identity)
    }

    @discardableResult
    func deleteAll() -> Bool {
        return databaseKey.deleteAll()
    }
}
