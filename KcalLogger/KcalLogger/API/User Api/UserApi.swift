//
//  UserApi.swift
//  KcalLogger
//
//  Created by Luís Machado on 14/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation
import Firebase

//Singleton
class UserApi: UserApiProtocol {

    static let shared:UserApi = UserApi()

    func isUserLoggedIn() -> FirebaseUserData? {

        if let firebaseUser = Auth.auth().currentUser {
            return FirebaseUserData(username: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "", uid: firebaseUser.uid)
        }

        return nil
    }

    func login(email:String, password:String,
               success: @escaping () -> (),
               failure: @escaping(Error) -> ()) {

        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in

            if let error = error {
                failure(error)
            }

            success()
        }
    }

    func registerUser(username: String, email: String, password: String,
                      success: @escaping () -> (),
                      failure: @escaping(Error) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in

            if let error = error {
                failure(error)
                return
            }

            guard let uid = Auth.auth().currentUser?.uid  else {return}

            let ref = Database.database().reference().child("users").child(uid)

            let values: [String: Any] = ["username": username, "email" : email, "roles" : ["User"], "dailyCalories" : 0]
            ref.updateChildValues(values, withCompletionBlock: { (err, ref) in

                if let error = error {
                    failure(error)
                    return
                }

                success()
            })
        }
    }

    func fetchUserData(for uid: String, success: @escaping ([String: Any]) -> (),
                       failure: @escaping (Error) -> ()) {

        let userPath = Database.database().reference().child(Configs.shared.firebaseUserListId).child(uid)
        userPath.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                success([:])
                return
            }
            guard let userData = snapshot.value as? [String: Any] else {
                failure(UserApiErrors.userHasNoId)
                return
            }
            success(userData)
        }) { (error) in
            failure(error)
        }

    }

    func editUser(uid: String, userJson: Json,
                  success: @escaping () -> (),
                  failure: @escaping (Error) -> ()) {

        let userRef = Database.database().reference().child(Configs.shared.firebaseUserListId).child(uid)

        userRef.setValue(userJson) { (err, ref) in
            if let err = err {
                failure(err)
                return
            }

            success()
        }
    }

    func checkCurrentPassword(oldPassword: String,
                              success: @escaping () -> (),
                              failure: @escaping(Error) -> ()) {


        guard let user = Auth.auth().currentUser, let email = user.email else {
            failure(UserApiErrors.noUserLoggedIn)
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

        user.reauthenticateAndRetrieveData(with: credential) { (result, error) in
            if let error = error {
                failure(error)
                return
            }
            success()
        }
    }

    func deleteUser(uid: String,
                    success: @escaping () -> (),
                    failure: @escaping(Error) -> ()) {

        let usersToDeleteList = Database.database().reference().child(Configs.shared.firebaseUsersToDeleteListId)
        let newRef = usersToDeleteList.childByAutoId()


        newRef.updateChildValues(["user":uid]) { (err, ref) in
            if let err = err {
                failure(err)
                return
            }
            success()
        }
    }


    func changePassword(newPassword: String,
                        success: @escaping () -> (),
                        failure: @escaping(Error) -> ()) {

        guard let user = Auth.auth().currentUser else {
            failure(UserApiErrors.noUserLoggedIn)
            return
        }

        user.updatePassword(to: newPassword, completion: { (error) in
            if let error = error {
                failure(error)
                return
            }
            success()
        })

    }

    func recoverPassword(email: String,
                         success: @escaping () -> (),
                         failure: @escaping(Error) -> ()) {

        Auth.auth().sendPasswordReset(withEmail: email) { (error) in

            if let error = error {
                failure(error)
                return
            }
            success()
        }
    }


    func logoutUser(uid:String,
                    success: @escaping () -> (),
                    failure: @escaping(Error) -> ()) {

        do {
            try Auth.auth().signOut()
            success()
        } catch let signOutErr {
            failure(signOutErr)
        }
    }

    func fetchUserList(success: @escaping ([String : Any]) -> (),
                       failure: @escaping (Error) -> ()) {

        let mealList = Database.database().reference().child(Configs.shared.firebaseUserListId)
        mealList.observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.exists() else {
                success([:])
                return
            }

            guard let todoItemJsonList = snapshot.value as? [String: Any] else {
                failure(UserApiErrors.unableToFetchListUsers)
                return
            }
            success(todoItemJsonList)
        }) { (error) in
            failure(error)
        }

    }

    func checkIfEmailExists(email: String,
                            success: @escaping (Bool) -> (),
                            failure: @escaping (Error) -> ()) {


        Auth.auth().fetchProviders(forEmail: email) { (providersList, error) in

            if let error = error {
                failure(error)
                return
            }

            if let list = providersList, list.count > 0 {
                success(true)
            } else {
                success(false)
            }
        }
    }

    func createUserFromAdmin(username: String, email: String, password: String,
                             success: @escaping () -> (),
                             failure: @escaping(Error) -> ()) {

        let ref = Database.database().reference().child(Configs.shared.firebaseUsersToCreateListId)
        let newRef = ref.childByAutoId()

        let values: [String: Any] = ["username": username, "password" : password, "email" : email, "roles" : ["User"], "dailyCalories" : 0]
        newRef.updateChildValues(values, withCompletionBlock: { (err, ref) in

            if let error = err {
                failure(error)
                return
            }

            success()
        })
    }
}




