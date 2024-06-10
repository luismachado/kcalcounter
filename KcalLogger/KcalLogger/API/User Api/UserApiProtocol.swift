//
//  UserApiProtocol.swift
//  KcalLogger
//
//  Created by Luís Machado on 15/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

enum UserApiErrors: Error {
    case noUserLoggedIn
    case userHasNoId
    case unableToFetchListUsers
    case wrongPassword
    case recoverError
    case errorChangePassword

    func handle() -> String {
        switch self {
        case .noUserLoggedIn:
            return "No user logged in"
        case .userHasNoId:
            return "User had no ID"
        case .unableToFetchListUsers:
            return "User list could not be retrieved."
        case .wrongPassword:
            return "Wrong password"
        case .errorChangePassword:
            return "Error changing password"
        case .recoverError:
            return "Error recovering password"
        }
    }
}

struct FirebaseUserData {
    let username: String
    let email: String
    let uid: String
}

protocol UserApiProtocol {

    func isUserLoggedIn() -> FirebaseUserData?

    func login(email:String, password:String,
               success: @escaping () -> (),
               failure: @escaping(Error) -> ())

    func fetchUserData(for uid: String, success: @escaping ([String: Any]) -> (),
                       failure: @escaping (Error) -> ())

    func editUser(uid: String, userJson: Json,
                  success: @escaping () -> (),
                  failure: @escaping (Error) -> ())

    func registerUser(username: String, email: String, password: String,
                      success: @escaping () -> (),
                      failure: @escaping(Error) -> ())

    func checkCurrentPassword(oldPassword: String,
                              success: @escaping () -> (),
                              failure: @escaping(Error) -> ())

    func changePassword(newPassword: String,
                        success: @escaping () -> (),
                        failure: @escaping(Error) -> ())

    func recoverPassword(email: String,
                         success: @escaping () -> (),
                         failure: @escaping(Error) -> ())

    func deleteUser(uid: String,
                    success: @escaping () -> (),
                    failure: @escaping(Error) -> ())

    func logoutUser(uid:String,
                    success: @escaping () -> (),
                    failure: @escaping(Error) -> ())

    func fetchUserList(success: @escaping ([String : Any]) -> (),
                       failure: @escaping (Error) -> ())

    func checkIfEmailExists(email: String,
                            success: @escaping (Bool) -> (),
                            failure: @escaping (Error) -> ())

    func createUserFromAdmin(username: String, email: String, password: String,
                             success: @escaping () -> (),
                             failure: @escaping(Error) -> ())
}
