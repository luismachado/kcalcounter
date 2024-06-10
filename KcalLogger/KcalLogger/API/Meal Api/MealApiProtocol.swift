//
//  MealApiProtocol.swift
//  KcalLogger
//
//  Created by Luís Machado on 16/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

enum MealApiError: Error {
    case unableToFetchList
    case itemHasNoId

    func handle() -> String {
        let suffix = "Please try again later."
        switch self {
        case .unableToFetchList:
            return "Meal list could not be retrieved. \(suffix)"
        case .itemHasNoId:
            return "Meal could not be retrieved. \(suffix)"
        }
    }
}

enum MealFilterType: String {
     case time = "hoursMinutes"
    case date = "date"
}

protocol MealApiProtocol {

    func getCalories(uid: String,
                     success: @escaping ([String : Any]) -> (),
                     failure: @escaping(Error) -> ())

    func getMealListForUserWith(id uid: String, lastKey: Any?,
                                 success: @escaping ([String: Any]) -> (),
                                 failure: @escaping(Error) -> ())

    func getFilteredtMealListForUserWith(id uid: String, filterType: MealFilterType, lowerBound: Any, upperBound: Any,
                                                success: @escaping ([String : Any]) -> (),
                                                failure: @escaping (Error) -> ())

    func addMeal(uid: String, mealJson: Json,
                     gotId: @escaping (_ id: String?) -> (),
                     success: @escaping () -> (),
                     failure: @escaping(Error) -> ())

    func editMeal(uid: String, mealId: String?, mealJson: Json,
                      success: @escaping () -> (),
                      failure: @escaping(Error) -> ())


    func deleteMeal(uid: String, mealId: String,
                        success: @escaping () -> (),
                        failure: @escaping(Error) -> ())
}

