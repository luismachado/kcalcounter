//
//  CreateEditMealViewController.swift
//  KcalLogger
//
//  Created by Luís Machado on 16/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class CreateEditMealViewController: UITableViewController {

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var deleteButton: UIBarButtonItem!

    var viewModel: CreateEditMealViewModelProtocol = CreateEditMealViewModel(mealId: nil)
    weak var mealListViewModel:MealListViewModelProtocol?

    lazy var datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()

    lazy var timePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        return picker
    }()

    var toolBar = UIToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = viewModel.title
        self.hideKeyboardWhenTappedAround()

        viewModel.description.bindAndFire { [unowned self] in self.descriptionTextField.text = $0 }
        viewModel.date.bindAndFire { [unowned self] in self.dateButton.setTitle($0, for: .normal) }
        viewModel.time.bindAndFire { [unowned self] in self.timeButton.setTitle($0, for: .normal) }
        viewModel.calories.bindAndFire { [unowned self]
            in self.caloriesTextField.text = $0
        }

        deleteButton.isEnabled = !viewModel.isNewMeal

        setupToolbar()

        descriptionTextField.delegate = self
        caloriesTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: .leastNormalMagnitude))

        if let mealListViewModel = mealListViewModel, !mealListViewModel.isMyself {
            addEditingWarning()
        }
    }

    func addEditingWarning() {
        //Get all views in the xib
        let allViewsInXibArray = Bundle.main.loadNibNamed("EditingUserInfo", owner: self, options: nil)
        let mainHeaderView = allViewsInXibArray?.first as! EditingUserInfo
        mainHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
        mainHeaderView.setup(username: mealListViewModel?.user?.username ?? "other user.")

        // Calculate best Size
        mainHeaderView.setNeedsLayout()
        mainHeaderView.layoutIfNeeded()
        let height = mainHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        mainHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)

        self.tableView.tableHeaderView = mainHeaderView
    }

    private func setupToolbar() {
        toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(donePressed))
        doneButton.tintColor = .black
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        cancelButton.tintColor = .black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton,spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        dateTextField.inputView = datePickerView
        dateTextField.inputAccessoryView = toolBar

        timeTextField.inputView = timePickerView
        timeTextField.inputAccessoryView = toolBar
    }

    @IBAction func dateButtonPressed(_ sender: Any) {
        self.dateTextField.becomeFirstResponder()
    }

    @IBAction func timeButtonPressed(_ sender: Any) {
        self.timeTextField.becomeFirstResponder()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        self.view.endEditing(true)

        guard let userId = mealListViewModel?.user?.uid else { return }

        if viewModel.isMealValid {
            if viewModel.isNewMeal {
                mealListViewModel?.add(meal: viewModel.meal, completed: { (errorMessage) in
                    if let error = errorMessage {
                        AlertHelper.displayAlert(title: self.viewModel.title, message: error, displayTo: self)
                    } else {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                })
            } else {
                viewModel.meal.updateMeal(userId: userId, success: {
                    self.mealListViewModel?.update(meal: self.viewModel.meal, completed: { (_) in
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                }) { (error) in
                    AlertHelper.displayAlert(title: self.viewModel.title, message: error, displayTo: self)
                }
            }
        } else {
            AlertHelper.displayAlert(title: viewModel.title, message: "All the fields have to be filled", displayTo: self)
        }
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        AlertHelper.displayAlertCancel(title: viewModel.title, message: "Delete meal? This action is irreversible", displayTo: self) { (_) in
            self.mealListViewModel?.remove(meal: self.viewModel.meal, completed: { (errorMessage) in
                if let error = errorMessage {
                    AlertHelper.displayAlert(title: self.viewModel.title, message: error, displayTo: self)
                } else {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
}

extension CreateEditMealViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == caloriesTextField {
            textField.text = viewModel.calories.value.replacingOccurrences(of: " kCal", with: "")
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == caloriesTextField {
            viewModel.set(calories: caloriesTextField.text ?? "0")
        } else if textField == descriptionTextField {
            viewModel.set(description: descriptionTextField.text ?? "")
        }
    }
}

extension CreateEditMealViewController:  UIPickerViewDelegate {

    @objc func cancelPressed() {
        timeTextField.resignFirstResponder()
        dateTextField.resignFirstResponder()
    }

    @objc func donePressed() {
        if dateTextField.isFirstResponder {
            dateTextField.resignFirstResponder()
            if let newDate = datePickerView.date.combineWithTime(time: viewModel.meal.date) {
                viewModel.set(date: newDate)
            }
        } else if timeTextField.isFirstResponder {
            timeTextField.resignFirstResponder()
            if let newDate = viewModel.meal.date.combineWithTime(time: timePickerView.date) {
                viewModel.set(date: newDate)
            }
        }
    }
}
