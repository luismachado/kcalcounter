//
//  MealListViewController+Table.swift
//  KcalLogger
//
//  Created by Luís Machado on 25/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

extension MealListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.nameForSection(in: section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: mealCellId, for: indexPath) as? MealCell else { return UITableViewCell() }
        let meal = viewModel.mealFor(indexPath: indexPath)
        cell.meal = meal
        cell.mealPosition = viewModel.mealPosition(for: indexPath)
        cell.hasExceededKcal = viewModel.hasExceededCaloriesForDay(meal: meal)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            AlertHelper.displayAlertCancel(title: viewModel.title, message: "Delete meal? This action is irreversible", displayTo: self) { (_) in
                self.viewModel.remove(meal: self.viewModel.mealFor(indexPath: indexPath)) { (errorMessage) in
                    if let error = errorMessage {
                        AlertHelper.displayAlert(title: "Delete meal", message: error, displayTo: self)
                    }
                }
            }
        }
    }

}
