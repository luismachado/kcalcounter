//
//  CreateEditMealViewModel.swift
//  KcalLogger
//
//  Created by Luís Machado on 16/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

final class CreateEditMealViewModel: CreateEditMealViewModelProtocol {

    internal var title: String {
        return meal.mealId == nil ? "New Meal" : "Edit Meal"
    }

    internal var meal: Meal!

    internal var description: Dynamic<String>
    internal var date: Dynamic<String>
    internal var time: Dynamic<String>
    internal var calories: Dynamic<String>

    internal var isNewMeal: Bool {
        return meal.mealId == nil
    }

    internal var isMealValid: Bool {
        return !meal.description.isEmpty && meal.kcalAmount > 0
    }

    func set(description: String) {
        self.meal.description = description
        update()
    }

    func set(date: Date) {
        self.meal.date = date
        update()
    }

    func set(calories: String) {
        self.meal.kcalAmount = Int(calories) ?? 0
        update()
    }

    private func update() {
        description.value = meal.description
        date.value = meal.date.stringify()
        time.value = meal.date.getHoursMinutes()
        calories.value = meal.kcalAmount > 0 ? "\(meal.kcalAmount) kCal" : ""
    }

    private func getKcalFormatted() -> String {
        return meal.kcalAmount > 0 ? "\(meal.kcalAmount) kCal" : ""
    }

    init(mealId: String?, description: String = "", date: Date = Date(), kcalAmount: Int = 0) {
        self.meal = Meal(description: description, date: date, kcalAmount: kcalAmount)
        self.meal.mealId = mealId
        
        self.description = Dynamic(meal.description)
        self.date = Dynamic(meal.date.stringify())
        self.time = Dynamic(meal.date.getHoursMinutes())
        self.calories = Dynamic(meal.kcalAmount > 0 ? "\(meal.kcalAmount) kCal" : "")
    }
}
