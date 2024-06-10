//
//  RolesViewModel.swift
//  KcalLogger
//
//  Created by Luís Machado on 21/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

final class RolesViewModel {
    var user: AppUser? {
        didSet {
            guard let user = user else { return }
            self.roleSelected[0] = true
            self.roleSelected[1] = user.roles.contains(.userAgent)
            self.roleSelected[2] = user.roles.contains(.admin)
        }
    }

    var roles: [Role] = [Role.user, Role.userAgent, Role.admin]
    var roleSelected: [Bool] = [true, false, false]

    internal let title = "Roles"

    func roleFor(row: Int) -> String {
        return roles[row].rawValue
    }

    func isRoleSelected(row: Int) -> Bool {
        return roleSelected[row]
    }

    func selectUnselectRow(row: Int) {
        if row == 0 {
            return
        }

        if row == 1 {
            if roleSelected[1] == true {
                roleSelected[1] = false
                roleSelected[2] = false
            } else {
                roleSelected[1] = true
            }
        }

        if row == 2 {
            if roleSelected[2] == true {
                roleSelected[2] = false
            } else {
                roleSelected[2] = true
                roleSelected[1] = true
            }
        }
    }

    func changeRoles(success: @escaping ()->(), failure: @escaping (String)->()) {

        var newRoles:[Role] = []
        for idx in 0...roles.count - 1 {
            if roleSelected[idx] {
                newRoles.append(roles[idx])
            }
        }

        self.user?.roles = newRoles
        self.user?.updateUser(success: {
            success()
        }, failure: { (error) in
            failure(error)
        })
    }

    

    init(user: AppUser?) {
        self.user = user ?? AppUser.getCurrentUser()
    }
}

