//
//  RegistrationViewModel.swift
//  KcalLogger
//
//  Created by Luís Machado on 23/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

final class RegistrationViewModel {
    var user: AppUser? 

    internal var email: Dynamic<String>
    internal var username: Dynamic<String>
    internal var passwordOne: Dynamic<String>
    internal var passwordTwo: Dynamic<String>

    internal let title = "Registration"

    internal var isAdmin: Bool {
        return user != nil
    }

    internal var signupButtonTitle: String {
        return isAdmin ? "Create User" : "Sign Up"
    }

    func checkFields() -> String? {
        var errorMessage: String? = nil

        if email.value.count == 0 || !email.value.isValidEmail() {
            errorMessage = "Email is empty or incorrectly formatted"
        }

        if errorMessage == nil, username.value.count < 6 {
            errorMessage = "Username must be longer than 6 characters"
        }

        if errorMessage == nil, passwordOne.value.count < 6 {
            errorMessage = "Password has to have a minimum of 6 characters"
        }

        if errorMessage == nil, passwordOne.value != passwordTwo.value {
            errorMessage = "Passwords should match"
        }

        return errorMessage
    }

    func registerUser(success: @escaping (String)->(), failure: @escaping (String)->()) {

        if isAdmin {
            AppUser.registerAdmin(username: username.value, email: email.value, password: passwordOne.value, success: { (uid) in
                success(uid)
            }) { (error) in
                failure(error)
            }
        } else {
            AppUser.register(username: username.value, email: email.value, password: passwordOne.value, success: { (uid) in
                success(uid)
            }) { (error) in
                failure(error)
            }
        }
    }

    init(user: AppUser?) {
        self.user = user ?? AppUser.getCurrentUser()
        email = Dynamic("")
        username = Dynamic("")
        passwordOne = Dynamic("")
        passwordTwo = Dynamic("")
    }
}
