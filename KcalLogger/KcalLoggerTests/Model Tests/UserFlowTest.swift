//
//  UserCreationTest.swift
//  KcalLoggerTests
//
//  Created by Luís Machado on 15/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Quick
import Nimble
@testable import KcalLogger

class UserFlowTests: QuickSpec {
    
    override func spec() {
        describe("Standard Init") {

            beforeEach {
                AppUser.getCurrentUser()?.logout {}
            }

            it("testLogin") {
                AppUser.userApi = UserAPIMock.init(shouldFail: false)
                AppUser.logIn(email: "email@test.com", password: "123456", success: { (uid) in
                    expect(uid).to(equal("1234567"))
                }, failure: { (message) in
                    expect(false).to(beTrue(), description: "Unable to login")
                })
            }

            it("testLoginError") {
                AppUser.userApi = UserAPIMock.init(shouldFail: true)
                AppUser.logIn(email: "email@test.com", password: "123456", success: { (uid) in
                    expect(false).to(beTrue(), description: "Login should have failed")
                }, failure: { (message) in
                    expect(true).to(beTrue(), description: "Expected login fail")
                })
            }

            it("testLoginError_empty_user") {
                AppUser.userApi = UserAPIMock.init(shouldFail: false, forgetUser: true)
                AppUser.logIn(email: "email@test.com", password: "123456", success: { (uid) in
                    expect(false).to(beTrue(), description: "Login should have failed")
                }, failure: { (message) in
                    expect(true).to(beTrue(), description: "Expected login fail")
                })
            }

            it("testRegistration") {
                AppUser.userApi = UserAPIMock.init(shouldFail: false)
                AppUser.register(username: "my_username", email: "email@test.com", password: "132456", success: { (uid) in
                    expect(uid).to(equal("1234567"))
                }, failure: { (error) in
                    expect(false).to(beTrue(), description: "Unable to register")
                })
            }

            it("testRegistrationError") {
                AppUser.userApi = UserAPIMock.init(shouldFail: true)
                AppUser.register(username: "my_username", email: "email@test.com", password: "132456", success: { (uid) in
                    expect(false).to(beTrue(), description: "Registration should have failed")
                }, failure: { (error) in
                    expect(true).to(beTrue(), description: "Expected registration to fail")
                })
            }

            it("testRegistrationError_empty_user") {
                AppUser.userApi = UserAPIMock.init(shouldFail: false, forgetUser: true)
                AppUser.register(username: "my_username", email: "email@test.com", password: "132456", success: { (uid) in
                    expect(false).to(beTrue(), description: "Registration should have failed")
                }, failure: { (error) in
                    expect(true).to(beTrue(), description: "Expected registration to fail")
                })
            }

            it("testLogoutError") {
                AppUser.userApi = UserAPIMock.init(shouldFail: false)
                let user = AppUser(uid: "1234", email: "email", json: [:])
                user.logout {
                    expect(true).to(beTrue(), description: "Expected logout to fail")
                }
            }

            it("testLogoutError_2") {
                AppUser.userApi = UserAPIMock.init(shouldFail: true)
                let user = AppUser(uid: "1234", email: "email", json: [:])
                user.logout {
                    expect(true).to(beTrue(), description: "Expected logout to fail")
                }
            }

            it("testLogout") {
                AppUser.userApi = UserAPIMock.init(shouldFail: false)
                AppUser.logIn(email: "email@test.com", password: "123456", success: { (uid) in
                    expect(uid).to(equal("1234567"))
                    if let currentUser = AppUser.getCurrentUser() {
                        currentUser.logout {
                            expect(true).to(beTrue(), description: "Logout ok")
                        }
                    } else {
                        expect(false).to(beTrue(), description: "No User created")
                    }
                }, failure: { (message) in
                    expect(false).to(beTrue(), description: "Unable to login")
                })
            }
        }
    }

}
