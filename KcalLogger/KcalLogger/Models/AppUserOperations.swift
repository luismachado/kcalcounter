//
//  AppUserOperations.swift
//  KcalLogger
//
//  Created by Luís Machado on 16/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import KRProgressHUD

// MARK: Admin Operations
extension AppUser {

    func fetchUserList(success: @escaping ([AppUser])->(), failure: @escaping (String)->()) {

        KRProgressHUD.show()
        AppUser.userApi.fetchUserList(success: { (userListJson) in
            KRProgressHUD.dismiss()
            let idList = Array(userListJson.keys)
            success(idList.compactMap { AppUser(uid: $0, email: "", json: userListJson[$0] as! [String: Any]) })
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(handleErrors(error: error))
        }
    }
}

extension AppUser {

    // Fetch meal list
    func fetchItemList(lastKey: Any?, success: @escaping ([Meal])->(), failure: @escaping (String)->()) {

        if lastKey == nil {
            KRProgressHUD.show()
        }

        AppUser.mealApi.getMealListForUserWith(id: self.uid, lastKey: lastKey, success: { (mealListJson) in
            KRProgressHUD.dismiss()
            self.mealList.removeAll()
            let idList = Array(mealListJson.keys)
            let temporaryList = idList.compactMap { Meal(mealId: $0, json: mealListJson[$0] as! [String: Any]) }

            success(temporaryList)
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(handleErrors(error: error))
        }
    }

    // Fetch calorie list
    func fetchCalorieList(showLoadingWheel: Bool = false, success: @escaping ([String:Any])->(), failure: @escaping (String)->()) {

        if showLoadingWheel {
            KRProgressHUD.show()
        }

        AppUser.mealApi.getCalories(uid: self.uid, success: { (calorieList) in
            KRProgressHUD.dismiss()
            success(calorieList)
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(handleErrors(error: error))
        }
    }

    func fetchFilteredMealList(filterType: MealFilterType, lowerBound: Date, upperBound: Date,
                                       success: @escaping ([Meal])->(), failure: @escaping (String)->()) {

        KRProgressHUD.show()

        let lowerBoundSetHoursToZero: Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: lowerBound) ?? lowerBound
        let upperBoundSetHoursToZero: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: upperBound) ?? upperBound

        let lowerBoundString: Any = filterType == .date ? Int(lowerBoundSetHoursToZero.timeIntervalSince1970) : lowerBound.getHoursMinutes()
        let upperBoundString: Any = filterType == .date ? Int(upperBoundSetHoursToZero.timeIntervalSince1970) : upperBound.getHoursMinutes()

        AppUser.mealApi.getFilteredtMealListForUserWith(id: self.uid, filterType: filterType, lowerBound: lowerBoundString, upperBound: upperBoundString, success: { (mealListJson) in
            KRProgressHUD.dismiss()
            self.mealList.removeAll()
            let idList = Array(mealListJson.keys)
            success(idList.compactMap { Meal(mealId: $0, json: mealListJson[$0] as! [String: Any]) })
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(handleErrors(error: error))
        }
    }

    func multiFilter(lowerDate: Date, upperDate: Date, lowerHour: Date, upperHour: Date,
                    success: @escaping ([Meal])->(), failure: @escaping (String)->()) {

        fetchFilteredMealList(filterType: .date, lowerBound: lowerDate, upperBound: upperDate, success: { (mealList) in
            let filteredMealListByHour = mealList.filter { $0.date.time >= lowerHour.time && $0.date.time <= upperHour.time }
            success(filteredMealListByHour)
        }) { (error) in
            failure(error)
        }
    }

    // Add Meal
    func add(meal: Meal, success: @escaping ()->(), failure: @escaping (String)->()) {

        AppUser.mealApi.addMeal(uid: self.uid, mealJson: meal.toJson(), gotId: { (mealId) in
            if let mealId = mealId {
                meal.mealId = mealId
                self.mealList.append(meal)
            } else {
                failure(handleErrors(error: MealApiError.itemHasNoId))
            }
        }, success: {
            //OFFLINE SUCCESS -> success() on above clause -> impacts removing the filter after adding a meal
             success()
        }) { (error) in
            failure(handleErrors(error: error))
        }
    }



    func delete(meal: Meal, success: @escaping ()->(), failure: @escaping (String)->()) {

        guard let mealId = meal.mealId else {
            failure(handleErrors(error: MealApiError.itemHasNoId))
            return
        }

        AppUser.mealApi.deleteMeal(uid: self.uid, mealId: mealId, success: {
            if let idx = self.mealList.index(where: { $0.mealId == mealId }) {
                self.mealList.remove(at: idx)
            }
            success()
        }) { (error) in
            failure(handleErrors(error: error))
        }
    }
}
