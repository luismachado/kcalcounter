//
//  MealListViewModelProtocol.swift
//  KcalLogger
//
//  Created by Luís Machado on 18/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

enum MealError: Error {
    case unableToAddMeal
    case unableToDeleteMeal
    case unableToEditMeal

    func handle() -> String {
        let suffix = "Please try again later."
        switch self {
        case .unableToAddMeal:
            return "Meal could not be added. \(suffix)"
        case .unableToDeleteMeal:
            return "Meal could not be deleted. \(suffix)"
        case .unableToEditMeal:
            return "Meal could not be saved. \(suffix)"
        }
    }
}

enum MealPosition {
    case first
    case middle
    case last
    case only
}

protocol MealListViewModelProtocol: class {
    var user: AppUser? { get set }
    var title: String { get }

    var isFetchingMore: Bool { get }
    var idxPathsToAdd: Dynamic<[IndexPath]> { get }

    var meals: [Meal] { get set }
    var daysList: [String] { get }
    var caloriesPerDay: [String: Int] { get }
    var mealsPerDay: Dynamic<[String: [Meal]]> { get }

    var isShowingFilteredMeals: Bool { get }
    var isMyself: Bool { get }
    var lastTimestamp: Int? { get }

    func numberOfSections() -> Int
    func nameForSection(in section: Int) -> String
    func numberOfRowsInSection(section: Int) -> Int
    func mealPosition(for indexPath:IndexPath) -> MealPosition
    func mealFor(indexPath: IndexPath) -> Meal
    func hasExceededCaloriesForDay(meal: Meal) -> Bool

    func fetchList(restart: Bool, success: @escaping ()->(), failure: @escaping (String)->())
    func fetchFilteredMealList(filterType: MealFilterType, lowerBound: Date, upperBound: Date, success: @escaping ()->(), failure: @escaping (String)->())
    func fetchMultiFilteredMealList(lowerBound: Date, upperBound: Date, lowerHourBound: Date, upperHourBound: Date,
                                    success: @escaping ()->(), failure: @escaping (String)->())
    func add(meal: Meal, completed: @escaping (String?)->())
    func remove(meal: Meal, completed: @escaping (String?)->())
    func update(meal: Meal, completed: @escaping (String?)->())

    func logout(completed: @escaping ()->())
    func changeCalories(newCalories: Int, success: @escaping ()->(), failure: @escaping (String)->())
}
