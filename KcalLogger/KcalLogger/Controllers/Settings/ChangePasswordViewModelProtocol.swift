//
//  ChangePasswordViewModelProtocol.swift
//  KcalLogger
//
//  Created by Luís Machado on 22/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

protocol ChangePasswordViewModelProtocol {

    var user: AppUser? { get set }
    var title: String { get }

    var passwordOne: Dynamic<String> { get set }
    var passwordTwo: Dynamic<String> { get set }
    var oldPasswordScreen: Dynamic<Bool> { get set }

    var isOldPassword: Bool { get }

    func setPasswords(pw1: String, pw2: String)
    func setOldPasswordScreen(value: Bool)

    func checkCurrentPassword(success: @escaping ()->(), failure: @escaping (String)->())
    func updatePassword(success: @escaping ()->(), failure: @escaping (String)->())
    
    var isFormValid: Bool  { get }
    var isOldPasswordValid: Bool { get }
    var areNewPasswordsEqual: Bool { get }

    var oldPasswordBadFormat: String { get }
    var passwordsDoNoMatch: String { get }
    var updateSuccess: String { get }
    var oldPasswordLabel: String { get }
    var oldHeader: String { get }
    var newPasswordLabel: String { get }
    var repeatNewPasswordLabel: String { get }
    var newHeader: String { get }
}
