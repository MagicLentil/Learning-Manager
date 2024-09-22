//
//  TabBarViewController.swift
//  PowerLoans
//
//  Created by Neo on 2023/8/27.
//

import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarStyle()
        setupSubViewControllers()
    }

    private func setupSubViewControllers() {
        let lessonVc = LessonViewController()
        lessonVc.tabBarItem = createItem(with: .lesson, vc: lessonVc, title: "课程", imageName: "lesson")

        let calendarVc = LMCalendarViewController()
        calendarVc.tabBarItem = createItem(with: .calendar, vc: calendarVc, title: "日历", imageName: "calendar")

        let statisticsVc = PersonalPageViewController()
        statisticsVc.tabBarItem = createItem(with: .statistics, vc: statisticsVc, title: "统计", imageName: "statistics")

        var tabArray: [UIViewController] = [lessonVc, calendarVc, statisticsVc]

        tabArray = tabArray.map { vc -> UINavigationController in
            vc.hidesBottomBarWhenPushed = false
            return UINavigationController(rootViewController: vc)
        }
        viewControllers = tabArray
    }

    private func setupTabBarStyle() {
//        tabBar.backgroundColor = .clear
//        tabBar.tintColor = UIColor.black
        tabBar.unselectedItemTintColor = UIColor(hex: 0xBCC1C6)
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.layer.shadowColor = UIColor(hex: 0x000000).cgColor
        tabBar.layer.shadowOpacity = 0.03
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 2
        tabBar.clipsToBounds = true
        tabBar.barTintColor = UIColor.white // 或者其他不透明颜色
        tabBar.isTranslucent = false
                
        // 设置分割线的颜色
//        let shadowImage = UIImage(color: UIColor.lightGray, size: CGSize(width: tabBar.frame.width, height: 1))
//        tabBar.shadowImage = shadowImage
        
        
        if #available(iOS 13.0, *) {
            UITabBar.appearance().backgroundColor = UIColor.white
        }
    }

    private func createItem(with page: TabBarItem.Page, vc: UIViewController, title: String, imageName: String) -> UITabBarItem {
        let item = TabBarItem(
            page: page,
            vc: vc,
            title: title,
            image: UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: imageName + "_selected")?.withRenderingMode(.alwaysOriginal)
        )

        item.setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor(hex: 0xBCC1C6),
                NSAttributedString.Key.font: UIFont.font(10),
            ],
            for: .normal
        )
        item.setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.font(10),
            ],
            for: .selected
        )
        return item
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
}
