//
//  SettingsViewController.swift
//  KcalLogger
//
//  Created by Luís Machado on 14/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var passwordField: UILabel!
    @IBOutlet weak var rolesField: UILabel!
    @IBOutlet weak var dailyKcalGoalField: UILabel!
    @IBOutlet weak var logoutMealsLabel: UILabel!
    
    var viewModel = SettingsViewModel(user: nil)
    var adminModel: AdministrationViewModelProtocol?

    weak var mealListViewController: MealListViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
    }

    private func updateValues() {
        usernameField.text = viewModel.username
        emailField.text = viewModel.email
        rolesField.text = viewModel.roles
        dailyKcalGoalField.text = viewModel.dailyKcalGoal
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateValues()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMealList" {
            guard let
                mealListVC = segue.destination as? MealListViewController,
                let currentUser = viewModel.user else {return}

            mealListVC.viewModel = MealListsViewModel(user: currentUser)
        } else if segue.identifier == "ShowRoles" {
            guard let
                navVC = segue.destination as? UINavigationController,
                navVC.viewControllers.count > 0,
                let rolesVC = navVC.viewControllers[0] as? RolesViewController,
                let currentUser = viewModel.user else {return}

            rolesVC.viewModel.user = currentUser
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !viewModel.shouldDisplay(section: section) {
            return 0.1
        } else {
            return  super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !viewModel.shouldDisplay(section: section) {
            return 0.1
        } else {
            return  super.tableView(tableView, heightForFooterInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 || section == 3 || section == 4 {
            return viewModel.shouldDisplay(section: section) ? 1 : 0
        } else {
            return  super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            if indexPath.item == 0 {
                usernameClicked(startingUsername: viewModel.username)
            } else if indexPath.item == 2 {
                if viewModel.handlingOtherUser {
                    AlertHelper.displayAlert(title: "Change Password", message: "You cannot change other user's passwords.", displayTo: self)
                } else {
                    self.performSegue(withIdentifier: "ShowPasswordChange", sender: self)
                }
            } else if indexPath.item == 3 {
                if !viewModel.handlingOtherUser {
                    AlertHelper.displayAlert(title: "Edit Roles", message: "You cannot edit your own roles", displayTo: self)
                } else {
                    if viewModel.canEditRoles {
                        self.performSegue(withIdentifier: "ShowRoles", sender: self)
                    } else {
                        AlertHelper.displayAlert(title: "Edit Roles", message: "You cannot edit users's roles with a higher role than yourself", displayTo: self)
                    }
                }
            }
        }

        if indexPath.section == 1 {
            caloriesClicked(startingCalories: Int(viewModel.dailyKcalGoal) ?? 0)
        }

        if indexPath.section == 2 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
                self.navigationController?.popViewController(animated: false)
                self.mealListViewController?.logout()
            }))

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            present(alertController, animated: true, completion: nil)
        } else if indexPath.section == 5 {
            AlertHelper.displayAlertCancel(title: viewModel.deleteMessageHeader, message: viewModel.deleteMessageMessageOne, displayTo: self) { (_) in
                AlertHelper.displayAlertCancel(title: self.viewModel.deleteMessageHeader, message: self.viewModel.deleteMessageMessageTwo, displayTo: self) { (action) in
                    self.viewModel.user?.delete(success: {
                        AlertHelper.displayAlert(title: self.viewModel.deleteMessageHeader, message: self.viewModel.deleteMessageSuccess, displayTo: self, completion: { (_) in
                            if self.viewModel.handlingOtherUser {
                                self.adminModel?.fetchUsers(finished: { (errorMessage) in
                                    self.navigationController?.popViewController(animated: true)
                                })
                            } else {
                                self.navigationController?.popViewController(animated: false)
                                self.mealListViewController?.logout()
                            }
                        })
                    }, failure: { (error) in
                        AlertHelper.displayAlert(title: self.viewModel.deleteMessageHeader, message: self.viewModel.deleteMessageError, displayTo: self)
                    })
                }
            }
        }
    }

    func caloriesClicked(startingCalories: Int) {
        var editedCalories: Int = startingCalories

        let alert = UIAlertController(style: .alert, title: "Change Daily Calories Goal")
        let config: TextField.Config = AlertHelper.getTextFieldConfig(initialText: "\(startingCalories)", placeholder: "", keyboardType: .numberPad) { (textField) in
            editedCalories = Int(textField.text ?? "0") ?? 0
        }
        alert.addOneTextField(configuration: config)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if editedCalories <= 0 || editedCalories > 5000 {
                AlertHelper.displayAlert(title: "Change Daily Calories Goal", message: "Calories should be more than 0 and less than 5000", displayTo: self, completion: { (_) in
                    self.caloriesClicked(startingCalories: editedCalories)
                })
            } else {
                self.viewModel.changeCalories(newCalories: editedCalories, success: {
                    self.updateValues()
                }, failure: { (error) in
                    AlertHelper.displayAlert(title: "Change Daily Calories Goal", message: "There was an issue changing the daily goal. Please try again later.", displayTo: self)
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
        }))
        alert.show()
    }

    func usernameClicked(startingUsername: String) {

        var editedUsername: String = startingUsername

        let alert = UIAlertController(style: .alert, title: "Change Username")
        let config: TextField.Config = AlertHelper.getTextFieldConfig(initialText: startingUsername, placeholder: "", keyboardType: .default) { (textField) in
            editedUsername = textField.text ?? ""
        }
        alert.addOneTextField(configuration: config)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if editedUsername.count < 6 {
                AlertHelper.displayAlert(title: "Change Username", message: "Username must be longer than 6 characters", displayTo: self, completion: { (_) in
                    self.usernameClicked(startingUsername: editedUsername)
                })
            } else {
                self.viewModel.changeUsername(newUsername: editedUsername, success: {
                    self.updateValues()
                }, failure: { (error) in
                    AlertHelper.displayAlert(title: "Change Username", message: "There was an issue changing the username. Please try again later.", displayTo: self)
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
        }))
        alert.show()
    }
    
}
