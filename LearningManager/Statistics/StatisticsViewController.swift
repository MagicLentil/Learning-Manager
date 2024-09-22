import UIKit
import SnapKit

class PersonalPageViewController: PLBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var lessons: [Lesson] = PlanTable.shared.lessons
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Setup TableView
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.separatorStyle = .none
        contentView.addSubview(tableView)
        
        //  Set table view constraints using SnapKit
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lessons = PlanTable.shared.lessons
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Personal Info and Task List
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : sortedTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "个人信息"
            cell.detailTextLabel?.text = "学习总时长: \(formatTime(totalStudyTime))"
            cell.selectionStyle = .none // Remove selection highlight
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
                return UITableViewCell()
            }
            let task = sortedTasks[indexPath.row]
            cell.configure(with: task, maxTotalTime: maxTotalTime)
            return cell
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    // MARK: - Helpers
    
    var totalStudyTime: Double {
        lessons.flatMap { $0.subTasks }.reduce(0) { $0 + $1.totalTime }
    }
    
    var sortedTasks: [SubTaskInfo] {
        lessons.flatMap { $0.subTasks }.sorted { $0.totalTime > $1.totalTime }
    }
    
    var maxTotalTime: Double {
        lessons.flatMap { $0.subTasks }.map { $0.totalTime }.max() ?? 1
    }
    
    func formatTime(_ totalTime: Double) -> String {
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        let seconds = Int(totalTime) % 60
        return "\(hours)小时 \(minutes)分钟 \(seconds)秒"
    }
}

class TaskCell: UITableViewCell {
    
    private let taskNameLabel = UILabel()
    private let timeLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        selectionStyle = .none // Disable cell selection highlight
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        taskNameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(taskNameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(progressBar)

        // Layout using SnapKit
        taskNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(15)
            make.trailing.equalTo(contentView).offset(-15)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(taskNameLabel.snp.bottom).offset(5)
            make.leading.equalTo(contentView).offset(15)
            make.trailing.equalTo(contentView).offset(-15)
        }
        
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView).offset(15)
            make.trailing.equalTo(contentView).offset(-15)
            make.bottom.equalTo(contentView).offset(-10)
            make.height.equalTo(10)
        }
        
        // Apply card-like style
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.backgroundColor = UIColor.white
    }

    func configure(with task: SubTaskInfo, maxTotalTime: Double) {
        taskNameLabel.text = task.taskName
        timeLabel.text = formatTime(task.totalTime)
        progressBar.progress = Float(task.totalTime / maxTotalTime)
    }
    
    private func formatTime(_ totalTime: Double) -> String {
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        let seconds = Int(totalTime) % 60
        return "\(hours)小时 \(minutes)分钟 \(seconds)秒"
    }
}
