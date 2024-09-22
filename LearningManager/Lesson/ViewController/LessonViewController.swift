//
//  LessonViewController.swift
//  LearningManager
//
//  Created by leo on 2024/9/15.
//

import UIKit
import RxSwift
import SnapKit

class LessonViewController: PLBaseViewController {
    
    private let vm = LessonViewModel()
    
    private var isEditLesson: Bool = true
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.adaptToIOS11()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "全部"
        view.backgroundColor = .white
        setupSubviews()
        addHandleEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.vm.lessons = PlanTable.shared.lessons
    }
    
    private func setupSubviews() {
        headerView.setRightButton(with: "完成", target: self, action: #selector(finishInserItem))
        headerView.rightButton.setTitleColor( UIColor.pl_title, for: .normal)
        headerView.rightButton.setTitleColor( UIColor.pl_title, for: .highlighted)
        headerView.rightButton.isHidden = true
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func addHandleEvent() {
        
    }
    
    @objc func finishInserItem() {
        self.contentView.endEditing(true)
        let userInfo: [String: Any] = ["isEditLesson": self.isEditLesson]

        NotificationCenter.default.post(
            name: addItemEditNotiFication,
            object: nil,
            userInfo: userInfo
        )
        headerView.rightButton.isHidden = true
    }
}

extension LessonViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.lessons.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (vm.lessons.count == 0 || section == vm.lessons.count) {
            return 1
        }
        return vm.lessons[section].subTasks.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == vm.lessons.count {
            // 添加课程
            let identifier = LessonItemAddCell.identifier
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LessonItemAddCell
            if cell == nil {
                cell = LessonItemAddCell(style: .subtitle, reuseIdentifier: identifier)
            }
            cell?.didTapAddAction = { [weak self] in
                guard let self = self else { return }
                self.startEditLessonItem()
                self.isEditLesson = true
            }
            
            cell?.itemAddCellTextViewFinishedAction = { [weak self] (isTask, text) in
                guard let self = self else { return }
                if (isTask ==  false) {
                    self.vm.add(lesson: Lesson(lessonName: text, subTasks: []))
                }
                
                self.contentView.endEditing(true)
                self.tableView.reloadData()
            }
            cell?.delegate = self
            return cell!
        } else {
            if indexPath.row == 0 {
                // 课程
                let identifier = LessonItemCell.identifier
                var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LessonItemCell
                if cell == nil {
                    cell = LessonItemCell(style: .subtitle, reuseIdentifier: identifier)
                }
                cell?.didTapCheckBox = { [weak self] isSelected in
                    guard let self = self else { return }
                    self.vm.lessons[indexPath.section].selected = isSelected
                    self.tableView.reloadData()
                }
                let model = vm.lessons[indexPath.section]
                cell?.bindData(with: model)
                return cell!
            } else {
                // 添加里程碑
                if indexPath.row == vm.lessons[indexPath.section].subTasks.count + 1 {
                    let identifier = SubTaskItemAddCell.subIdentifier
                    var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? LessonItemAddCell
                    if cell == nil {
                        cell = SubTaskItemAddCell(style: .subtitle, reuseIdentifier: identifier)
                    }
                    cell?.didTapAddAction = { [weak self] in
                        guard let self = self else { return }
                        self.startEditTaskItem()
                        self.headerView.rightButton.isHidden = true
                        self.isEditLesson = false
                    }
                    cell?.delegate = self
                    cell?.itemAddCellTextViewFinishedAction = { [weak self] (isTask, text) in
                        guard let self = self else { return }
                        if isTask == true {
                            self.vm.add(task: SubTaskInfo(taskName: text, selected: false), section: indexPath.section)
                        }
                        self.contentView.endEditing(true)
                        self.tableView.reloadData()
                    }
                    return cell!
                } else {
                    // 里程碑
                    let identifier = SubLessonItemCell.subIdentifier
                    var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SubLessonItemCell
                    if cell == nil {
                        cell = SubLessonItemCell(style: .subtitle, reuseIdentifier: identifier)
                    }
                    cell?.didTapCheckBox = { [weak self] isSelected in
                        guard let self = self else { return }
                        self.vm.lessons[indexPath.section].subTasks[indexPath.row - 1].selected = isSelected
                        self.tableView.reloadData()
                    }
                    let model = vm.lessons[indexPath.section].subTasks[indexPath.row - 1]
                    cell?.bindData(with: model)
                    return cell!
                }
            }
        }
    }
    
    func startEditLessonItem() {

    }
    
    func startEditTaskItem() {
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // 高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}

extension LessonViewController: LessonItemAddCellDelegate {
    func lessonItemAddCellDelegateTextViewStarted() {
        self.headerView.rightButton.isHidden = false
    }
}

// 左滑删除
extension LessonViewController {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAtIndexPath indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print(indexPath)
        if indexPath.section == vm.lessons.count || indexPath.row == vm.lessons[indexPath.section].subTasks.count + 1 {
            return nil
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { (action, view, completionHandler) in
            // 从数据源中删除数据
            self.vm.deleteItem(indexPath: indexPath)
            // 从表视图中删除行
            if indexPath.row == 0 {
                tableView.deleteSections(IndexSet([indexPath.section]), with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            completionHandler(true)
            print(self.vm.lessons)
        }
        
        let detailAction = UIContextualAction(style: .destructive, title: "详细") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let pageStyle: DetailPageStyle = indexPath.row == 0 ? .main : .second
            let pageModel = self.vm.lessons[indexPath.section]
            let vc = DetailViewController(with: pageStyle, pageModel: pageModel, index: indexPath.row, sectionIndex: indexPath.section)
            self.navigationController?.pushViewController(vc, animated: true)
            completionHandler(true)
        }
        detailAction.backgroundColor = .systemOrange
        
        // 创建滑动操作配置
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, detailAction])
        return configuration
    }
}
