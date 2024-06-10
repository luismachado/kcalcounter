//
//  MealLogicUITests.swift
//  KcalLoggerUITests
//
//  Created by Luís Machado on 18/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import XCTest
@testable import KcalLogger

class MealLogicUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments += ["UI-Testing"]
        app.launchArguments += ["UI-Testing-Logged-In"]
        app.launch()
    }

    func testDeleteInEditor() {
        let app = XCUIApplication()

        XCTAssertEqual(app.tables.staticTexts["Meal1"].exists, true)
        app.tables.staticTexts["Meal1"].tap()
        XCTAssertEqual(app.navigationBars["Edit Meal"].otherElements["Edit Meal"].exists, true)
        app.toolbars["Toolbar"].buttons["Delete"].tap()
        app.alerts["Edit Meal"].buttons["OK"].tap()

        let navBarTitle = XCUIApplication().navigationBars["My Calories Logger"]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: navBarTitle, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(app.tables.staticTexts["Meal1"].exists, false)
    }

    func testDeleteInTable() {
        let app = XCUIApplication()

        XCTAssertEqual(app.tables.staticTexts["Meal1"].exists, true)
        app.tables.staticTexts["Meal1"].swipeLeft()

        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: app.tables.buttons["Delete"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        app.tables.buttons["Delete"].tap()
        let myCaloriesLoggerAlert = app.alerts["My Calories Logger"]
        expectation(for: exists, evaluatedWith: myCaloriesLoggerAlert.staticTexts["Delete meal? This action is irreversible"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        myCaloriesLoggerAlert.buttons["OK"].tap()

        let notExists = NSPredicate(format: "exists == 0")
        expectation(for: notExists, evaluatedWith: app.tables.staticTexts["Meal1"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

    }

    func testAddGoBack() {
        let app = XCUIApplication()
        app.navigationBars["My Calories Logger"].buttons["Add"].tap()
        app.navigationBars["New Meal"].buttons["Back"].tap()
        let navBarTitle = XCUIApplication().navigationBars["My Calories Logger"]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: navBarTitle, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testUpdateMeal() {
        let app = XCUIApplication()

        XCTAssertEqual(app.tables.staticTexts["Meal1"].exists, true)
        app.tables.staticTexts["Meal1"].tap()
        XCTAssertEqual(app.navigationBars["Edit Meal"].otherElements["Edit Meal"].exists, true)

        var textField = app.tables.cells.containing(.staticText, identifier:"Description").children(matching: .textField).element
        textField.clearAndEnterText(text: "Meal2")

        let tablesQuery = app.tables
        var button = tablesQuery.cells.buttons.element(boundBy: 0)
        button.tap()
        let datePickersQuery = app.datePickers
        datePickersQuery.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "1")
        datePickersQuery.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "January")
        datePickersQuery.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2000")
        app.toolbars.matching(identifier: "Toolbar").buttons["Ok"].tap()

        button = tablesQuery.cells.buttons.element(boundBy: 1)
        button.tap()
        let timePickersQuery = app.datePickers
        timePickersQuery.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "12")
        timePickersQuery.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "00")
        app.toolbars.matching(identifier: "Toolbar").buttons["Ok"].tap()

        textField = app.tables.cells.containing(.staticText, identifier:"Calories").children(matching: .textField).element
        textField.clearAndEnterText(text: "1234")
        app.navigationBars["Edit Meal"].buttons["Save"].tap()

        let navBarTitle = XCUIApplication().navigationBars["My Calories Logger"]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: navBarTitle, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(app.tables.staticTexts["Meal2"].exists, true)
        XCTAssertEqual(app.tables.staticTexts["01 January"].exists, true)
        XCTAssertEqual(app.tables.staticTexts["12:00"].exists, true)
        XCTAssertEqual(app.tables.staticTexts["1234 kCal"].exists, true)
    }

    func testCreateMeal() {
        let app = XCUIApplication()

        app.navigationBars["My Calories Logger"].buttons["Add"].tap()

        let tablesQuery2 = app.tables
        let exPeanutButterSandwichTextField = tablesQuery2.textFields["ex. Peanut Butter Sandwich"]

        app.navigationBars["New Meal"].buttons["Save"].tap()
        var newMealAlert = app.alerts["New Meal"]
        XCTAssertEqual(newMealAlert.staticTexts["All the fields have to be filled"].exists, true)

        exPeanutButterSandwichTextField.clearAndEnterText(text: "Meal2")

        app.navigationBars["New Meal"].buttons["Save"].tap()
        newMealAlert = app.alerts["New Meal"]
        XCTAssertEqual(newMealAlert.staticTexts["All the fields have to be filled"].exists, true)
        newMealAlert.buttons["OK"].tap()

        let tablesQuery = app.tables
        var button = tablesQuery.cells.buttons.element(boundBy: 0)
        button.tap()
        let datePickersQuery = app.datePickers
        datePickersQuery.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "1")
        datePickersQuery.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "January")
        datePickersQuery.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2000")
        app.toolbars.matching(identifier: "Toolbar").buttons["Ok"].tap()

        app.navigationBars["New Meal"].buttons["Save"].tap()
        newMealAlert = app.alerts["New Meal"]
        XCTAssertEqual(newMealAlert.staticTexts["All the fields have to be filled"].exists, true)
        newMealAlert.buttons["OK"].tap()

        button = tablesQuery.cells.buttons.element(boundBy: 1)
        button.tap()
        let timePickersQuery = app.datePickers
        timePickersQuery.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "12")
        timePickersQuery.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "00")
        app.toolbars.matching(identifier: "Toolbar").buttons["Ok"].tap()

        app.navigationBars["New Meal"].buttons["Save"].tap()
        newMealAlert = app.alerts["New Meal"]
        XCTAssertEqual(newMealAlert.staticTexts["All the fields have to be filled"].exists, true)
        newMealAlert.buttons["OK"].tap()

        let exKcalField = tablesQuery2.textFields["ex. 120 kcal"]
        exKcalField.clearAndEnterText(text: "1234")
        app.navigationBars["New Meal"].buttons["Save"].tap()

        XCTAssertEqual(XCUIApplication().navigationBars["My Calories Logger"].exists,true)
        XCTAssertEqual(app.tables.staticTexts["Meal2"].exists, true)
        XCTAssertEqual(app.tables.staticTexts["01 January"].exists, true)
        XCTAssertEqual(app.tables.staticTexts["12:00"].exists, true)
        XCTAssertEqual(app.tables.staticTexts["1234 kCal"].exists, true)
    }
}
