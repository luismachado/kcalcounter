//
//  ChangePasswordViewModel.swift
//  KcalLogger
//
//  Created by Luís Machado on 22/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

final class ChangePasswordViewModel: ChangePasswordViewModelProtocol {
    var user: AppUser?

    internal let title = "Change Password"

    internal var passwordOne: Dynamic<String>
    internal var passwordTwo: Dynamic<String>
    internal var oldPasswordScreen: Dynamic<Bool>

    internal var oldPasswordBadFormat: String = "Password must be filled out (at least 6 characters)"
    internal var passwordsDoNoMatch: String = "Passwords do not match"
    internal var updateSuccess: String = "Password has been updated successfully."
    internal var oldPasswordLabel: String = "old password"
    internal var oldHeader: String = "First enter your current password to set a new password."
    internal var newPasswordLabel: String = "new password"
    internal var repeatNewPasswordLabel: String = "repeat new password"
    internal var newHeader: String = "Now enter the new password and confirm it again."

    internal var isOldPassword: Bool {
        return oldPasswordScreen.value
    }

    internal var isFormValid: Bool {
        return passwordOne.value.count >= 6 && (oldPasswordScreen.value || passwordTwo.value.count >= 6)
    }

    internal var isOldPasswordValid: Bool {
        return passwordOne.value.count >= 6
    }

    internal var areNewPasswordsEqual: Bool {
        return passwordOne.value == passwordTwo.value
    }

    func setPasswords(pw1: String, pw2: String) {
        self.passwordOne.value = pw1
        self.passwordTwo.value = pw2
    }

    func setOldPasswordScreen(value: Bool) {
        self.oldPasswordScreen.value = value
        setPasswords(pw1: "", pw2: "")
    }

    func checkCurrentPassword(success: @escaping ()->(), failure: @escaping (String)->()) {
        user?.checkCurrentPassword(oldPassword: passwordOne.value, success: {
            success()
        }, failure: { (error) in
            failure(error)
        })
    }

    func updatePassword(success: @escaping ()->(), failure: @escaping (String)->()) {
        user?.updatePassword(newPassword: passwordOne.value, success: {
            success()
        }, failure: { (error) in
            failure(error)
        })
    }

    init(user: AppUser?) {
        self.user = user ?? AppUser.getCurrentUser()
        self.passwordOne = Dynamic("")
        self.passwordTwo = Dynamic("")
        self.oldPasswordScreen = Dynamic(true)
    }
}


