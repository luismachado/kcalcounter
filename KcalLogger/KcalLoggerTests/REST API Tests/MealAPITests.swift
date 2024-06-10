//
//  MealAPITests.swift
//  KcalLoggerTests
//
//  Created by Luís Machado on 23/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Quick
import Nimble
@testable import KcalLogger

class MealAPITests: QuickSpec {

    var mealApi: MealApiProtocol = MealApi.shared
    var testUserId: String = "ehdOoNmNL0goDGSPDth1phwMqEB2"

    override func spec() {
        describe("Meal API Tests") {

            beforeEach {
            }

            it("fetchMeals") {
                waitUntil(timeout: 2) { done in
                    self.mealApi.getMealListForUserWith(id: self.testUserId, lastKey: nil, success: { (mealListJson) in
                        done()
                        let idList = Array(mealListJson.keys)
                        let list = idList.compactMap { Meal(mealId: $0, json: mealListJson[$0] as! [String: Any]) }
                        expect(list.contains(where: {$0.mealId == "-LafK2bVVY1BiLEjzUxP"})).to(beTrue())
                        expect(list.contains(where: {$0.mealId == "-LafK5bx-W-ShoJFeSoU"})).to(beTrue())
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Meal fetch failed")
                    })
                }
            }

            it("fetchTestFilter") {
                waitUntil(timeout: 2) { done in
                    self.mealApi.getFilteredtMealListForUserWith(id: self.testUserId, filterType: .date, lowerBound: 1553299200, upperBound: 1553385599, success: { (mealListJson) in
                        let idList = Array(mealListJson.keys)
                        let list = idList.compactMap { Meal(mealId: $0, json: mealListJson[$0] as! [String: Any]) }
                        expect(list.contains(where: {$0.mealId == "-LafK2bVVY1BiLEjzUxP"})).to(beTrue())
                        expect(list.contains(where: {$0.mealId == "-LafK5bx-W-ShoJFeSoU"})).to(beTrue())
                        expect(list.contains(where: {$0.mealId == "-LafVUDfWlzUf9UvQGFu"})).to(beFalse())
                        expect(list.contains(where: {$0.mealId == "-LafVd5Nc4tnJ4akoGHB"})).to(beFalse())
                        done()
                    }, failure: { (error) in
                        expect(false).to(beTrue(), description: "Meal filter fetch failed")
                        done()
                    })
                }
            }

            it("addEditAndDelete") {

                let meal = Meal(description: "MyTestMeal", date: Date(), kcalAmount: 256)

                waitUntil(timeout: 10) { done in
                    self.mealApi.addMeal(uid: self.testUserId, mealJson: meal.toJson(), gotId: { (mealId) in
                        meal.mealId = mealId
                    }, success: {
                        // CHECK IF EXISTS
                        self.mealApi.getMealListForUserWith(id: self.testUserId, lastKey: nil, success: { (mealListJson) in
                            let idList = Array(mealListJson.keys)
                            let list = idList.compactMap { Meal(mealId: $0, json: mealListJson[$0] as! [String: Any]) }
                            expect(list.contains(where: {$0.mealId == meal.mealId})).to(beTrue())

                            // EDIT MEAL
                            meal.description = "MyTestMeal2"
                            self.mealApi.editMeal(uid: self.testUserId, mealId: meal.mealId, mealJson: meal.toJson(), success: {

                                // CHECK EDITION
                                self.mealApi.getMealListForUserWith(id: self.testUserId, lastKey: nil, success: { (mealListJson) in
                                    let idList = Array(mealListJson.keys)
                                    let list = idList.compactMap { Meal(mealId: $0, json: mealListJson[$0] as! [String: Any]) }
                                    expect(list.contains(where: {$0.mealId == meal.mealId && $0.description == "MyTestMeal2"})).to(beTrue())

                                    // DELETE
                                    self.mealApi.deleteMeal(uid: self.testUserId, mealId: meal.mealId ?? "0", success: {

                                        // CHECK DELETION
                                        self.mealApi.getMealListForUserWith(id: self.testUserId, lastKey: nil, success: { (mealListJson) in
                                            done()
                                            let idList = Array(mealListJson.keys)
                                            let list = idList.compactMap { Meal(mealId: $0, json: mealListJson[$0] as! [String: Any]) }
                                            expect(list.contains(where: {$0.mealId == meal.mealId})).to(beFalse())
                                        }, failure: { (error) in
                                            done()
                                            expect(false).to(beTrue(), description: "Meal fetch failed")
                                        })
                                    }, failure: { (error) in
                                        done()
                                        expect(false).to(beTrue(), description: "Meal deletion failed")
                                    })
                                }, failure: { (error) in
                                    done()
                                    expect(false).to(beTrue(), description: "Meal fetch failed")
                                })
                            }, failure: { (error) in
                                done()
                                expect(false).to(beTrue(), description: "Meal edit failed")
                            })
                        }, failure: { (error) in
                            done()
                            expect(false).to(beTrue(), description: "Meal fetch failed")
                        })
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Meal adition failed")
                    })
                }
            }
        }
    }
}
