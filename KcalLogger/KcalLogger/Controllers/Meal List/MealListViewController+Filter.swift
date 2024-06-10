//
//  MealListViewController+Filter.swift
//  KcalLogger
//
//  Created by Luís Machado on 25/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

extension MealListViewController {
    func showDatePicker() {
        self.presentPicker(title: "Select lower bound", mode: .date, minimumDate: nil, success: { (lowerDate) in
            self.presentPicker(title: "Select upper bound", mode: .date, minimumDate: lowerDate, success: { (upperDate) in
                self.viewModel.fetchFilteredMealList(filterType: .date, lowerBound: lowerDate, upperBound: upperDate, success: {
                }, failure: { (error) in
                    AlertHelper.displayAlert(title: "Downloading meals", message: error, displayTo: self)
                })
            }, canceled: {})
        }, canceled: {})
    }

    func showTimePicker() {
        self.presentPicker(title: "Select lower bound", mode: .time, minimumDate: nil, success: { (lowerDate) in
            self.presentPicker(title: "Select upper bound", mode: .time, minimumDate: lowerDate, success: { (upperDate) in
                self.viewModel.fetchFilteredMealList(filterType: .time, lowerBound: lowerDate, upperBound: upperDate, success: {
                }, failure: { (error) in
                    AlertHelper.displayAlert(title: "Downloading meals", message: error, displayTo: self)
                })
            }, canceled: {})
        }, canceled: {})
    }

    func showDateTimePicker() {
        self.presentPicker(title: "Select lower date bound", mode: .date, minimumDate: nil, success: { (lowerDate) in
            self.presentPicker(title: "Select upper date bound", mode: .date, minimumDate: lowerDate, success: { (upperDate) in
                self.presentPicker(title: "Select lower hour bound", mode: .time, minimumDate: nil, success: { (lowerTime) in
                    self.presentPicker(title: "Select upper hour bound", mode: .time, minimumDate: lowerTime, success: { (upperTime) in
                        self.viewModel.fetchMultiFilteredMealList(lowerBound: lowerDate, upperBound: upperDate, lowerHourBound: lowerTime, upperHourBound: upperTime, success: {
                        }, failure: { (error) in
                            AlertHelper.displayAlert(title: "Downloading meals", message: error, displayTo: self)
                        })
                    }, canceled: {})
                }, canceled: {})
            }, canceled: {})
        }, canceled: {})
    }

    private func presentPicker(title: String, mode: UIDatePicker.Mode, minimumDate: Date?, success: @escaping (Date) -> (),
                               canceled: @escaping () -> ()) {

        var selectedDate: Date = Date()

        let alert = UIAlertController(style: .actionSheet, title: title)
        alert.addDatePicker(mode: mode, date: Date(), minimumDate: minimumDate, maximumDate: nil) { date in
            selectedDate = date
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            success(selectedDate)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            canceled()
        }))
        alert.show()
    }
}
