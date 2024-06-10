//
//  CreateEditMealViewModelProtocol.swift
//  KcalLogger
//
//  Created by Luís Machado on 17/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

protocol CreateEditMealViewModelProtocol {

    var meal: Meal! { get set }
    var title: String { get }

    var description: Dynamic<String> { get }
    var calories: Dynamic<String> { get }
    var date: Dynamic<String> { get }
    var time: Dynamic<String> { get }

    var isNewMeal: Bool { get }
    var isMealValid: Bool { get }

    func set(description: String)
    func set(date: Date)
    func set(calories: String)
}
