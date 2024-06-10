//
//  UserTests.swift
//  KcalLoggerTests
//
//  Created by Luís Machado on 13/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Quick
import Nimble
@testable import KcalLogger

class UserTests: QuickSpec {

    override func spec() {
        describe("Standard Init") {
            it("createStandardUser") {
                let json:[String:Any] = [
                    "username" : "username",
                    "dailyCalories": 2500,
                    "roles": ["User","User Agent"]
                ]
                let user = AppUser(uid: "0000", email: "user@email.com", json: json)
                expect(user.uid).to(equal("0000"))
                expect(user.roles.count).to(equal(2))
            }

            it("createStandardUserWith0Kcal") {
                let user = AppUser(uid: "0000", email: "user@email.com", json: [:])
                expect(user.dailyKcal).to(equal(0))
            }

            it("createStandardUserWithNoRoles") {
                let json:[String:Any] = [
                    "dailyCalories": 2500
                ]
                let user = AppUser(uid: "0000", email: "user@email.com", json: json)
                expect(user.roles.count).to(equal(1))
                expect(user.roles[0]).to(equal(Role.user))
            }

            it("createStandardUserWithWrongRoles") {
                let json:[String:Any] = [
                    "dailyCalories": 2500,
                    "roles": ["Super User"]
                ]
                let user = AppUser(uid: "0000", email: "user@email.com", json: json)
                expect(user.roles.count).to(equal(1))
                expect(user.roles[0]).to(equal(Role.user))
            }
        }
    }
}
