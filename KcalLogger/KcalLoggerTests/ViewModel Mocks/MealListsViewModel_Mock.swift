//
//  MealListsViewModel_Mock.swift
//  KcalLoggerTests
//
//  Created by Luís Machado on 18/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation
@testable import KcalLogger

final class MealListsViewModel_Mock: MealListViewModelProtocol {
    var isFetchingMore: Bool = false
    
    var idxPathsToAdd: Dynamic<[IndexPath]> = Dynamic([])
    
    var user: AppUser?

    internal let title = "My Calories Logger"

    internal var meals: [Meal] = []
    internal var daysList: [String] = []
    internal var caloriesPerDay: [String: Int] = [:]
    internal var mealsPerDay: Dynamic<[String: [Meal]]> = Dynamic([:])
    var lastTimestamp: Int?
    
    var isShowingFilteredMeals: Bool = false

    var isMyself: Bool {
        return true
    }

    private var apiMeals: [Meal] = []
    private var throwErrors: Bool = false

    static var mealMock = Meal(description:  "Meal1", date: Date(timeIntervalSince1970: 1553342158), kcalAmount: 123)
    static var mealMock2 = Meal(description: "Meal2", date: Date(timeIntervalSince1970: 1553256000), kcalAmount: 555)
    static var mealMock3 = Meal(description: "Meal3", date: Date(timeIntervalSince1970: 1553275320), kcalAmount: 4000)
    static var mealMock4 = Meal(description: "Meal4", date: Date(timeIntervalSince1970: 1553169660), kcalAmount: 111)

    init(throwErrors: Bool, preMeals:[Meal]) {
        self.throwErrors = throwErrors
        self.apiMeals = preMeals
    }

    private func generateLists() {
        daysList.removeAll()
        caloriesPerDay.removeAll()
        mealsPerDay.value.removeAll()

        meals.forEach { (meal) in
            let key = meal.date.getYearMonthDay()
            if !daysList.contains(key) {
                daysList.append(key)
            }

            if var mealList = mealsPerDay.value[key] {
                mealList.append(meal)
                mealsPerDay.value[key] = mealList
            } else {
                mealsPerDay.value[key] = [meal]
            }

            //Increment calorie counter for the day
            if let counter = caloriesPerDay[key] {
                caloriesPerDay[key] = counter + meal.kcalAmount
            } else {
                caloriesPerDay[key] = meal.kcalAmount
            }
        }

        performSort()
    }

    private func removeMealFromList(meal: Meal) {
        if let idx = meals.index(where: { $0.mealId ?? "0" == meal.mealId ?? "0" }) {
            meals.remove(at: idx)
            generateLists() // Could be improved
        }
    }

    private func addMealToList(meal: Meal) {
        meals.append(meal)
        generateLists() //Could be improved
    }

    private func performSort() {
        daysList.sort { (m1, m2) -> Bool in
            m1 > m2
        }

        for day in daysList {
            var mealList = mealsPerDay.value[day]!
            mealList.sort { (m1, m2) -> Bool in
                m1.date.getHoursMinutes().localizedStandardCompare(m2.date.getHoursMinutes()) == .orderedAscending
            }
            mealsPerDay.value[day] = mealList
        }
    }

    //MARK: Table Delegate
    func numberOfSections() -> Int {
        return daysList.count
    }

    func nameForSection(in section: Int) -> String {
        let unformattedName = daysList[section]
        if let formattedName = unformattedName.translateIntoReadableDate() {
            return formattedName
        }
        return unformattedName
    }

    func numberOfRowsInSection(section: Int) -> Int {
        let name = daysList[section]
        guard let dayMeals = mealsPerDay.value[name] else { return 0 }

        return dayMeals.count
    }

    func mealPosition(for indexPath:IndexPath) -> MealPosition {

        let name = daysList[indexPath.section]
        let dayMeals = mealsPerDay.value[name]!

        if dayMeals.count == 1{
            return .only
        }

        if indexPath.item == 0 {
            return .first
        }

        if indexPath.item == dayMeals.count - 1 {
            return .last
        }

        return .middle
    }

