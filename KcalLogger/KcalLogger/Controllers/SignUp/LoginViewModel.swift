//
//  LoginViewModel.swift
//  KcalLogger
//
//  Created by Luís Machado on 25/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

final class LoginViewModel {

    internal var email: Dynamic<String>
    internal var password: Dynamic<String>

    internal let title = "Login"

    func checkFields() -> String? {
        var errorMessage: String? = nil

        if email.value.count == 0 || !email.value.isValidEmail() {
            errorMessage = "Email is empty or incorrectly formatted"
        }

        if errorMessage == nil, password.value.count < 6 {
            errorMessage = "Password has to have a minimum of 6 characters"
        }

        return errorMessage
    }

    func recoverPassword(success: @escaping ()->(), failure: @escaping (String)->()) {
        AppUser.userApi.recoverPassword(email: email.value, success: {
            success()
        }, failure: { (error) in
            failure(error.localizedDescription)
        })
    }

    func login(success: @escaping ()->(), failure: @escaping (String)->()) {
        AppUser.logIn(email: email.value, password: password.value, success: { (userId) in
            success()
        }) { (errorMessage) in
            failure(errorMessage)
        }
    }

    init() {
        email = Dynamic("")
        password = Dynamic("")
    }
}
