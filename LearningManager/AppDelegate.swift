//
//  AppDelegate.swift
//  LearningManager
//
//  Created by leo on 2024/9/15.
//

import UIKit
import MMKV

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWindow()
        Self.setupStorage()
        executeNormalLaunch(launchOptions: launchOptions)
        return true
    }
    
    static func setupStorage() {
        MMKV.initialize(rootDir: nil)
        _ = PlanTable.shared
    }
    
    private func setupWindow() {
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: UIDevice.width, height: UIDevice.height))
        window?.frame = UIScreen.main.bounds
    }
    
    /// 显示首页
    func setupTabBarViewController() {
        let tabbarViewController = TabBarViewController()
        setupRootViewController(with: tabbarViewController)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func executeNormalLaunch(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        setupTabBarViewController()
    }
    
    func setupRootViewController(with rootVC: UIViewController) {
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }
}

