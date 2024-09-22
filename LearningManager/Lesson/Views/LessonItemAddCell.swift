//
//  SubLessonItemAddCell.swift
//  LearningManager
//
//  Created by leo on 2024/9/16.
//

import UIKit
import RxSwift

protocol LessonItemAddCellDelegate {
    func lessonItemAddCellDelegateTextViewStarted()
}

let addItemEditNotiFication = NSNotification.Name(rawValue: "addItemEditNotiFication")

class LessonItemAddCell: UITableViewCell {
    
    private let bag = DisposeBag()
    
    var delegate: LessonItemAddCellDelegate?
    
    var didTapAddAction:(() -> Void)? = nil
    
    var itemAddCellTextViewFinishedAction:((Bool, String) -> Void)? = nil
    
    var itemSubAddCellTextViewFinishedAction:((Bool, String) -> Void)? = nil
    
    lazy var checkBtn: UIButton = {
        let checkBtn = UIButton(type: .custom)
        checkBtn.rx.tap.subscribeNext { [weak checkBtn, weak self]_ in
            guard let checkBtn = checkBtn, let self = self else { return }
            checkBtn.isSelected.toggle()
        }.disposed(by: bag)
        checkBtn.isHidden = true
        checkBtn.setImage(UIImage(named: "unselected"), for: .normal)
        checkBtn.setImage(UIImage(named: "selected"), for: .selected)
        return checkBtn
    }()
    
    let textView = TextView().then {
        $0.placeholderLabel.text = "添加课程"
        $0.placeholderLabel.font = .font(16)
        $0.placeholderLabel.textColor = .hex(0xB7BCD2)
//        $0.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 15, right: 16)
        $0.isHidden = true
        $0.textContainer.lineFragmentPadding = 0
        $0.font = .font(16)
        $0.textColor = .pl_title
        $0.tintColor = UIColor(hex: 0x8072FF)
    }
    
    lazy var addBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.rx.tap.subscribeNext { [weak self]_ in
            guard let self = self else { return }
            btn.isSelected.toggle()
            self.didTapAddAction?()
            self.startEdit()
        }.disposed(by: bag)
        
        btn.setImage(UIImage(named: "common_add"), for: .normal)
        btn.setImage(UIImage(named: "common_add"), for: .highlighted)
        return btn
    }()
    
    let titleLable = UILabel().then {
        $0.font = .boldFont(17)
        $0.textColor = .pl_title
        $0.numberOfLines = 2
        $0.text = "添加课程"
    }
    
    let grayLine = UIView().then {
        $0.backgroundColor = UIColor(hex: 0x000E1F, alpha: 0.12)
    }
    
    static let identifier = "LessonItemAddCellIdentifier"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupSubviews()
        textView.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(finishEditClick(_:)),
            name: addItemEditNotiFication,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        contentView.addSubview(addBtn)
        contentView.addSubview(checkBtn)
        
        addBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(25)
        }
        
        checkBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(25)
        }
        
        contentView.addSubview(titleLable)
        titleLable.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(addBtn.snp.right).offset(10)
        }
        
        contentView.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(35)
            make.right.equalToSuperview().offset(-30)
            make.left.equalTo(addBtn.snp.right).offset(10)
        }
        
        contentView.addSubview(grayLine)
        grayLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(titleLable)
            make.right.equalToSuperview()
        }
    }
    
    func refreshEditState(flag: Bool) {
        self.checkBtn.isHidden = !flag
        self.textView.isHidden = !flag
        titleLable.isHidden = flag
        addBtn.isHidden = flag
    }
    
    func startEdit() {
        self.checkBtn.isHidden = false
        self.textView.text = ""  //
        self.textView.isHidden = false
        titleLable.isHidden = true
        addBtn.isHidden = true
        textView.becomeFirstResponder()
    }
    
    @objc func finishEditClick(_ notification: Notification) {
        if let userInfo = notification.userInfo, let isSuccessful = userInfo["isEditLesson"] as? Bool {
            if isSuccessful == false {
                return
            }
        }
        if let currentText = textView.text as String? {
            if currentText.isEmpty {
                
            } else {
                self.itemAddCellTextViewFinishedAction?(false, currentText)
            }
            
            refreshEditState(flag: false)
            self.contentView.endEditing(true)
        }
        textView.text = ""
    }
}

extension LessonItemAddCell: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.lessonItemAddCellDelegateTextViewStarted()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        refreshEditState(flag: false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView.markedTextRange == nil else { return }
   }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView.text.isNotEmpty else {
            return true
        }
        return true
    }
}

