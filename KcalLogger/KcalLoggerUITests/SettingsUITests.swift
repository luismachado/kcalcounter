//
//  SettingsUITests.swift
//  KcalLoggerUITests
//
//  Created by Luís Machado on 15/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import XCTest
@testable import KcalLogger

class SettingUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments += ["UI-Testing"]
        app.launchArguments += ["UI-Testing-Logged-In"]
        app.launch()
    }

    func testSettings() {
        let app = XCUIApplication()
        XCTAssertEqual(XCUIApplication().navigationBars["My Calories Logger"].exists,true)
        XCUIApplication().navigationBars["My Calories Logger"].buttons["Settings"].tap()
        XCTAssertEqual( app.navigationBars["Settings"].otherElements["Settings"].exists, true)
    }

    func testLogoutCancel() {
        let app = XCUIApplication()
        XCTAssertEqual(XCUIApplication().navigationBars["My Calories Logger"].exists,true)
        XCUIApplication().navigationBars["My Calories Logger"].buttons["Settings"].tap()


        let logoutStaticText = app.tables.staticTexts["Logout"]
        XCTAssertEqual(logoutStaticText.exists, true)

        logoutStaticText.tap()
        let sheetsQuery = app.sheets
        let cancelButton = sheetsQuery.buttons["Cancel"]
        XCTAssertEqual(cancelButton.exists, true)
        cancelButton.tap()

        XCTAssertEqual( app.navigationBars["Settings"].otherElements["Settings"].exists, true)

        logoutStaticText.tap()
        let confirmButton = sheetsQuery.buttons["Log Out"]
        XCTAssertEqual(confirmButton.exists, true)
        confirmButton.tap()

        app.staticTexts["My Calories Logger"].tap()
    }

    func testChangePassword() {

        let app = XCUIApplication()
        app.navigationBars["My Calories Logger"].buttons["Settings"].tap()

        let staticText = app.tables.staticTexts["*********"]
        staticText.tap()

        XCTAssertEqual(app.staticTexts["First enter your current password to set a new password."].exists, true)

        let oldPasswordSecureTextField = app.secureTextFields["old password"]
        let okButton = app.buttons["OK"]
        oldPasswordSecureTextField.clearAndEnterText(text: "1")
        okButton.tap()

        let changePasswordAlert = app.alerts["Change Password"]
        XCTAssertEqual(changePasswordAlert.staticTexts["Password must be filled out (at least 6 characters)"].exists, true)
        changePasswordAlert.buttons["OK"].tap()

        oldPasswordSecureTextField.clearAndEnterText(text: "1234567")
        okButton.tap()
        XCTAssertEqual(changePasswordAlert.staticTexts["Wrong password"].exists, true)
        changePasswordAlert.buttons["OK"].tap()

        oldPasswordSecureTextField.clearAndEnterText(text: "123456")
        okButton.tap()
        XCTAssertEqual(app.staticTexts["Now enter the new password and confirm it again."].exists, true)

        let newPasswordSecureTextField = app.secureTextFields["new password"]
        let repeatNewPasswordSecureTextField = app.secureTextFields["repeat new password"]
        newPasswordSecureTextField.clearAndEnterText(text: "1")
        okButton.tap()

        XCTAssertEqual(changePasswordAlert.staticTexts["Password must be filled out (at least 6 characters)"].exists, true)
        changePasswordAlert.buttons["OK"].tap()

        newPasswordSecureTextField.clearAndEnterText(text: "1234567")
        okButton.tap()
        XCTAssertEqual(changePasswordAlert.staticTexts["Passwords do not match"].exists, true)
        changePasswordAlert.buttons["OK"].tap()

        repeatNewPasswordSecureTextField.clearAndEnterText(text: "1234567")
        okButton.tap()
        XCTAssertEqual(changePasswordAlert.staticTexts["Password has been updated successfully."].exists, true)
        changePasswordAlert.buttons["OK"].tap()

        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: staticText, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        staticText.tap()

        let firstOldPassword = app.staticTexts["First enter your current password to set a new password."]

        expectation(for: exists, evaluatedWith: firstOldPassword, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        oldPasswordSecureTextField.clearAndEnterText(text: "1234567")
        okButton.tap()
        XCTAssertEqual(app.staticTexts["Now enter the new password and confirm it again."].exists, true)
    }

    func testChangeUsername() {

        let app = XCUIApplication()
        app.navigationBars["My Calories Logger"].buttons["Settings"].tap()
        
        let tablesQuery = app.tables
        XCTAssertEqual(tablesQuery.staticTexts["username"].exists, true)

        tablesQuery.staticTexts["username"].tap()

        let changeUsernameAlert = app.alerts["Change Username"]
        let textField = changeUsernameAlert.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element

        textField.clearAndEnterText(text: "")
        let okButton = changeUsernameAlert.buttons["OK"]
        okButton.tap()

        let exists = NSPredicate(format: "exists == 1")
        let username6CharsAlert = changeUsernameAlert.staticTexts["Username must be longer than 6 characters"]
        expectation(for: exists, evaluatedWith: username6CharsAlert, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        okButton.tap()
        textField.clearAndEnterText(text: "username123")
        okButton.tap()

        let newUsername = tablesQuery.staticTexts["username123"]
        expectation(for: exists, evaluatedWith: newUsername, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testChangeCalories() {

        let app = XCUIApplication()
        app.navigationBars["My Calories Logger"].buttons["Settings"].tap()
        let exists = NSPredicate(format: "exists == 1")
        let tablesQuery = app.tables

        expectation(for: exists, evaluatedWith:  tablesQuery.staticTexts["1000"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        tablesQuery.staticTexts["1000"].tap()

        let changeDailyCaloriesGoalAlert = app.alerts["Change Daily Calories Goal"]
        expectation(for: exists, evaluatedWith: changeDailyCaloriesGoalAlert.staticTexts["Change Daily Calories Goal"], handler: nil)

        let textField = changeDailyCaloriesGoalAlert.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element

        textField.clearAndEnterText(text: "0")
        let okButton = changeDailyCaloriesGoalAlert.buttons["OK"]
        okButton.tap()
        expectation(for: exists, evaluatedWith: changeDailyCaloriesGoalAlert.staticTexts["Calories should be more than 0 and less than 5000"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        okButton.tap()

        textField.clearAndEnterText(text: "5001")
        okButton.tap()
        expectation(for: exists, evaluatedWith: changeDailyCaloriesGoalAlert.staticTexts["Calories should be more than 0 and less than 5000"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        okButton.tap()

        textField.clearAndEnterText(text: "4000")
        okButton.tap()
        expectation(for: exists, evaluatedWith:  tablesQuery.staticTexts["4000"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

    
}