    func mealFor(indexPath: IndexPath) -> Meal {
        let name = daysList[indexPath.section]
        let dayMeals = mealsPerDay.value[name]!

        return dayMeals[indexPath.item]
    }

    //Mark: - Calories
    func hasExceededCaloriesForDay(meal: Meal) -> Bool {
        guard let user = user, let calorieTotalForDay = caloriesPerDay[meal.date.getYearMonthDay()] else { return false }
        return user.dailyKcal < calorieTotalForDay
    }


    // MARK: - Meal Operations
    func fetchList(restart: Bool, success: @escaping ()->(), failure: @escaping (String)->()) {

        if throwErrors {
            failure("Error fetching meal list")
            return
        }

        self.isShowingFilteredMeals = false
        self.meals = apiMeals
        self.generateLists()
        success()
    }

    func fetchFilteredMealList(filterType: MealFilterType, lowerBound: Date, upperBound: Date, success: @escaping () -> (), failure: @escaping (String) -> ()) {
        if throwErrors {
            failure("Error fetching meal list")
            return
        }

        var filteredMeals:[Meal] = []

        let lowerBoundSetHoursToZero: Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: lowerBound) ?? lowerBound
        let upperBoundSetHoursToZero: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: upperBound) ?? upperBound

        if filterType == .date {
            filteredMeals = apiMeals.filter { $0.date >= lowerBoundSetHoursToZero && $0.date <= upperBoundSetHoursToZero }
        } else if filterType == .time {
            filteredMeals = apiMeals.filter { $0.date.time >= lowerBound.time && $0.date.time <= upperBound.time }
        }

        self.isShowingFilteredMeals = true
        self.meals = filteredMeals
        self.generateLists()
        success()
    }

    func fetchMultiFilteredMealList(lowerBound: Date, upperBound: Date, lowerHourBound: Date, upperHourBound: Date, success: @escaping () -> (), failure: @escaping (String) -> ()) {

        if throwErrors {
            failure("Error fetching meal list")
            return
        }

        var filteredMeals:[Meal] = []

        let lowerBoundSetHoursToZero: Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: lowerBound) ?? lowerBound
        let upperBoundSetHoursToZero: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: upperBound) ?? upperBound

        filteredMeals = apiMeals.filter { $0.date >= lowerBoundSetHoursToZero && $0.date <= upperBoundSetHoursToZero }
        filteredMeals = filteredMeals.filter { $0.date.time >= lowerHourBound.time && $0.date.time <= upperHourBound.time }

        self.isShowingFilteredMeals = true
        self.meals = filteredMeals
        self.generateLists()
        success()
    }

    func changeCalories(newCalories: Int, success: @escaping () -> (), failure: @escaping (String) -> ()) {
        self.user?.dailyKcal = newCalories
        self.user?.updateUser(success: {
            success()
        }, failure: { (error) in
            failure(error)
        })
    }

    func add(meal: Meal, completed: @escaping (String?)->()) {

        if throwErrors {
            completed(MealError.unableToAddMeal.handle())
            return
        }

        apiMeals.append(meal)
        self.addMealToList(meal: meal)
        self.generateLists()
        completed(nil)
    }

    func remove(meal: Meal, completed: @escaping (String?)->()) {

        if throwErrors {
            completed(MealError.unableToDeleteMeal.handle())
            return
        }

        if let idx = apiMeals.index(where: { $0.mealId == meal.mealId }) {
            self.apiMeals.remove(at: idx)
        }

        self.removeMealFromList(meal: meal)
        completed(nil)
    }



    func update(meal: Meal, completed: @escaping (String?)->()) {
        if let idx = apiMeals.index(where: { $0.mealId == meal.mealId }) {
            self.apiMeals[idx] = meal
        }
        self.removeMealFromList(meal: meal)
        self.addMealToList(meal: meal)
        self.generateLists()
        completed(nil)
    }

    init(user: AppUser?) {
        self.user = user ?? AppUser.getCurrentUser()
    }

    func logout(completed: @escaping () -> ()) {
        AppUser.getCurrentUser()?.logout {
            self.isShowingFilteredMeals = false
            self.meals = []
            self.generateLists()
            self.user = nil
            completed()
        }
    }
}
