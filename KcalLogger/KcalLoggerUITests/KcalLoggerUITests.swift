//
//  KcalLoggerUITests.swift
//  KcalLoggerUITests
//
//  Created by Luís Machado on 12/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import XCTest
@testable import KcalLogger

class KcalLoggerUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments += ["UI-Testing"]
        app.launch()
    }

    func testLogin() {

        let app = XCUIApplication()
        let loginButton = app.buttons["Login"]
        XCTAssertEqual(loginButton.isEnabled, true)

        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]

        emailField.tap()
        emailField.typeText("email")
        XCTAssertEqual(loginButton.isEnabled, true)

        passwordField.tap()
        passwordField.typeText("1234")

        XCTAssertEqual(loginButton.isEnabled, true)
        loginButton.tap()

        var errorAlert = app.alerts["Login"]
        XCTAssertEqual(errorAlert.exists, true)

        var errorMessage = errorAlert.staticTexts["Email is empty or incorrectly formatted"]
        XCTAssertEqual(errorMessage.exists, true)

        errorAlert.buttons["OK"].tap()

        emailField.clearAndEnterText(text: "email@email.com")

        loginButton.tap()
        errorAlert = app.alerts["Login"]
        XCTAssertEqual(errorAlert.exists, true)

        errorMessage = errorAlert.staticTexts["Password has to have a minimum of 6 characters"]
        XCTAssertEqual(errorMessage.exists, true)


        passwordField.clearAndEnterText(text: "1234567")
        loginButton.tap()

        XCTAssertEqual(XCUIApplication().navigationBars["My Calories Logger"].exists,true)
    }

    func testPasswordRecovery() {

        let app = XCUIApplication()
        let recoverPasswordButton = app.buttons["Recover Password"]
        recoverPasswordButton.tap()

        let passwordRecoveryAlert = app.alerts["Password Recovery"]
        let okButton = passwordRecoveryAlert.buttons["OK"]

        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: passwordRecoveryAlert.staticTexts["Please enter the email associated with your account"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        okButton.tap()

        expectation(for: exists, evaluatedWith: passwordRecoveryAlert.staticTexts["Email is empty or incorrectly formatted"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        okButton.tap()

        let emailEmailComTextField = passwordRecoveryAlert.collectionViews.textFields["email@email.com"]
        emailEmailComTextField.clearAndEnterText(text: "email@email.com")

        okButton.tap()
        expectation(for: exists, evaluatedWith: passwordRecoveryAlert.staticTexts["Recovery email sent"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        okButton.tap()
    }

    func testGoToRegisterAndBack() {

        let app = XCUIApplication()

        let goToSignUpButton = app.buttons["Don't have an account? Sign Up"]
        XCTAssertEqual(goToSignUpButton.exists, true)
        goToSignUpButton.tap()

        let goBackToRegistration = app.buttons["Already have an account? Sign In"]
        XCTAssertEqual(goBackToRegistration.exists, true)
    }

    func testRegistration() {

        let app = XCUIApplication()
        let goToSignUpButton = app.buttons["Don't have an account? Sign Up"]
        goToSignUpButton.tap()

        let emailField = app.textFields["Email"]
        let usernameField = app.textFields["Username"]
        let passwordField = app.secureTextFields["Password"]
        let passwordConfirmField = app.secureTextFields["Confirm Password"]
        let signUpButton = app.buttons["Sign Up"]

        signUpButton.tap()
        var errorAlert = app.alerts["Registration"]
        XCTAssertEqual(errorAlert.exists, true)
        var errorMessage = errorAlert.staticTexts["Email is empty or incorrectly formatted"]
        XCTAssertEqual(errorMessage.exists, true)
        errorAlert.buttons["OK"].tap()

        emailField.tap()
        emailField.typeText("email@email.com")
        signUpButton.tap()
        errorAlert = app.alerts["Registration"]
        XCTAssertEqual(errorAlert.exists, true)
        errorMessage = errorAlert.staticTexts["Username must be longer than 6 characters"]
        XCTAssertEqual(errorMessage.exists, true)
        errorAlert.buttons["OK"].tap()

        usernameField.tap()
        usernameField.typeText("username")
        signUpButton.tap()
        errorAlert = app.alerts["Registration"]
        XCTAssertEqual(errorAlert.exists, true)
        errorMessage = errorAlert.staticTexts["Password has to have a minimum of 6 characters"]
        XCTAssertEqual(errorMessage.exists, true)
        errorAlert.buttons["OK"].tap()

        passwordField.tap()
        passwordField.typeText("qwerty1234")
        signUpButton.tap()
        errorAlert = app.alerts["Registration"]
        XCTAssertEqual(errorAlert.exists, true)
        errorMessage = errorAlert.staticTexts["Passwords should match"]
        XCTAssertEqual(errorMessage.exists, true)
        errorAlert.buttons["OK"].tap()

        passwordConfirmField.tap()
        passwordConfirmField.typeText("qwerty12345")
        signUpButton.tap()
        errorAlert = app.alerts["Registration"]
        XCTAssertEqual(errorAlert.exists, true)
        errorMessage = errorAlert.staticTexts["Passwords should match"]
        XCTAssertEqual(errorMessage.exists, true)
        errorAlert.buttons["OK"].tap()

        passwordConfirmField.tap()
        passwordConfirmField.clearAndEnterText(text: "qwerty1234")
        signUpButton.tap()
        XCTAssertEqual(XCUIApplication().navigationBars["My Calories Logger"].exists,true)
    }

    
}

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }
}
