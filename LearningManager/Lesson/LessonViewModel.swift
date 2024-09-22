//
//  LessonViewModel.swift
//  LearningManager
//
//  Created by leo on 2024/9/16.
//

import Foundation

struct Lesson: Codable {
    let lessonName: String
    var subTasks: [SubTaskInfo] = []
    var desc = ""
    private var _selected: Bool = false
    var level: TaskLevel = .p0
    var timStamp: TimeInterval = 0
    var selected: Bool {
        get {
            return subTasks.allSatisfy { $0.selected == true }
        }
        set {
            // 更新所有子任务的选中状态
            for index in subTasks.indices {
                subTasks[index].selected = newValue
            }
            // 更新私有存储属性
            _selected = newValue
        }
    }
    
    var progress: String {
        let selectedCount = subTasks.filter { $0.selected  == true }.count
        let progressValue =  subTasks.isEmpty ? 0.0 : Double(selectedCount) / Double(subTasks.count)
        let percentage = progressValue * 100
        return String(format: "%.0f%%", percentage) // 格式化为整数百分比
    }
    
    init(lessonName: String, subTasks: [SubTaskInfo], desc: String = "", selected: Bool = false) {
        self.lessonName = lessonName
        self.subTasks = subTasks
        self._selected = selected
    }
}


enum TaskLevel: String, Codable {
    case p0
    case p1
    case p2
}

struct SubTaskInfo: Codable {
    let taskName: String
    var desc: String = ""
    var level: TaskLevel = .p0
    var selected: Bool = false
    var started: Bool = false
    var totalTime: Double = 0
    var timStamp: TimeInterval = 0
}

final class LessonViewModel {
    var lessons: [Lesson] = PlanTable.shared.lessons
    
    func add(lesson: Lesson) {
        lessons.append(lesson)
        PlanTable.shared.lessons = lessons
        print(PlanTable.shared.lessons)
    }
    
    func add(task: SubTaskInfo, section: Int) {
        lessons[section].subTasks.append(task)
        PlanTable.shared.lessons = lessons
        print(PlanTable.shared.lessons)
    }
    
    
    func deleteItem(indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        // 检查 section 是否在范围内
        guard section < lessons.count else {
            print("Section out of range")
            return
        }
        
        if row == 0 {
            // 删除整个 A 结构体
            lessons.remove(at: section)
        } else {
            // 检查 row 是否在范围内
            guard row - 1 < lessons[section].subTasks.count else {
                return
            }
            // 删除 A 中的 B 元素
            lessons[section].subTasks.remove(at: row - 1)
        }
        PlanTable.shared.lessons = lessons
        print(PlanTable.shared.lessons)
    }
}
