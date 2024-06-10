//
//  UserAPITests.swift
//  KcalLoggerTests
//
//  Created by Luís Machado on 23/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Quick
import Nimble
import Firebase
@testable import KcalLogger

class UserAPITests: QuickSpec {

    var userApi: UserApiProtocol = UserApi.shared
    var testUserId: String = "ehdOoNmNL0goDGSPDth1phwMqEB2"
    var email: String = "apitest@email.com"
    var password: String = "qwerty1234"


    override func spec() {
        describe("User API Tests") {

            beforeEach {
                waitUntil(timeout: 2) { done in
                    self.userApi.logoutUser(uid: self.testUserId, success: {
                        done()
                    }, failure: { (_) in
                        done()
                    })
                }
            }

            it("checkExistingEmail") {
                waitUntil(timeout: 2) { done in
                    self.userApi.checkIfEmailExists(email: "apitest@email.com", success: { (exits) in
                        done()
                        expect(exits).to(beTrue(), description: "Email should exist")
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Check exists failed")
                    })
                }
            }

            it("checkNotExistingEmail") {
                waitUntil(timeout: 2) { done in
                    self.userApi.checkIfEmailExists(email: "doesNotExist@email.com", success: { (exits) in
                        done()
                        expect(exits).to(beFalse(), description: "Email should exist")
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Check exists failed")
                    })
                }
            }

            it("check password") {
                waitUntil(timeout: 5) { done in
                    self.userApi.login(email: self.email, password: self.password, success: {
                        self.userApi.checkCurrentPassword(oldPassword: self.password, success: {
                            done()
                            expect(true).to(beTrue())
                        }, failure: { (error) in
                            done()
                            expect(false).to(beTrue(), description: "Password should be correct")
                        })
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Login failed")
                    })
                }
            }

            it("change password") {
                waitUntil(timeout: 5) { done in
                    //Login
                    self.userApi.login(email: self.email, password: self.password, success: {
                        // Change password
                        self.userApi.changePassword(newPassword: "qwerty12345", success: {
                            // Check new password
                            self.userApi.checkCurrentPassword(oldPassword: "qwerty12345", success: {
                                // Change it back
                                self.userApi.changePassword(newPassword: "qwerty1234", success: {
                                    done()
                                }, failure: { (error) in
                                    done()
                                    expect(false).to(beTrue(), description: "Error changing password")
                                })
                            }, failure: { (error) in
                                done()
                                expect(false).to(beTrue(), description: "Password should be correct")
                            })
                        }, failure: { (error) in
                            done()
                            expect(false).to(beTrue(), description: "Error changing password")
                        })
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Login failed")
                    })
                }
            }

            it("login") {
                waitUntil(timeout: 5) { done in
                    self.userApi.login(email: self.email, password: self.password, success: {
                        done()
                        if let fbUser = self.userApi.isUserLoggedIn() {
                            expect(fbUser.email).to(equal(self.email))
                        } else {
                            expect(false).to(beTrue(), description: "no firebase user")
                        }
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "Login failed")
                    })
                }
            }

            it("fetchUserError") {
                if (self.userApi.isUserLoggedIn()) != nil {
                    expect(false).to(beTrue(), description: "no firebase user")
                } else {
                    expect(true).to(beTrue(), description: "should have no user")
                }
            }

            it("recover password error") {
                waitUntil(timeout: 5) { done in
                    self.userApi.recoverPassword(email: "doesNotExist@email.com", success: {
                        done()
                        expect(false).to(beTrue(), description: "Should have failed")
                    }, failure: { (error) in
                        done()
                        expect(true).to(beTrue())
                    })
                }
            }

            it("fetch user data") {
                waitUntil(timeout: 5) { done in
                    self.userApi.fetchUserData(for: self.testUserId, success: { (userDataJson) in
                        let user = AppUser(uid: self.testUserId, email: self.email, json: userDataJson)
                        expect(user.username).to(equal("apiTestUser"))
                        expect(user.dailyKcal).to(equal(2440))
                        done()
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "fetch user data error")
                    })
                }
            }

            it("fetch user data error") {
                waitUntil(timeout: 5) { done in
                    self.userApi.fetchUserData(for: "wronguserid", success: { (userDataJson) in
                        done()
                        if userDataJson.keys.count > 0 {
                            expect(false).to(beTrue(), description: "should have failed")
                        }
                    }, failure: { (error) in
                        done()
                    })
                }
            }

            it("edit user") {
                waitUntil(timeout: 5) { done in
                    // Fetch User
                    self.userApi.fetchUserData(for: self.testUserId, success: { (userDataJson) in
                        let user = AppUser(uid: self.testUserId, email: self.email, json: userDataJson)
                        user.username = "newUsername"
                        // Edit User
                        self.userApi.editUser(uid: self.testUserId, userJson: user.toJson(), success: {
                            // Fetch editions
                            self.userApi.fetchUserData(for: self.testUserId, success: { (userDataJson) in
                                let userNew = AppUser(uid: self.testUserId, email: self.email, json: userDataJson)
                                expect(userNew.username).to(equal("newUsername"))
                                userNew.username = "apiTestUser"
                                // Edit to initial
                                self.userApi.editUser(uid: self.testUserId, userJson: userNew.toJson(), success: {
                                    done()
                                }, failure: { (error) in
                                    done()
                                    expect(false).to(beTrue(), description: "edit user error")
                                })
                            }, failure: { (error) in
                                done()
                                expect(false).to(beTrue(), description: "fetch user data error")
                            })
                        }, failure: { (error) in
                            done()
                            expect(false).to(beTrue(), description: "edit user error")
                        })
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "fetch user data error")
                    })
                }
            }

            it("register user") {
                let userEmail = "newestuser999@email.com"
                waitUntil(timeout: 5) { done in
                    self.userApi.registerUser(username: "newTestUser999", email: userEmail, password: "qwerty1234", success: {
                        if let user = self.userApi.isUserLoggedIn() {
                            expect(user.email).to(equal(userEmail))
                            // Reocver password
                            self.userApi.recoverPassword(email: userEmail, success: {
                                self.userApi.deleteUser(uid: user.uid, success: {
                                    done()
                                }, failure: { (error) in
                                    done()
                                    expect(false).to(beTrue(), description: "error deleting user")
                                })
                            }, failure: { (error) in
                                done()
                                expect(false).to(beTrue(), description: "recover password error")
                            })
                        } else {
                            done()
                            expect(false).to(beTrue(), description: "no user!")
                        }
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "register error")
                    })
                }
            }

            it("fetch user list") {
                waitUntil(timeout: 5) { done in
                    self.userApi.fetchUserList(success: { (userListJson) in
                        done()
                        let idList = Array(userListJson.keys)
                        let usersList = idList.compactMap { AppUser(uid: $0, email: "", json: userListJson[$0] as! [String: Any]) }
                        expect(usersList.contains(where: { $0.uid == self.testUserId })).to(beTrue())
                    }, failure: { (error) in
                        done()
                        expect(false).to(beTrue(), description: "fetch user list error")
                    })
                }
            }
        }
    }
}

