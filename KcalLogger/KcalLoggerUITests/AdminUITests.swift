//
//  AdminUITests.swift
//  KcalLoggerUITests
//
//  Created by Luís Machado on 23/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import XCTest
@testable import KcalLogger

class AdminUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments += ["UI-Testing"]
        app.launchArguments += ["UI-Testing-Logged-In"]
        app.launch()
    }

    func testEditOwnRoles() {
        let app = XCUIApplication()
        app.navigationBars["My Calories Logger"].buttons["Settings"].tap()
        app.tables.staticTexts["User, User Agent, Admin"].tap()

        let editRolesAlert = app.alerts["Edit Roles"]
        let exists = NSPredicate(format: "exists == 1")
        let editOwnRoles = editRolesAlert.staticTexts["You cannot edit your own roles"]
        expectation(for: exists, evaluatedWith: editOwnRoles, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

         editRolesAlert.buttons["OK"].tap()
    }

    func testListOtherUsers() {
        let app = XCUIApplication()
        app.navigationBars["My Calories Logger"].buttons["Settings"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["Administration"].tap()

        let exists = NSPredicate(format: "exists == 1")
        let otherUser = tablesQuery.staticTexts["use2r@user.com"]
        expectation(for: exists, evaluatedWith: otherUser, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testEditRoles() {
        let app = XCUIApplication()
        app.navigationBars["My Calories Logger"].buttons["Settings"].tap()
        app.tables.staticTexts["Administration"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["use2r@user.com"].tap()

        let exists = NSPredicate(format: "exists == 1")

        let userRole = tablesQuery.staticTexts["User"]
        expectation(for: exists, evaluatedWith: userRole, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        userRole.tap()
        userRole.tap()

        let rolesAlert = app.alerts["Roles"]
        let minimumRoleAlert = rolesAlert.staticTexts["This is the minimum role that a user can carry and therefore can't be removed"]
        expectation(for: exists, evaluatedWith: minimumRoleAlert, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        rolesAlert.buttons["OK"].tap()

        tablesQuery.staticTexts["Admin"].tap()
        XCUIApplication().navigationBars["Roles"].buttons["Save"].tap()

        let newUserRoles = tablesQuery.staticTexts["User, User Agent, Admin"]
        expectation(for: exists, evaluatedWith: newUserRoles, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        newUserRoles.tap()

        tablesQuery.staticTexts["User Agent"].tap()
        XCUIApplication().navigationBars["Roles"].buttons["Save"].tap()

        let endUserRoles = tablesQuery.staticTexts["User"]
        expectation(for: exists, evaluatedWith: endUserRoles, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testDeleteUser() {
        let app = XCUIApplication()
        app.navigationBars["My Calories Logger"].buttons["Settings"].tap()
        app.tables.staticTexts["Administration"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["use2r@user.com"].tap()

        app.tables.staticTexts["Delete Account"].tap()

        let deleteAccountAlert = app.alerts["Delete Account"]
        let okButton = deleteAccountAlert.buttons["OK"]

        let exists = NSPredicate(format: "exists == 1")

        let firstMsg = deleteAccountAlert.staticTexts["Are you sure you want to delete username2's account?"]
        expectation(for: exists, evaluatedWith: firstMsg, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        okButton.tap()

        let secondMessage = deleteAccountAlert.staticTexts["Are you sure? This action is irreversible!"]
        expectation(for: exists, evaluatedWith: secondMessage, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        okButton.tap()


        let endMessage = deleteAccountAlert.staticTexts["The account will be deleted"]
        expectation(for: exists, evaluatedWith: endMessage, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        okButton.tap()

        let noMoreUser = tablesQuery.staticTexts["use2r@user.com"]
        let noExists = NSPredicate(format: "exists == 0")
        expectation(for: noExists, evaluatedWith: noMoreUser, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testCheckOtherMeals() {

        let app = XCUIApplication()
        app.navigationBars["My Calories Logger"].buttons["Settings"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["Administration"].tap()
        tablesQuery.staticTexts["username2"].tap()
        tablesQuery.staticTexts["User's Meals"].tap()

        let exists = NSPredicate(format: "exists == 1")
        let table = app.tables
        expectation(for: exists, evaluatedWith: table.staticTexts["Editing username2"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

    }
}
