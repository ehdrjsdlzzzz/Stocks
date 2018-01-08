//
//  AppDelegate.swift
//  Stock-Application
//
//  Created by 이동건 on 2017. 12. 8..
//  Copyright © 2017년 이동건. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    let tabBarController = UITabBarController()
    
    var groupsViewController: GroupsViewController? {
        return (tabBarController.viewControllers?[0] as? UINavigationController)?.topViewController as? GroupsViewController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        tabBarController.viewControllers = [ UINavigationController(rootViewController: GroupsViewController()),
                                             UINavigationController(rootViewController: StocksViewController())]
        
        tabBarController.tabBar.isHidden = true // UISegmenetedControl을 통해 제어할 것.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }
}
