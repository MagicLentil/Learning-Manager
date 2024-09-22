//
//  CalendarViewController.swift
//  LearningManager
//
//  Created by leo on 2024/9/15.
//

import UIKit
import SnapKit

class LMCalendarViewController: PLBaseViewController, CalendarViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "日历"
        setupSubViews()
        
    }

    
    func setupSubViews() {
        self.headerView.rightButton.isHidden = false
        self.headerView.setRightButton(with: "今日", target: self, action: #selector(selectToday))
        let calendarController = CJCalendarViewController()
        addChild(calendarController)
        contentView.addSubview(calendarController.view)
        calendarController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        calendarController.didMove(toParent: self)
        
        
        calendarController.delegate = self
    }
    
    @objc func selectToday() {
        NotificationCenter.default.post(name: Notification.Name("YourNotificationName"), object: nil, userInfo: nil)
    }

}
