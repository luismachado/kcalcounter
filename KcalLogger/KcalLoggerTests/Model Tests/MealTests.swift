//
//  Nimble.swift
//  KcalLoggerTests
//
//  Created by Luís Machado on 12/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Quick
import Nimble
@testable import KcalLogger

class MealTests: QuickSpec {

    override func spec() {
        describe("Standard Init") {
            it("createStandardMeal") {
                let date = Date()
                let meal = Meal(description: "Test123", date: date, kcalAmount: 1234)
                expect(meal.description).to(equal("Test123"))
                expect(meal.date).to(equal(date))
                expect(meal.kcalAmount).to(equal(1234))
            }
        }

        describe("Json Flow") {
            let nowDate = Date()
            let json:[String:Any] = [
                "description": "Meal1",
                "date": Int(nowDate.timeIntervalSince1970),
                "dateOrder": -Int(nowDate.timeIntervalSince1970),
                "hoursMinutes": nowDate.getHoursMinutes(),
                "kcalAmount": 2500
            ]

            it("jsonFail") {
                let wrongJson:[String:Any] = [
                    "description": "Meal1",
                    "date": nowDate,
                    "kcalAmount": 2500
                ]
                if Meal(mealId: "111", json: wrongJson) == nil {
                    expect(true).to(beTrue(), description: "Failed init with incorrect json")
                } else {
                    expect(false).to(beTrue(), description: "Unable to init from json")
                }

            }

            it("initJson") {
                if let meal = Meal(mealId: "111", json: json) {
                    expect(meal.description).to(equal("Meal1"))
                    expect(Int(meal.date.timeIntervalSince1970)).to(equal(Int(nowDate.timeIntervalSince1970)))
                    expect(meal.kcalAmount).to(equal(2500))
                } else {
                    expect(false).to(beTrue(), description: "Unable to init from json")
                }

            }

            it("getJson") {
                if let meal = Meal(mealId: "111", json: json) {
                    let jsonFromMeal = meal.toJson()
                    expect(NSDictionary(dictionary: json).isEqual(to: jsonFromMeal)).to(beTrue())
                } else {
                    expect(false).to(beTrue(), description: "Unable to init from json")
                }
            }
        }
    }
}
