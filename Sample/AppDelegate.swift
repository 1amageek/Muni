//
//  AppDelegate.swift
//  Sample
//
//  Created by 1amageek on 2018/07/27.
//  Copyright © 2018年 1amageek. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()

        self.window = UIWindow(frame: UIScreen.main.bounds)

        guard let user: FirebaseAuth.User = Auth.auth().currentUser else {
            Auth.auth().signInAnonymously { [weak self] (result, error) in
                if let error = error {
                    print(error)
                    return
                }

                let user: User = User(id: result!.user.uid)

                print("**************************************")
                print("YOUR ID: ", user.id)
                print("**************************************")
                user.save({ (_, _) in
                    let viewController: BoxViewController = BoxViewController(userID: user.id)
                    let navigationController: UINavigationController = UINavigationController(rootViewController: viewController)
                    let tabbarController: UITabBarController = UITabBarController(nibName: nil, bundle: nil)
                    tabbarController.setViewControllers([navigationController], animated: true)
                    self?.window?.rootViewController = tabbarController
                    self?.window?.makeKeyAndVisible()
                })
            }
            return true
        }

        print("**************************************")
        print("YOUR ID: ", user.uid)
        print("**************************************")


        User.get(user.uid) { (user, error) in
            if user == nil {
                _ = try! Auth.auth().signOut()
            }
        }

        let viewController: BoxViewController = BoxViewController(userID: user.uid)
        let navigationController: UINavigationController = UINavigationController(rootViewController: viewController)
//        navigationController.navigationBar.isTranslucent = false
        let tabbarController: UITabBarController = UITabBarController(nibName: nil, bundle: nil)
        tabbarController.setViewControllers([navigationController], animated: true)
        self.window?.rootViewController = tabbarController
        self.window?.makeKeyAndVisible()

        return true
    }
}

