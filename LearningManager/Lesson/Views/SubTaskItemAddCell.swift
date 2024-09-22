//
//  SubTaskItemAddCell.swift
//  LearningManager
//
//  Created by leo on 2024/9/16.
//

import UIKit

class SubTaskItemAddCell: LessonItemAddCell {

    static let subIdentifier = "SubTaskItemAddCellIdentifier"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupSubviews()
    }
    
    override func setupSubviews() {
        textView.placeholderLabel.text = "添加里程碑"
        contentView.addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(60)
        }
        
        contentView.addSubview(checkBtn)
        checkBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(60)
        }
        
        contentView.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(35)
            make.right.equalToSuperview().offset(-30)
            make.left.equalTo(addBtn.snp.right).offset(10)
        }
        
        titleLable.text = "添加里程碑"
        contentView.addSubview(titleLable)
        titleLable.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(addBtn.snp.right).offset(10)
        }
        
        contentView.addSubview(grayLine)
        grayLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(addBtn)
            make.right.equalToSuperview()
        }
        
        
    }
    @objc override func finishEditClick(_ notification: Notification) {
        if let userInfo = notification.userInfo, let isSuccessful = userInfo["isEditLesson"] as? Bool {
            if isSuccessful == true {
                return
            }
        }
        if (textView.isHidden) { return }
        if let currentText = textView.text as String? {
            if currentText.isEmpty {
                
            } else {
                self.itemAddCellTextViewFinishedAction?(true, currentText)
            }
            
            refreshEditState(flag: false)
            self.contentView.endEditing(true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
