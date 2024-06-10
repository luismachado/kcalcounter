//
//  Configs.swift
//  KcalLogger
//
//  Created by Luís Machado on 14/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class Configs: NSObject {

    static let shared = Configs()

    let firebaseMealListId = "meal_list"
    let firebaseUserListId = "users"
    let firebaseUsersToDeleteListId = "users_to_delete"
    let firebaseUsersToCreateListId = "users_to_create"

    let mealListPageLength: UInt = 30

    let navigationColor = UIColor.rgb(red: 44, green: 62, blue: 80)
    let backgroundColor = UIColor.rgb(red: 52, green: 73, blue: 94)

    let buttonColor = UIColor.rgb(red: 26, green: 188, blue: 156)
    let buttonColorDisabled = UIColor.rgb(red: 142, green: 160, blue: 157)

    let darkGreen = UIColor.rgb(red: 33, green: 160, blue: 133)
}

