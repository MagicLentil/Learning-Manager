//
//  LessonItemCell.swift
//  LearningManager
//
//  Created by leo on 2024/9/16.
//

import UIKit
import RxSwift

protocol FileCellProtocol: AnyObject {
    func itemCellBtnClick()
}

class LessonItemCell: UITableViewCell {
    
    static let identifier = "LessonItemCellIdentifier"
    
    private let bag = DisposeBag()
    
    var isBtnSelected = false {
        didSet {
            checkBtn.isSelected = isBtnSelected
        }
    }
    
    var didTapCheckBox:((Bool) -> Void)? = nil
    
    lazy var checkBtn: UIButton = {
        let checkBtn = UIButton(type: .custom)
        checkBtn.rx.tap.subscribeNext { [weak checkBtn, weak self]_ in
            guard let checkBtn = checkBtn, let self = self else { return }
            checkBtn.isSelected.toggle()
            self.isBtnSelected = checkBtn.isSelected
            self.didTapCheckBox?(self.isBtnSelected)
        }.disposed(by: bag)
        checkBtn.setImage(UIImage(named: "unselected"), for: .normal)
        checkBtn.setImage(UIImage(named: "selected"), for: .selected)
        return checkBtn
    }()
    
    let titleLable = UILabel().then {
        $0.font = .boldFont(17)
        $0.textColor = .pl_title
        $0.numberOfLines = 2
    }
    
    private let progressLable = UILabel().then {
        $0.font = .boldFont(16)
        $0.textColor = UIColor(hex: 0x85878D)
    }
    
    let grayLine = UIView().then {
        $0.backgroundColor = UIColor(hex: 0x000E1F, alpha: 0.12)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupSubviews()
    }
    
    func setupSubviews() {
        contentView.addSubview(checkBtn)
        checkBtn.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(25)
        }
        
        contentView.addSubview(titleLable)
        titleLable.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(checkBtn.snp.right).offset(10)
        }
        
        contentView.addSubview(progressLable)
        progressLable.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-30)
        }
        
        contentView.addSubview(grayLine)
        grayLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(titleLable)
            make.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindData(with lesson: Lesson) {
        titleLable.text = lesson.lessonName
        checkBtn.isSelected = lesson.selected
        progressLable.text = lesson.progress
    }
}
