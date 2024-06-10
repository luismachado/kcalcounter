//
//  FilterUITests.swift
//  KcalLoggerUITests
//
//  Created by Luís Machado on 23/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import XCTest
@testable import KcalLogger

class FilterUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments += ["UI-Testing"]
        app.launchArguments += ["UI-Testing-Logged-In"]
        app.launch()
    }

    func testFilterDate() {
        let app = XCUIApplication()
        let exists = NSPredicate(format: "exists == 1")
        let notExists = NSPredicate(format: "exists ==  0")

        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal1"], handler: nil)
        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal2"], handler: nil)
        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal3"], handler: nil)
        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal4"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        app.toolbars["Toolbar"].buttons["Search"].tap()
        app.sheets["Filter by:"].buttons["Date"].tap()

        expectation(for: exists, evaluatedWith: app.sheets["Select lower bound"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        let selectLowerBoundSheet = app.sheets["Select lower bound"]
        let lowerDatePicker = selectLowerBoundSheet.datePickers
        lowerDatePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "22")
        lowerDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "March")
        lowerDatePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2019")
        selectLowerBoundSheet.buttons["OK"].tap()

        expectation(for: exists, evaluatedWith: app.sheets["Select upper bound"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        let selectUpperBoundSheet = app.sheets["Select upper bound"]

        let upperDatePicker = selectUpperBoundSheet.datePickers
        upperDatePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "23")
        upperDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "March")
        upperDatePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2019")
        selectUpperBoundSheet.buttons["OK"].tap()

        expectation(for: exists, evaluatedWith: app.staticTexts["Filter Active"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        expectation(for: notExists, evaluatedWith: app.tables.staticTexts["Meal4"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFilterTime() {
        let app = XCUIApplication()
        let exists = NSPredicate(format: "exists == 1")
        let notExists = NSPredicate(format: "exists ==  0")

        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal1"], handler: nil)
        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal2"], handler: nil)
        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal3"], handler: nil)
        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal4"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        app.toolbars["Toolbar"].buttons["Search"].tap()
        app.sheets["Filter by:"].buttons["Time"].tap()

        expectation(for: exists, evaluatedWith: app.sheets["Select lower bound"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        let selectLowerBoundSheet = app.sheets["Select lower bound"]
        let lowerDatePicker = selectLowerBoundSheet.datePickers
        lowerDatePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "11")
        lowerDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "50")
        selectLowerBoundSheet.buttons["OK"].tap()

        expectation(for: exists, evaluatedWith: app.sheets["Select upper bound"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        let selectUpperBoundSheet = app.sheets["Select upper bound"]

        let upperDatePicker = selectUpperBoundSheet.datePickers
        upperDatePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "12")
        upperDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "59")
        selectUpperBoundSheet.buttons["OK"].tap()

        expectation(for: exists, evaluatedWith: app.staticTexts["Filter Active"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        expectation(for: notExists, evaluatedWith: app.tables.staticTexts["Meal3"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        app.toolbars["Toolbar"].buttons["Search"].tap()
        app.sheets["Filter by:"].buttons["Remove Filter"].tap()

        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal3"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFilterDateTime() {
        let app = XCUIApplication()
        let exists = NSPredicate(format: "exists == 1")
        let notExists = NSPredicate(format: "exists ==  0")

        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal1"], handler: nil)
        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal2"], handler: nil)
        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal3"], handler: nil)
        expectation(for: exists, evaluatedWith: app.tables.staticTexts["Meal4"], handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        app.toolbars["Toolbar"].buttons["Search"].tap()
        app.sheets["Filter by:"].buttons["Date & Time"].tap()

        expectation(for: exists, evaluatedWith: app.sheets["Select lower date bound"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        let selectLowerBoundSheet = app.sheets["Select lower date bound"]
        let lowerDatePicker = selectLowerBoundSheet.datePickers
        lowerDatePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "22")
        lowerDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "March")
        lowerDatePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2019")
        selectLowerBoundSheet.buttons["OK"].tap()

        expectation(for: exists, evaluatedWith: app.sheets["Select upper date bound"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
        let selectUpperBoundSheet = app.sheets["Select upper date bound"]

        let upperDatePicker = selectUpperBoundSheet.datePickers
        upperDatePicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "23")
        upperDatePicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "March")
        upperDatePicker.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "2019")
        selectUpperBoundSheet.buttons["OK"].tap()

        expectation(for: exists, evaluatedWith: app.sheets["Select lower hour bound"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        let selectLowerHourBoundSheet = app.sheets["Select lower hour bound"]
        let lowerHourPicker = selectLowerHourBoundSheet.datePickers
        lowerHourPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "11")
        lowerHourPicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "50")
        selectLowerHourBoundSheet.buttons["OK"].tap()

        expectation(for: exists, evaluatedWith: app.sheets["Select upper hour bound"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        let selectUpperHourBoundSheet = app.sheets["Select upper hour bound"]
        let upperHourPicker = selectUpperHourBoundSheet.datePickers
        upperHourPicker.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "12")
        upperHourPicker.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "50")
        selectUpperHourBoundSheet.buttons["OK"].tap()

        expectation(for: exists, evaluatedWith: app.staticTexts["Filter Active"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        expectation(for: notExists, evaluatedWith: app.tables.staticTexts["Meal3"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)

        expectation(for: notExists, evaluatedWith: app.tables.staticTexts["Meal4"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
}
