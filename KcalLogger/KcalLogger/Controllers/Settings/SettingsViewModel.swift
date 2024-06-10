//
//  SettingsViewModel.swift
//  KcalLogger
//
//  Created by Luís Machado on 14/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

final class SettingsViewModel {
    var user: AppUser?

    internal let title = "Settings"

    internal let deleteMessageHeader: String = "Delete Account"
    internal var deleteMessageMessageOne: String {
        return handlingOtherUser ? "Are you sure you want to delete \(username)'s account?" : "Are you sure you want to delete your account?"
    }
    internal let deleteMessageMessageTwo: String = "Are you sure? This action is irreversible!"
    internal let deleteMessageSuccess: String = "The account will be deleted"
    internal let deleteMessageError: String = "Error deleting account. Please try again later"

    internal var username: String {
        return user?.username ?? ""
    }

    internal var email: String {
        return user?.email ?? ""
    }

    internal var roles: String {
        if let userRoles = user?.roles {
            return userRoles.map{$0.rawValue}.joined(separator: ", ")
        } else {
            return Role.user.rawValue
        }
    }

    internal var dailyKcalGoal: String {
        return String(user?.dailyKcal ?? 0)
    }

    internal var handlingOtherUser: Bool {
        if let user = user, let currentUser = AppUser.getCurrentUser() {
            return user.uid != currentUser.uid
        }
        return false
    }

    internal var shouldDisplayAdmin: Bool {
        if let user = AppUser.getCurrentUser(), !handlingOtherUser  {
            return user.roles.contains(.userAgent) || user.roles.contains(.admin)
        }
        return false
    }

    internal var shouldEditMeals: Bool {
        if let user = AppUser.getCurrentUser(), handlingOtherUser  {
            return user.roles.contains(.admin)
        }
        return false
    }

    internal var canEditRoles: Bool {
        if let user = user, let myself = AppUser.getCurrentUser() {
            if !myself.roles.contains(.admin) && user.roles.contains(.admin) { //Only case is when user is editing a higher role than himself
                return false
            }
            return true
        }
        return false
    }

    func shouldDisplay(section: Int) -> Bool {
        if section == 2 && handlingOtherUser {
            return false
        }

        if section == 3 && !shouldDisplayAdmin {
            return false
        }

        if section == 4 && !shouldEditMeals {
            return false
        }

        return true
    }

    func changeUsername(newUsername: String, success: @escaping ()->(), failure: @escaping (String)->()) {
        self.user?.username = newUsername
        self.user?.updateUser(success: {
            success()
        }, failure: { (error) in
            failure(error)
        })
    }

    func changeCalories(newCalories: Int, success: @escaping ()->(), failure: @escaping (String)->()) {
        self.user?.dailyKcal = newCalories
        self.user?.updateUser(success: {
            success()
        }, failure: { (error) in
            failure(error)
        })
    }

    func deleteUser(success: @escaping ()->(), failure: @escaping (String)->()) {
        self.user?.delete(success: {
            success()
        }, failure: { (error) in
            failure(error)
        })
    }

    init(user: AppUser?) {
        self.user = user ?? AppUser.getCurrentUser()
    }
}
