//
//  CalorieExcessTest.swift
//  KcalLoggerTests
//
//  Created by Luís Machado on 19/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Quick
import Nimble
@testable import KcalLogger

class CalorieExcessTest: QuickSpec {

    var viewController: MealListViewController!

    override func spec() {
        describe("View Controller Tests") {

            beforeEach {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if let navController = appDelegate.window?.rootViewController as? UINavigationController, let mealListVC = navController.visibleViewController as? MealListViewController {
                    self.viewController = mealListVC
                    _ = navController.view
                }
            }

            it("testViewModel") {
                expect(self.viewController.viewModel).toNot(beNil())
            }

            it("shouldNotExceed") {
                let viewModel = self.viewController.viewModel

                let meal = viewModel.meals[0]
                var test = viewModel.hasExceededCaloriesForDay(meal: meal)
                expect(test).to(beFalse())

                let meal2 = Meal(description: "Meal2", date: meal.date, kcalAmount: 10000)
                meal2.mealId = "2"
                viewModel.add(meal: meal2, completed: { (_) in})

                test = viewModel.hasExceededCaloriesForDay(meal: meal)
                expect(test).to(beTrue())

            }

        }
    }
}
