//
//  DetailViewController.swift
//  LearningManager
//
//  Created by leo on 2024/9/16.
//

import UIKit
import RxSwift

enum DetailPageStyle {
    case main
    case second
}

class DetailViewController: PLBaseViewController {
    
    private let bag = DisposeBag()

    let pageStyle: DetailPageStyle
    
    var pageModel: Lesson
    
    var curDesc = ""
    
    var curLevel: TaskLevel = .p0
    
    var curTimeStame: TimeInterval = 0
    
    var curName:String = ""
    
    var timeStarted: Bool = false
    var elapsedTime: TimeInterval = 0 // 记录经过的时间（以秒为单位）
    let sectionIndex: Int
    let index: Int
    
    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        return picker
    }()
    
    let eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    let eventDescriptionContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    let priorityContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    let taskContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    let actionContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    private let dateTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "总时间"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let dateShowDescLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0x8072FF)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 20
    }
    
    let eventDescriptionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "注释"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let dateContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
        
    let priorityLabel: UILabel = {
        let label = UILabel()
        label.text = "优先级:"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "日期:"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let dataSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()

    let priorityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Priority", for: .normal)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5.0
        return button
    }()
    
    let taskDescLabel: UILabel = {
        let label = UILabel()
        label.text = "里程碑:"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    
    let taskCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    let priorities = ["p0", "p1", "p2"]
    let priorityColors: [UIColor] = [.green.withAlphaComponent(0.3), .orange.withAlphaComponent(0.3), .red.withAlphaComponent(0.3)]

    private var consumerTimer: Timer?
    
    init(with pageStyle: DetailPageStyle, pageModel: Lesson, index: Int, sectionIndex: Int) {
        self.pageStyle = pageStyle
        self.pageModel = pageModel
        self.index = index
        self.sectionIndex = sectionIndex
        super.init(nibName: nil, bundle: nil)
        
        if index == 0 {
            curName = pageModel.lessonName
        } else {
            curName = pageModel.subTasks[index - 1].taskName
        }
        self.title = curName
    }
    
    deinit {
        self.stopTimer()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPriorityMenu()
        addHandleEvent()
        detailData()
        startTimerIfNeeded();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    func stopTimer() {
        consumerTimer?.invalidate()
        consumerTimer = nil
    }
    
    private func detailData() {
        let text = pageStyle == .main ? pageModel.desc : pageModel.subTasks[self.index - 1].desc
        eventDescriptionTextField.text = text;
        var curStamp: TimeInterval = 0
        if pageStyle == .second {
            let task = pageModel.subTasks[self.index - 1];
            self.priorityButton.setTitle(task.level.rawValue, for: .normal)
            timeStarted = pageModel.subTasks[index - 1].started
            elapsedTime = pageModel.subTasks[index - 1].totalTime
            curStamp = task.timStamp
            pageModel.subTasks[index - 1].totalTime = elapsedTime
            
            
            let hours = Int(elapsedTime) / 3600
            let minutes = (Int(elapsedTime) % 3600) / 60
            let seconds = Int(elapsedTime) % 60
            
            // 格式化时间为 00:00:00
            let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            // 更新 UILabel 的文本
            self.dateShowDescLabel.text = timeString
            
        } else {
            self.priorityButton.setTitle(pageModel.level.rawValue, for: .normal)
            curStamp = pageModel.timStamp
            
        }
        actionContainer.isHidden = pageStyle == .main
        if (curStamp == 0) {
            let currentDate = Date()
            timePicker.setDate(currentDate, animated: true)
        } else {
            let date = Date(timeIntervalSince1970: curStamp)
            // 设置 UIDatePicker 的日期
            timePicker.setDate(date, animated: true)
        }
        let str = timeStarted ? "end" : "start";
        actionButton.setTitle(str, for: .normal)
        actionButton.setTitle(str, for: .highlighted)
        
         
    }
    
    private func startTimerIfNeeded() {
        if self.pageStyle == .main { return }
        if self.pageModel.subTasks[self.index - 1].started == false { return }
        consumerTimer = Timer(timeInterval: 1.0, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            
            
            elapsedTime += 1 // 增加经过的时间
                    
            // 计算小时、分钟和秒
            let hours = Int(elapsedTime) / 3600
            let minutes = (Int(elapsedTime) % 3600) / 60
            let seconds = Int(elapsedTime) % 60
            
            // 格式化时间为 00:00:00
            let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            // 更新 UILabel 的文本
            self.dateShowDescLabel.text = timeString
        })
        RunLoop.main.add(consumerTimer!, forMode: .common)
    }
    
    private func setupUI() {
        headerView.rightButton.isHidden = false
        headerView.setRightButton(with: "完成", target: self, action: #selector(finishAction))
        headerView.rightButton.setTitleColor( UIColor.pl_title, for: .normal)
        headerView.rightButton.setTitleColor( UIColor.pl_title, for: .highlighted)
        headerView.leftButton.isHidden = false
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        [eventDescriptionContainer, dateContainer, priorityContainer, taskContainer, actionContainer].forEach { container in
            stackView.addArrangedSubview(container)
            container.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
            }
        }
        eventDescriptionContainer.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        eventDescriptionContainer.addSubview(eventNameLabel)
        eventDescriptionContainer.addSubview(separatorLine)
        eventDescriptionContainer.addSubview(eventDescriptionTextField)
        
        eventNameLabel.text = curName
        eventNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
        }
                
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(eventNameLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        eventDescriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.left.right.equalTo(separatorLine)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        priorityContainer.addSubview(priorityLabel)
        priorityContainer.addSubview(priorityButton)
        
        priorityLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        priorityButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(75)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(40)
        }
        
        taskContainer.addSubview(taskDescLabel)
        taskContainer.addSubview(taskCountLabel)
        
        taskDescLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }
        
        taskCountLabel.text = String(pageModel.subTasks.count)
        taskCountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(75)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        dateContainer.addSubview(dateLabel)
        dateContainer.addSubview(dataSeparatorLine)
        dateContainer.addSubview(timePicker)
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        dataSeparatorLine.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        timePicker.snp.makeConstraints { make in
            make.top.equalTo(dataSeparatorLine.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        taskContainer.isHidden = pageStyle == .second
        
        actionContainer.addSubview(dateTotalLabel)
        actionContainer.addSubview(actionButton)
        actionContainer.addSubview(dateShowDescLabel)
        
        dateTotalLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(10)
        }
        
        dateShowDescLabel.snp.makeConstraints { make in
            make.top.equalTo(dateTotalLabel.snp.bottom).offset(10)
            make.left.equalTo(dateTotalLabel)
        }
        
        actionButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(40)
            make.width.equalTo(75)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    @objc func finishAction() {
        let currentDate = timePicker.date
        let timestamp = currentDate.timeIntervalSince1970
        let textStr = eventDescriptionTextField.text ?? ""
        print(textStr)
        print(curLevel)
        print(timestamp)
        self.navigationController?.popViewController(animated: true)
        
        
        var tempLessons = PlanTable.shared.lessons
        if pageStyle == .main {
            pageModel.level = curLevel
            pageModel.timStamp = timestamp
            pageModel.desc = textStr;
        } else {
            pageModel.subTasks[index - 1].timStamp = timestamp
            pageModel.subTasks[index - 1].desc = textStr
            pageModel.subTasks[index - 1].level = curLevel
            pageModel.subTasks[index - 1].started = timeStarted
            pageModel.subTasks[index - 1].totalTime = elapsedTime
        }
        
        tempLessons[sectionIndex] = pageModel
        PlanTable.shared.lessons = tempLessons
        
        print(PlanTable.shared.lessons)
    }
    
    private func addHandleEvent() {
        timePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        if pageStyle == .main { return }
        actionButton.rx.tap.subscribeNext { [weak self]  in
            guard let self = self else { return }
            let str = self.timeStarted ? "start" : "end";
            self.timeStarted.toggle()
            self.pageModel.subTasks[self.index - 1].started = self.timeStarted
            self.actionButton.setTitle(str, for: .normal)
            self.actionButton.setTitle(str, for: .highlighted)
            // 修改状态
            if timeStarted {
                self.startTimerIfNeeded()
            } else {
                self.stopTimer()
            }
        }.disposed(by: bag)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
            // 获取用户选择的日期和时间
        let selectedDate = sender.date
        
        // 获取当前日期，并去掉时间部分
        let currentDate = Calendar.current.startOfDay(for: Date())
        
        // 比较选择的日期和当前日期
        if selectedDate < currentDate {
            PLToast.showAutoHideHint("不能小于当前日期")
            sender.setDate(currentDate, animated: true)
        }
    }
        
    private func setupPriorityMenu() {
        var actions: [UIAction] = []
                
        for priority in priorities {
            let action = UIAction(title: priority) { [weak self] _ in
                guard let self = self else { return }
                self.priorityButton.setTitle(priority, for: .normal)
                self.curLevel = TaskLevel(rawValue: priority) ?? .p0
            }
            actions.append(action)
        }
        let menu = UIMenu(children: actions)
        priorityButton.menu = menu
        priorityButton.showsMenuAsPrimaryAction = true
    }
}
