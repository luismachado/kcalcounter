//
//  ViewController.swift
//  KcalLogger
//
//  Created by Luís Machado on 12/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class MealListViewController: UIViewController {

    @IBOutlet weak var filterButton: UIBarButtonItem!
    let mealCellId = "MealCell"

    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: MealListViewModelProtocol = MealListsViewModel(user: nil)
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)

        //Create user object at startup if user is logged in
        AppUser.isUserLoggedIn { (_) in
            self.checkForLogin()
        }

        viewModel.mealsPerDay.bind { [unowned self] (list) in
            if !self.viewModel.isFetchingMore {
                DispatchQueue.main.async {
                    let contentOffset = self.tableView.contentOffset
                    self.tableView.reloadData()
                    self.tableView.layoutIfNeeded()
                    self.tableView.setContentOffset(contentOffset, animated: true)
                    self.checkIfEmpty()
                }
            }
        }

        viewModel.idxPathsToAdd.bind { [unowned self] (indexPathList) in
            DispatchQueue.main.async {
                self.tableView.performBatchUpdates({
                    self.tableView.insertRows(at: indexPathList, with: .none)
                }, completion: { (finished) in
                })
            }
        }

        filterLabel.text = ""
    }

    @objc func refresh() {
        // Code to refresh table view
        viewModel.fetchList(restart: true, success: {
            self.refreshControl.endRefreshing()
        }) { (error) in
            AlertHelper.displayAlert(title: "Downloading meals", message: error, displayTo: self)
            self.refreshControl.endRefreshing()
        }
    }

    func addEditingWarning() {
        //Get all views in the xib
        let allViewsInXibArray = Bundle.main.loadNibNamed("EditingUserInfo", owner: self, options: nil)
        let mainHeaderView = allViewsInXibArray?.first as! EditingUserInfo
        mainHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
        mainHeaderView.setup(username: viewModel.user?.username ?? "other user.")

        // Calculate best Size
        mainHeaderView.setNeedsLayout()
        mainHeaderView.layoutIfNeeded()
        let height = mainHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        mainHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)

        self.tableView.tableHeaderView = mainHeaderView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if viewModel.isMyself {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: .leastNormalMagnitude))
        } else {
            DispatchQueue.main.async {
                self.addEditingWarning()
            }
        }
        tableView.reloadData()
    }

    @objc func showSettings() {
        performSegue(withIdentifier: "showSettings", sender: self)
    }

    // If user is logged in it proceeds to fetch data
    func checkForLogin(fromSignup: Bool = false) {

        if self.viewModel.user == nil {
            self.viewModel.user = AppUser.getCurrentUser()
        }

        if self.viewModel.user == nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showLogin", sender: self)
            }
        } else {
            self.setupSettingsButton()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.askForCalories()
            }
            self.viewModel.fetchList(restart: true, success: {

            }) { (error) in
                AlertHelper.displayAlert(title: "Downloading meals", message: error, displayTo: self)
            }
        }
    }

    private func askForCalories(startingCalories: Int = 0) {
        if let user = self.viewModel.user, let myself = AppUser.getCurrentUser(), user.uid == myself.uid, user.dailyKcal == 0 {
            var editedCalories: Int = startingCalories

            let alert = UIAlertController(style: .alert, title: "Your daily goal for calories is 0!")
            let config: TextField.Config = AlertHelper.getTextFieldConfig(initialText: "\(startingCalories)", placeholder: "", keyboardType: .numberPad) { (textField) in
                editedCalories = Int(textField.text ?? "0") ?? 0
            }            
            alert.addOneTextField(configuration: config)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                if editedCalories <= 0 || editedCalories > 5000 {
                    AlertHelper.displayAlert(title: "Change Daily Calories Goal", message: "Calories should be more than 0 and less than 5000", displayTo: self, completion: { (_) in
                        self.askForCalories(startingCalories: editedCalories)
                    })
                } else {
                    self.viewModel.changeCalories(newCalories: editedCalories, success: {
                        AlertHelper.displayAlert(title: "Change Daily Calories Goal", message: "Calories Saved.", displayTo: self)
                        self.tableView.reloadData()
                    }, failure: { (error) in
                        AlertHelper.displayAlert(title: "Change Daily Calories Goal", message: "There was an issue changing the daily goal. Please try again later.", displayTo: self)
                    })
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            }))
            alert.show()
        }
    }

    private func checkIfEmpty() {
        filterLabel.text = viewModel.isShowingFilteredMeals ? "Filter Active" : ""

        if viewModel.meals.count == 0 {
            let label = UILabel(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.x, width: self.view.frame.size.width, height: (self.view.frame.size.height / 3)*2))
            let labelView = UIView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.x, width: self.view.frame.size.width, height: (self.view.frame.size.height / 3)*2))
            label.text = "You have no meals :("
            label.textColor = .darkGray
            label.textAlignment = .center
            labelView.addSubview(label)
            self.tableView.backgroundView = labelView
        } else {
            self.tableView.backgroundView = nil
        }
    }

    private func setupSettingsButton() {
        if let user = self.viewModel.user, let myself = AppUser.getCurrentUser(), user.uid == myself.uid {
            let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.showSettings))
            self.navigationItem.leftBarButtonItem = settingsButton
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettings", let settingsVC = segue.destination as? SettingsViewController {
            settingsVC.mealListViewController = self
        } else if segue.identifier == "editMeal" || segue.identifier == "createMeal" {
            guard let
                navController = segue.destination as? UINavigationController,
                navController.viewControllers.count > 0,
                let createEditMealVC = navController.viewControllers[0] as? CreateEditMealViewController else {return}

            createEditMealVC.mealListViewModel = self.viewModel
            if  segue.identifier == "editMeal" {
                guard let selectedIdx = tableView.indexPathForSelectedRow else  { return }
                let meal = viewModel.mealFor(indexPath: selectedIdx)
                createEditMealVC.viewModel = CreateEditMealViewModel(mealId: meal.mealId, description: meal.description, date: meal.date, kcalAmount: meal.kcalAmount)
                tableView.deselectRow(at: selectedIdx, animated: false)
            }
        } else if segue.identifier == "showLogin" {
            guard let
                navVC = segue.destination as? UINavigationController,
                navVC.viewControllers.count > 0,
                let loginVC = navVC.viewControllers[0] as? LoginViewController else {return}

            loginVC.loginCallBack = { [unowned self] result in
                self.checkForLogin(fromSignup: result)
            }
        }
    }

    @IBAction func filterPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Filter by:", message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Date", style: .default, handler: { (_) in
            self.showDatePicker()
        }))

        alertController.addAction(UIAlertAction(title: "Time", style: .default, handler: { (_) in
            self.showTimePicker()
        }))

        alertController.addAction(UIAlertAction(title: "Date & Time", style: .default, handler: { (_) in
            self.showDateTimePicker()
        }))

        let removeFilter = UIAlertAction(title: "Remove Filter", style: .default) { (_) in
            self.viewModel.fetchList(restart: true, success: {
            }, failure: { (error) in
                AlertHelper.displayAlert(title: "Downloading meals", message: error, displayTo: self)
            })
        }

        if viewModel.isShowingFilteredMeals {
            alertController.addAction(removeFilter)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func logout() {
        viewModel.logout {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showLogin", sender: self)
            }
        }
    }
}
