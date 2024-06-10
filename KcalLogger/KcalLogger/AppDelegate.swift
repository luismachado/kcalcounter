//
//  AppDelegate.swift
//  KcalLogger
//
//  Created by Luís Machado on 12/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        if ProcessInfo.processInfo.arguments.contains("UI-Testing") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            AppUser.getCurrentUser()?.logout {}
            AppUser.userApi = UserAPIMock(shouldFail: false, forgetUser: false)
        }

        if ProcessInfo.processInfo.arguments.contains("UI-Testing-Logged-In") {
            AppUser.logIn(email: "email@email.com", password: "123456", success: { (_) in }) { (_) in}
            print("DO THIS")
            if let navController = self.window?.rootViewController as? UINavigationController, let mealListVC = navController.visibleViewController as? MealListViewController {
                let meal1 = MealListsViewModel_Mock.mealMock
                meal1.mealId = "1"
                let meal2 = MealListsViewModel_Mock.mealMock2
                meal1.mealId = "2"
                let meal3 = MealListsViewModel_Mock.mealMock3
                meal1.mealId = "3"
                let meal4 = MealListsViewModel_Mock.mealMock4
                meal1.mealId = "4"
                mealListVC.viewModel = MealListsViewModel_Mock(throwErrors: false, preMeals: [meal1,meal2,meal3,meal4])

            }
        }

        return true
    }
}

