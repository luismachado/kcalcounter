//
//  LoginViewController.swift
//  KcalLogger
//
//  Created by Luís Machado on 14/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailFormField: UITextField!
    @IBOutlet weak var passwordFormField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    var loginCallBack: ((Bool)->())?

    var viewModel: LoginViewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        emailFormField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        emailFormField.delegate = self
        passwordFormField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        passwordFormField.delegate = self

        handleTextInputChange()

        viewModel.email.bindAndFire { [unowned self] (_) in
            self.visibilities()
        }

        viewModel.password.bindAndFire { [unowned self] (_) in
            self.visibilities()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRegistration", let registrationVC = segue.destination as? RegistrationViewController {
            registrationVC.loginCallBack = self.loginCallBack
        }
    }

    @objc private func handleTextInputChange() {
        viewModel.email.value = emailFormField.text ?? ""
        viewModel.password.value = passwordFormField.text ?? ""
    }

    @objc private func visibilities() {
        if viewModel.checkFields() == nil {
            loginButton.layer.masksToBounds = false
            loginButton.backgroundColor = Configs.shared.buttonColor
        } else {

            loginButton.layer.masksToBounds = true
            loginButton.backgroundColor = Configs.shared.buttonColorDisabled
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if loginButton.backgroundColor == Configs.shared.buttonColor {
            performLogin()
        }

        return true
    }

    fileprivate func performLogin() {
        if let errorMessage = viewModel.checkFields() {
            AlertHelper.displayAlert(title: viewModel.title, message: errorMessage, displayTo: self)
            return
        }

        emailFormField.resignFirstResponder()
        passwordFormField.resignFirstResponder()

        viewModel.login(success: {
            if let loginCallback = self.loginCallBack {
                loginCallback(true)
            }
            self.navigationController?.dismiss(animated: true, completion: {})
        }) { (errorMessage) in
            AlertHelper.displayAlert(title: self.viewModel.title, message: errorMessage, displayTo: self)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        performLogin()
    }

    @IBAction func recoverPasswordPressed(_ sender: Any) {

        var emailToRecover: String = ""

        if let email = emailFormField.text, email.count > 0, email.isValidEmail() {
            emailToRecover = email
        }
        AlertHelper.displayEmailRequest(defaultText: emailToRecover, displayTo: self) { (email) in
            self.viewModel.recoverPassword(success: {
                AlertHelper.displayAlert(title: "Password Recovery", message: "Recovery email sent", displayTo: self)
            }, failure: { (error) in
                AlertHelper.displayAlert(title: "Password Recovery", message: error, displayTo: self)
            })
        }
    }
}
