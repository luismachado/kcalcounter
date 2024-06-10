//
//  ChangePasswordViewController.swift
//  KcalLogger
//
//  Created by Luís Machado on 22/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    var viewModel: ChangePasswordViewModelProtocol = ChangePasswordViewModel(user: nil)

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var password2Field: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = viewModel.title

        passwordField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        password2Field.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)

        passwordField.delegate = self
        password2Field.delegate = self

        viewModel.passwordOne.bindAndFire { [unowned self] (_) in
            self.passwordField.text = self.viewModel.passwordOne.value
            self.visibilities()
        }

        viewModel.passwordTwo.bindAndFire { [unowned self] (_) in
            self.visibilities()
        }

        viewModel.oldPasswordScreen.bind { [unowned self] (_) in
            self.changeView()
        }
        viewModel.setOldPasswordScreen(value: true)
    }

    @objc private func handleTextInputChange() {
        viewModel.setPasswords(pw1: passwordField.text ?? "", pw2: password2Field.text ?? "")
    }

    @objc private func visibilities() {
        if viewModel.isFormValid {
            submitButton.layer.masksToBounds = false
            submitButton.backgroundColor = Configs.shared.buttonColor
        } else {
            submitButton.layer.masksToBounds = true
            submitButton.backgroundColor = Configs.shared.buttonColorDisabled
        }
    }


    @IBAction func submitPressed(_ sender: Any) {

        guard viewModel.isOldPasswordValid else {
            AlertHelper.displayAlert(title: viewModel.title, message: viewModel.oldPasswordBadFormat, displayTo: self)
            return
        }

        if viewModel.isOldPassword {
            viewModel.checkCurrentPassword(success: {
                self.viewModel.setOldPasswordScreen(value: false)
            }) { (errorMessage) in
                AlertHelper.displayAlert(title: self.viewModel.title, message: errorMessage, displayTo: self)
            }
        } else {
            guard viewModel.areNewPasswordsEqual else {
                AlertHelper.displayAlert(title: viewModel.title, message: viewModel.passwordsDoNoMatch, displayTo: self)
                return
            }

            viewModel.updatePassword(success: {
                AlertHelper.displayAlert(title: self.viewModel.title, message: self.viewModel.updateSuccess, displayTo: self, completion: { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
            }) { (error) in
                AlertHelper.displayAlert(title: self.viewModel.title, message: error, displayTo: self)
            }
        }
    }

    fileprivate func changeView() {
        handleTextInputChange()

        if viewModel.isOldPassword {
            stackView.removeArrangedSubview(password2Field)
            password2Field.isHidden = true
            stackViewHeight.constant = 40
            passwordField.placeholder = viewModel.oldPasswordLabel
            headerLabel.text = viewModel.oldHeader
        } else {
            stackViewHeight.constant = 93
            stackView.insertArrangedSubview(password2Field, at: 1)
            password2Field.isHidden = false
            passwordField.placeholder = viewModel.newPasswordLabel
            password2Field.placeholder = viewModel.repeatNewPasswordLabel
            headerLabel.text = viewModel.newHeader
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
