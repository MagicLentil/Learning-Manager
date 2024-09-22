//
//  PlanTable.swift
//  xxxx
//
//  Created by leo on 2022/12/26.
//

import Foundation

final class PlanTable: DatabaseTableType {

    static let tableName = "PlanTable"
    static let shared = PlanTable()

    private init() {
        setup()
    }
    
    var tableName: String { Self.tableName }
    enum RawKey: String {
        case placeholder
    }

    enum Keys: String, DatabaseKeyWrapperProtocol {
        static var table: String { PlanTable.tableName }
        case lessonInfo
    }
    
    @DatabaseKeyWrapper(key: Keys.lessonInfo, [])
    var lessons: [Lesson]
}
