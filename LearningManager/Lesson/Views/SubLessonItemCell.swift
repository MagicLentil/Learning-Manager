//
//  SubLessonItemCell.swift
//  LearningManager
//
//  Created by leo on 2024/9/16.
//

import UIKit

class SubLessonItemCell: LessonItemCell {
    
    static let subIdentifier = "subIdentifier"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupSubviews()
    }
    
    override func setupSubviews() {
        contentView.addSubview(checkBtn)
        checkBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(60)
        }
        
        contentView.addSubview(titleLable)
        titleLable.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(checkBtn.snp.right).offset(10)
        }
        
        contentView.addSubview(grayLine)
        grayLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(checkBtn)
            make.right.equalToSuperview()
        }
    }
    
    func bindData(with task: SubTaskInfo) {
        checkBtn.isSelected = task.selected
        titleLable.text = task.taskName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
