//
//  AppUser.swift
//  KcalLogger
//
//  Created by Luís Machado on 12/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit
import KRProgressHUD

enum Role: String {
    case user = "User"
    case userAgent = "User Agent"
    case admin = "Admin"

    static func getRole(from roleDescription: String) -> Role? {
        return Role(rawValue: roleDescription)
    }
}

class AppUser {

    var uid: String
    var username: String
    var email: String
    var dailyKcal: Int
    var roles: [Role]

    var mealList:[Meal]

    private static var currentUser: AppUser?
    static var userApi:UserApiProtocol = UserApi.shared
    static var mealApi:MealApiProtocol = MealApi.shared

    static func isUserLoggedIn(success: @escaping (String?)->()) {

        if let firebaseUser = userApi.isUserLoggedIn(), AppUser.currentUser == nil {
            userApi.fetchUserData(for: firebaseUser.uid, success: { (userJson) in
                AppUser.currentUser = AppUser(uid: firebaseUser.uid, email: firebaseUser.email, json: userJson)
                success(AppUser.currentUser?.uid)
            }) { (error) in
                success(nil)
            }
        } else {
            success(AppUser.currentUser?.uid)
        }
    }

    static func getCurrentUser() -> AppUser? {
        return currentUser
    }

    init(uid: String, email: String, json: [String: Any]) {
        self.uid = uid
        self.username = json["username"] as? String ?? "No Username"
        self.email = email
        self.dailyKcal = json["dailyCalories"]  as? Int ?? 0
        self.roles = []
        self.mealList = []

        if let roleList = json["roles"] as? [String] {
            for roleDescription in roleList {
                guard let role = Role.getRole(from: roleDescription) else { continue }
                self.roles.append(role)
            }
        }

        if username.isEmpty, let jsonUsername = json["username"] as? String {
            self.username = jsonUsername
        }

        if email.isEmpty, let jsonEmail  = json["email"] as? String {
            self.email = jsonEmail
        }

        if self.roles.count == 0 {
            // If no info provided role defaults to normal user
            self.roles.append(.user)
        }
    }

    // MARK: - JSON Converter
    func toJson() -> Json {
        return [
            "dailyCalories": self.dailyKcal,
            "email": self.email,
            "username" : self.username,
            "roles": self.roles.map { $0.rawValue }
        ]
    }

    // MARK: - Firebase operations
    // Login
    static func logIn(email: String, password: String, success: @escaping (String)->(), failure: @escaping (String)->()) {
        KRProgressHUD.show()
        AppUser.currentUser = nil

        userApi.login(email: email, password: password, success: { () in
            KRProgressHUD.dismiss()
            isUserLoggedIn(success: { (uid) in
                if let uid = uid {
                    success(uid)
                } else {
                    failure("Error while logging in")
                }
            })
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(getFirebaseError(error: error) ?? (error as NSError).domain)
        }
    }

    // Register
    static func register(username: String, email: String, password: String, success: @escaping (String)->(), failure: @escaping (String)->()) {
        KRProgressHUD.show()

        userApi.registerUser(username: username, email: email, password: password, success: {
            KRProgressHUD.dismiss()
            isUserLoggedIn(success: { (uid) in
                if let uid = uid {
                    success(uid)
                } else {
                    failure("Registration error. Please try again.")
                }
            })
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(getFirebaseError(error: error) ?? (error as NSError).domain)
        }
    }

    // Register Admin
    static func registerAdmin(username: String, email: String, password: String, success: @escaping (String)->(), failure: @escaping (String)->()) {
        KRProgressHUD.show()

        userApi.checkIfEmailExists(email: email, success: { (exists) in
            if exists {
                KRProgressHUD.dismiss()
                failure("Email is already in use")
            } else {
                userApi.createUserFromAdmin(username: username, email: email, password: password, success: {
                    KRProgressHUD.dismiss()
                    success("")
                }, failure: { (error) in
                    KRProgressHUD.dismiss()
                    failure(getFirebaseError(error: error) ?? (error as NSError).domain)
                })
            }
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(getFirebaseError(error: error) ?? (error as NSError).domain)
        }
    }

    static private func registerUserInDatabaseWithUid(uid: String, values: [String : AnyObject], completion: @escaping () -> (), failure: @escaping (String)->()) {
        
    }

    //Edit
    func updateUser(success: @escaping ()->(), failure: @escaping (String)->()) {
        // Improvement: function should receive new value (instead of editing the object directly). That way
        // we can backup the old value and set it back if the api fails

        KRProgressHUD.show()
        saveUser(success: {
            KRProgressHUD.dismiss()
            success()
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(handleErrors(error: error))
        }
    }

    private func saveUser(success: @escaping ()->(), failure: @escaping (Error)->()) {
        AppUser.userApi.editUser(uid: self.uid, userJson: self.toJson(), success: {
            success()
        }) { (error) in
            failure(error)
        }
    }

    func checkCurrentPassword(oldPassword: String, success: @escaping ()->(), failure: @escaping (String)->()) {
        KRProgressHUD.show()

        AppUser.userApi.checkCurrentPassword(oldPassword: oldPassword, success: {
            KRProgressHUD.dismiss()
            success()
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(handleErrors(error: error))
        }
    }

    func updatePassword(newPassword: String, success: @escaping ()->(), failure: @escaping (String)->()) {
        KRProgressHUD.show()

        AppUser.userApi.changePassword(newPassword: newPassword, success: {
            KRProgressHUD.dismiss()
            success()
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(handleErrors(error: error))
        }
    }

    func delete(success: @escaping ()->(), failure: @escaping (String)->()) {
        KRProgressHUD.show()

        AppUser.userApi.deleteUser(uid: self.uid, success: {
            KRProgressHUD.dismiss()
            success()
        }) { (error) in
            KRProgressHUD.dismiss()
            failure(handleErrors(error: error))
        }
    }
    
    //Logout
    func logout(completion: @escaping ()->()) {
        guard let uid = AppUser.userApi.isUserLoggedIn()?.uid else {
            completion()
            return
        }

        AppUser.currentUser = nil

        UserApi.shared.logoutUser(uid: uid, success: {
            completion()
        }) { (error) in
            print(error)
            completion()
        }
    }
}
