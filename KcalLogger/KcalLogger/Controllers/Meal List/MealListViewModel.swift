//
//  MealListViewModel.swift
//  KcalLogger
//
//  Created by Luís Machado on 15/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

final class MealListsViewModel: MealListViewModelProtocol {

    weak var user: AppUser?

    internal let title = "My Calories Logger"

    internal var meals: [Meal] = []
    internal var daysList: [String] = []
    internal var caloriesPerDay: [String: Int] = [:]
    internal var mealsPerDay: Dynamic<[String: [Meal]]> = Dynamic([:])

    internal var isFetchingMore: Bool = false
    internal var idxPathsToAdd: Dynamic<[IndexPath]> = Dynamic([])

    internal var lastTimestamp: Int?
    internal var meal5FromEndId: String?

    var isShowingFilteredMeals: Bool = false

    internal var isMyself: Bool {
        if let user = user, let myself = AppUser.getCurrentUser() {
            return user.uid == myself.uid
        }
        return true
    }

    private func generateLists() {

        daysList.removeAll()
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
        }

        performSort()
    }

    private func removeMealFromList(meal: Meal) {
        if let idx = meals.index(where: { $0.mealId ?? "0" == meal.mealId ?? "0" }) {
            meals.remove(at: idx)
            generateLists()
        }
    }

    private func addMealToList(meal: Meal) -> IndexPath? {
        meals.append(meal)

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

        performSort()

        if let section = daysList.index(where: { $0 == key }) {
            let mealList = mealsPerDay.value[key]!
            if let idx = mealList.index(where: { $0.mealId ?? "" == meal.mealId ?? "" }) {
                return IndexPath(item: idx, section: section)
            }
        }

        return nil
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
        let meal = dayMeals[indexPath.item]

        if let checkMealId = meal5FromEndId, let currentId = meal.mealId, checkMealId == currentId {
            self.fetchList(restart: false, success: {
            }) { (_) in
            }
        }

        return meal
    }

    // MARK: - Calories
    func hasExceededCaloriesForDay(meal: Meal) -> Bool {
        guard let user = user, let calorieTotalForDay = caloriesPerDay[meal.date.getYearMonthDay()] else { return false }
        return user.dailyKcal < calorieTotalForDay
    }


    // MARK: - Meal Operations
    func fetchList(restart: Bool, success: @escaping ()->(), failure: @escaping (String)->()) {
        if restart {
            self.lastTimestamp = nil
        }

        isFetchingMore = !restart

        user?.fetchItemList(lastKey: self.lastTimestamp, success: { (mealList) in
            self.isShowingFilteredMeals = false

            if restart { // First fetch (first page)
                self.user?.fetchCalorieList(showLoadingWheel: restart, success: { (calorieList) in
                    self.isFetchingMore = false
                    self.caloriesPerDay = calorieList as! [String : Int]
                    self.processFetchedMeals(restart: restart, mealList: mealList)
                    success()
                }, failure: { (error) in
                    failure(error)
                    self.isFetchingMore = false
                })
            } else { // First fetch (first page)
                self.processFetchedMeals(restart: restart, mealList: mealList)
                success()
                self.isFetchingMore = false
            }

        }, failure: { (error) in
            self.isFetchingMore = false
            failure(error)
        })
    }

    private func processFetchedMeals(restart: Bool, mealList: [Meal]) {
        var mealListSorted = mealList.sorted(by: { (m1, m2) -> Bool in
            return m1.date < m2.date
        })

        if let lastMeal = mealListSorted.last {
            self.lastTimestamp = -Int(lastMeal.date.timeIntervalSince1970)
        }

        if mealListSorted.count == Configs.shared.mealListPageLength + 1 { // plus one to get next key
            self.meal5FromEndId = mealListSorted[mealListSorted.count - 10].mealId
        } else if mealListSorted.count > 0 {
            self.meal5FromEndId = nil
        }

        if mealListSorted.count > 0 && mealListSorted.count == Configs.shared.mealListPageLength + 1 {
            mealListSorted.removeLast()
        }

        if !restart {
            self.meals.append(contentsOf: mealListSorted)
        } else {
            self.meals = mealListSorted
        }

        if restart {
            self.generateLists()
        } else {
            var idxPathList: [IndexPath] = []
            mealListSorted.forEach { (meal) in
                if let idxPath = addMealToList(meal: meal) {
                    idxPathList.append(idxPath)
                }
            }
            self.idxPathsToAdd.value = idxPathList
        }
    }

    func fetchFilteredMealList(filterType: MealFilterType, lowerBound: Date, upperBound: Date,
                               success: @escaping ()->(), failure: @escaping (String)->()) {

        user?.fetchFilteredMealList(filterType: filterType, lowerBound: lowerBound, upperBound: upperBound, success: { (mealList) in
            self.user?.fetchCalorieList(success: { (calorieList) in
                self.caloriesPerDay = calorieList as! [String : Int]
                self.isShowingFilteredMeals = true
                self.meals = mealList
                self.generateLists()
                success()
            }, failure: { (error) in
                failure(error)
            })
        }, failure: { (error) in
            failure(error)
        })
    }

    func fetchMultiFilteredMealList(lowerBound: Date, upperBound: Date, lowerHourBound: Date, upperHourBound: Date,
                                    success: @escaping ()->(), failure: @escaping (String)->()) {

        user?.multiFilter(lowerDate: lowerBound, upperDate: upperBound, lowerHour: lowerHourBound, upperHour: upperHourBound, success: { (mealList) in
            self.user?.fetchCalorieList(success: { (calorieList) in
                self.caloriesPerDay = calorieList as! [String : Int]
                self.isShowingFilteredMeals = true
                self.meals = mealList
                self.generateLists()
                success()
            }, failure: { (error) in
                failure(error)
            })
        }, failure: { (error) in
            failure(error)
        })
    }

    func add(meal: Meal, completed: @escaping (String?)->()) {
        guard let user = user else {
            completed(MealError.unableToAddMeal.handle())
            return
        }

        user.add(meal: meal, success: {
            // If filter is active we disable it (improve this to only disable if the new meal would be outside the filter)
            if self.isShowingFilteredMeals {
                self.fetchList(restart: true, success: {
                    completed(nil)
                }, failure: { (error) in
                    completed(error)
                })
            } else {
                self.user?.fetchCalorieList(success: { (calorieList) in
                    self.caloriesPerDay = calorieList as! [String : Int]
                    _ = self.addMealToList(meal: meal)
                    completed(nil)
                }, failure: { (error) in
                    completed(error)
                })
            }

        }) { (error) in
            completed(error)
        }
    }

    func remove(meal: Meal, completed: @escaping (String?)->()) {
        guard let user = user else {
            completed(MealError.unableToDeleteMeal.handle())
            return
        }

        user.delete(meal: meal, success: {
            self.user?.fetchCalorieList(success: { (calorieList) in
                self.caloriesPerDay = calorieList as! [String : Int]
                self.removeMealFromList(meal: meal)
                completed(nil)
            }, failure: { (error) in
                completed(error)
            })
        }) { (error) in
            completed(error)
        }
    }

    func update(meal: Meal, completed: @escaping (String?)->()) {
        // If filter is active we disable it (improve this to only disable if the edited meal would be outside the filter)
        if self.isShowingFilteredMeals {
            self.fetchList(restart: true, success: {}, failure: { (_) in })
        } else {
            self.user?.fetchCalorieList(success: { (calorieList) in
                self.caloriesPerDay = calorieList as! [String : Int]
                self.removeMealFromList(meal: meal)
                _ = self.addMealToList(meal: meal)
                completed(nil)
            }, failure: { (error) in
                completed(error)
            })
        }
    }

    init(user: AppUser?) {
        self.user = user ?? AppUser.getCurrentUser()
    }

    func logout(completed: @escaping ()->()) {
        AppUser.getCurrentUser()?.logout {
            self.isShowingFilteredMeals = false
            self.meals = []
            self.generateLists()
            self.user = nil
            print("DashboardVC: User did logout")
            completed()
        }
    }

    func changeCalories(newCalories: Int, success: @escaping ()->(), failure: @escaping (String)->()) {
        self.user?.dailyKcal = newCalories
        self.user?.updateUser(success: {
            success()
        }, failure: { (error) in
            failure(error)
        })
    }
}

