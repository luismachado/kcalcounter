//
//  MealApi.swift
//  KcalLogger
//
//  Created by Luís Machado on 16/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation
import Firebase

//Singleton
class MealApi: MealApiProtocol {

    static let shared:MealApi = MealApi()
    lazy var functions = Functions.functions()

    func getCalories(uid: String,
                     success: @escaping ([String : Any]) -> (),
                     failure: @escaping(Error) -> ()) {

        functions.httpsCallable("getCaloriesUser").call(["userId": uid]) { (result, error) in

            if let error = error {
                failure(error)
                return
            }

            if let resulJson = result?.data as? [String: Any] {
                success(resulJson)
            } else {
                success([:])
            }
        }
    }

    func getMealListForUserWith(id uid: String, lastKey: Any?,
                                success: @escaping ([String : Any]) -> (),
                                failure: @escaping (Error) -> ()) {

        var mealList = Database.database().reference().child(Configs.shared.firebaseMealListId).child(uid).queryOrdered(byChild: "dateOrder")

        if let lastKey = lastKey {
            mealList = mealList.queryEnding(atValue:lastKey).queryLimited(toLast: Configs.shared.mealListPageLength+1)
        } else {
            mealList = mealList.queryLimited(toLast: Configs.shared.mealListPageLength+1)
        }

        mealList.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                success([:])
                return
            }

            guard let todoItemJsonList = snapshot.value as? [String: Any] else {
                failure(MealApiError.unableToFetchList)
                return
            }
            success(todoItemJsonList)
        }) { (error) in
            failure(error)
        }
    }

    func getFilteredtMealListForUserWith(id uid: String, filterType: MealFilterType, lowerBound: Any, upperBound: Any,
                                         success: @escaping ([String : Any]) -> (),
                                         failure: @escaping (Error) -> ()) {

        let mealList = Database.database().reference().child(Configs.shared.firebaseMealListId).child(uid)
        let query = mealList.queryOrdered(byChild: filterType.rawValue).queryStarting(atValue: lowerBound).queryEnding(atValue: upperBound)

        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                success([:])
                return
            }

            guard let todoItemJsonList = snapshot.value as? [String: Any] else {
                failure(MealApiError.unableToFetchList)
                return
            }
            success(todoItemJsonList)
        }) { (error) in
            failure(error)
        }
    }

    func addMeal(uid: String, mealJson: Json,
                 gotId: @escaping (_ id: String?) -> (),
                 success: @escaping () -> (),
                 failure: @escaping (Error) -> ()) {

        let mealListRef = Database.database().reference().child(Configs.shared.firebaseMealListId).child(uid)
        let mealRef = mealListRef.childByAutoId()


        gotId(mealRef.key)

        mealRef.updateChildValues(mealJson) { (err, ref) in
            if let err = err {
                failure(err)
                return
            }

            success()
        }
    }

    func editMeal(uid: String, mealId: String?, mealJson: Json,
                  success: @escaping () -> (),
                  failure: @escaping (Error) -> ()) {

        guard let mealId = mealId else {
            failure(MealApiError.itemHasNoId)
            return
        }

        let mealRef = Database.database().reference().child(Configs.shared.firebaseMealListId).child(uid).child(mealId)

        mealRef.setValue(mealJson) { (err, ref) in
            if let err = err {
                failure(err)
                return
            }

            success()
        }
    }

    func deleteMeal(uid: String, mealId: String,
                    success: @escaping () -> (),
                    failure: @escaping(Error) -> ()) {

        let mealRef = Database.database().reference().child(Configs.shared.firebaseMealListId).child(uid).child(mealId)

        mealRef.removeValue { (err, ref) in
            if let err = err {
                failure(err)
                return
            }
            success()
        }
    }
}
