//
//  File.swift
//  KcalLoggerTests
//
//  Created by Luís Machado on 15/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation
import UIKit
@testable import KcalLogger

//Singleton
class UserAPIMock: UserApiProtocol {

    var currentPassword: String = "123456"
    var userJson: Json = ["dailyCalories": 1000, "email": "user@user.com", "username": "username", "roles" : ["User", "User Agent", "Admin"]]

    var otherUsers:[String:Any] = ["001" : ["dailyCalories": 1234, "email": "use2r@user.com", "username": "username2", "roles" : ["User"]]]

    static let shared:UserAPIMock = UserAPIMock()
    var shouldFail: Bool = false
    var forgetToUpdateUser: Bool = false
    var currentUser: FirebaseUserData?

    init(shouldFail: Bool = false, forgetUser: Bool = false) {
        self.shouldFail = shouldFail
        self.forgetToUpdateUser = forgetUser
    }

    func isUserLoggedIn() -> FirebaseUserData? {
        return currentUser
    }

    func login(email: String, password: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        if shouldFail {
            failure(UserApiErrors.userHasNoId)
        } else {
            currentUser = forgetToUpdateUser ? nil : FirebaseUserData(username: "xpto", email: email, uid: "1234567")
            success()
        }
    }

    func registerUser(username: String, email: String, password: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        if shouldFail {
            failure(UserApiErrors.userHasNoId)
        } else {
            currentUser = forgetToUpdateUser ? nil : FirebaseUserData(username: username, email: email, uid: "1234567")
            success()
        }
    }

    func fetchUserData(for uid: String, success: @escaping ([String : Any]) -> (), failure: @escaping (Error) -> ()) {
        if shouldFail {
            failure(UserApiErrors.userHasNoId)
        } else {
            success(userJson)
        }
    }

    func recoverPassword(email: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        if shouldFail {
            failure(UserApiErrors.recoverError)
        } else {
            success()
        }
    }

    func checkCurrentPassword(oldPassword: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        if currentPassword == oldPassword {
            success()
        } else {
            failure(UserApiErrors.wrongPassword)
        }
    }

    func changePassword(newPassword: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        if shouldFail {
            failure(UserApiErrors.errorChangePassword)
        } else {
            currentPassword = newPassword
            success()
        }
    }


    func logoutUser(uid: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        if shouldFail {
            failure(UserApiErrors.userHasNoId)
        } else {
            currentUser = nil
            success()
        }
    }

    func fetchUserList(success: @escaping ([String : Any]) -> (), failure: @escaping (Error) -> ()) {
        if shouldFail {
            failure(UserApiErrors.userHasNoId)
        } else {
            success(otherUsers)
        }
    }

    func deleteUser(uid: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        if shouldFail {
            failure(UserApiErrors.userHasNoId)
        } else {
            otherUsers.removeValue(forKey: uid)
            success()
        }
    }

    func editUser(uid: String, userJson: Json,
                  success: @escaping () -> (),
                  failure: @escaping (Error) -> ()) {

        if shouldFail {
            failure(UserApiErrors.userHasNoId)
        } else {
            if otherUsers[uid] != nil {
                otherUsers[uid] = userJson
                success()
            } else {
                self.userJson = userJson
                success()
            }
        }
    }

    func checkIfEmailExists(email: String, success: @escaping (Bool) -> (), failure: @escaping (Error) -> ()) {

    }

    func createUserFromAdmin(username: String, email: String, password: String,
                             success: @escaping () -> (),
                             failure: @escaping(Error) -> ()) {
        
    }
}
