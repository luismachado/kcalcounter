//
//  Meal.swift
//  KcalLogger
//
//  Created by Luís Machado on 12/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation
import KRProgressHUD

class Meal {

    var mealId: String?
    var description: String
    var date: Date
    var kcalAmount: Int

    static var mealApi:MealApiProtocol = MealApi.shared

    // MARK: - Init
    init(description: String, date: Date, kcalAmount: Int) {
        self.description = description
        self.date = date
        self.kcalAmount = kcalAmount
    }

    init?(mealId: String, json: Json) {
        self.mealId = mealId

        guard
            let description = json["description"] as? String,
            let dateTimestamp = json["date"] as? Int,
            let kcalAmount = json["kcalAmount"] as? Int
            else {
                return nil
        }

        self.description = description
        self.kcalAmount = kcalAmount
        self.date = Date(timeIntervalSince1970: TimeInterval(dateTimestamp))
    }

    // MARK: - JSON Converter
    func toJson() -> Json {
        return [
            "description": self.description,
            "date": Int(self.date.timeIntervalSince1970),
            "dateOrder": -Int(self.date.timeIntervalSince1970),
            "hoursMinutes" : self.date.getHoursMinutes(),
            "kcalAmount": self.kcalAmount
        ]
    }


    //Operations
    //Edit
    func updateMeal(userId: String, success: @escaping ()->(), failure: @escaping (String)->()) {
        // Improvement: function should receive new value (instead of editing the object directly). That way
        // we can backup the old value and set it back if the api fails

        KRProgressHUD.show()
        saveMeal(userId: userId, success: {
            KRProgressHUD.dismiss()
            success()
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(handleErrors(error: error))
        }
    }

    private func saveMeal(userId: String, success: @escaping ()->(), failure: @escaping (Error)->()) {

        Meal.mealApi.editMeal(uid: userId, mealId: self.mealId, mealJson: self.toJson(), success: {
            success()
        }) { (error) in
            failure(error)
        }
    }
}
