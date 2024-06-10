//
//  MealListModelTest.swift
//  KcalLoggerTests
//
//  Created by Luís Machado on 23/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Quick
import Nimble
import Firebase
@testable import KcalLogger

class MealListModelTest: QuickSpec {

    var viewModel: MealListViewModelProtocol = MealListsViewModel(user: nil)
    var testUserId: String = "ehdOoNmNL0goDGSPDth1phwMqEB2"
    var email: String = "apitest@email.com"
    var password: String = "qwerty1234"


    override func spec() {
        describe("Meal List Model") {

            AppUser.userApi = UserApi.shared

            beforeEach {
                waitUntil(timeout: 2) { done in
                    AppUser.logIn(email: self.email, password: self.password, success: { (uid) in
                        self.viewModel.user = AppUser.getCurrentUser()
                        done()
                    }, failure: { (_) in
                        done()
                    })
                }
            }

            it("logout") {
                waitUntil(timeout: 2) { done in
                    self.viewModel.logout {
                        done()
                        expect(self.viewModel.meals.count).to(equal(0))
                    }
                }
            }

            it("fetch meals") {
                waitUntil(timeout: 10) { done in
                    self.viewModel.fetchList(restart: true, success: {
                        done()
                        expect(self.viewModel.meals.count == 4).to(beTrue())
                        expect(self.viewModel.numberOfSections()).to(equal(3))
                        expect(self.viewModel.nameForSection(in: 0)).to(equal("23 March"))
                        expect(self.viewModel.numberOfRowsInSection(section: 0)).to(equal(2))
                        expect(self.viewModel.mealPosition(for: IndexPath(item: 0, section: 0))).to(equal(MealPosition.first))
                        expect(self.viewModel.mealPosition(for: IndexPath(item: 1, section: 0))).to(equal(MealPosition.last))
                        expect(self.viewModel.mealPosition(for: IndexPath(item: 0, section: 1))).to(equal(MealPosition.only))
                        expect(self.viewModel.mealFor(indexPath: IndexPath(item: 0, section: 0)).description).to(equal("Two Meals"))
                    }, failure: { (errror) in
                        done()
                        expect(false).to(beTrue(), description: "Fetch lists failed")
                    })
                }
            }

            it("update meal") {
                waitUntil(timeout: 50) { done in
                    self.viewModel.fetchList(restart: true, success: {
                        let meal = self.viewModel.meals[self.viewModel.meals.count - 1]
                        let sections = self.viewModel.numberOfSections()
                        let originalDate = meal.date
                        meal.date = Date(timeIntervalSince1970: 0)
                        self.viewModel.update(meal: meal, completed: { (error) in
                            expect(self.viewModel.numberOfSections()).to(equal(sections+1))
                            meal.date = originalDate
                            self.viewModel.update(meal: meal, completed: { (error) in
                                expect(self.viewModel.numberOfSections()).to(equal(sections))
                                done()
                            })
                        })
                    }, failure: { (errror) in
                        done()
                        expect(false).to(beTrue(), description: "Fetch lists failed")
                    })
                }
            }

            it("fetch meals") {
                waitUntil(timeout: 10) { done in
                    let newMeal = Meal(description: "NewMeal", date: Date(), kcalAmount: 888)
                    self.viewModel.add(meal: newMeal, completed: { (error) in
                        if error != nil {
                            done()
                            expect(false).to(beTrue(), description: "Add meal failed")
                        } else {
                            guard let newMealId = newMeal.mealId else {
                                done()
                                expect(false).to(beTrue(), description: "No Meal Id")
                                return
                            }
                            print("NEW MEAL ID \(newMealId)")
                            self.viewModel.fetchList(restart: true, success: {
                                expect(self.viewModel.meals.contains(where: { ($0.mealId ?? "") == newMealId})).to(beTrue())
                                self.viewModel.remove(meal: newMeal, completed: { (error) in
                                    if error != nil {
                                        done()
                                        expect(false).to(beTrue(), description: "Delete meal failed")
                                    } else {
                                        self.viewModel.fetchList(restart: true, success: {
                                            done()
                                            expect(self.viewModel.meals.contains(where: { ($0.mealId ?? "") == newMealId})).to(beFalse())
                                        }, failure: { (errror) in
                                            done()
                                            expect(false).to(beTrue(), description: "Fetch lists failed")
                                        })
                                    }
                                })
                            }, failure: { (errror) in
                                done()
                                expect(false).to(beTrue(), description: "Fetch lists failed")
                            })
                        }
                    })
                }
            }

            it("filter meals") {
                waitUntil(timeout: 10) { done in
                    self.viewModel.fetchFilteredMealList(filterType: .date, lowerBound: Date(timeIntervalSince1970: 1553299200), upperBound: Date(timeIntervalSince1970: 1553385599), success: {
                        expect(self.viewModel.meals.count).to(equal(2))
                        self.viewModel.fetchList(restart: true, success: {
                            done()
                        }, failure: { (error) in
                            done()
                            expect(false).to(beTrue(), description: "Fetch filter lists failed")
                        })
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Fetch filter lists failed")
                    })
                }
            }

            it("filter meals multi") {
                waitUntil(timeout: 10) { done in
                    self.viewModel.fetchMultiFilteredMealList(lowerBound: Date(timeIntervalSince1970: 1553212800), upperBound: Date(timeIntervalSince1970: 1553385599), lowerHourBound: Date(timeIntervalSince1970: 1546343400), upperHourBound: Date(timeIntervalSince1970: 1546351200), success: {
                        expect(self.viewModel.meals.count).to(equal(2))
                        self.viewModel.fetchList(restart: true, success: {
                            done()
                        }, failure: { (error) in
                            done()
                            expect(false).to(beTrue(), description: "Fetch filter lists failed")
                        })
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Fetch filter lists failed")
                    })
                }
            }

            it("change calories") {
                guard let user = self.viewModel.user else {
                    expect(false).to(beTrue(), description: "No User!")
                    return
                }
                let originalCalories = user.dailyKcal
                waitUntil(timeout: 10) { done in
                    self.viewModel.changeCalories(newCalories: 4999, success: {
                        expect(user.dailyKcal).to(equal(4999))
                        self.viewModel.changeCalories(newCalories: originalCalories, success: {
                            done()
                            expect(user.dailyKcal).to(equal(originalCalories))
                        }, failure: { (error) in
                            done()
                            expect(false).to(beTrue(), description: "Error updating user's calories")
                        })
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Error updating user's calories")
                    })
                }
            }
        }
    }
}
