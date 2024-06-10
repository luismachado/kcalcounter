//
//  RegistrationViewController.swift
//  KcalLogger
//
//  Created by Luís Machado on 14/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var topView: UIView!
    
    var loginCallBack: ((Bool)->())?

    var viewModel: RegistrationViewModel = RegistrationViewModel(user: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = viewModel.title

        goBackButton.isHidden = viewModel.isAdmin
        topView.isHidden = viewModel.isAdmin
        signupButton.setTitle(viewModel.signupButtonTitle, for: .normal)

        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        emailTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)

        viewModel.email.bindAndFire { [unowned self] (_) in
            self.visibilities()
        }

        viewModel.username.bindAndFire { [unowned self] (_) in
            self.visibilities()
        }

        viewModel.passwordOne.bindAndFire { [unowned self] (_) in
            self.visibilities()
        }

        viewModel.passwordTwo.bindAndFire { [unowned self] (_) in
            self.visibilities()
        }
    }

    @objc private func handleTextInputChange() {
        viewModel.email.value = emailTextField.text ?? ""
        viewModel.username.value = usernameTextField.text ?? ""
        viewModel.passwordOne.value = passwordTextField.text ?? ""
        viewModel.passwordTwo.value = confirmPasswordTextField.text ?? ""
    }

    @objc private func visibilities() {
        if viewModel.checkFields() == nil {
            signupButton.layer.masksToBounds = false
            signupButton.backgroundColor = Configs.shared.buttonColor
        } else {
            signupButton.layer.masksToBounds = true
            signupButton.backgroundColor = Configs.shared.buttonColorDisabled
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    @IBAction func signUpPressed(_ sender: Any) {
        if let errorMessage = viewModel.checkFields() {
            AlertHelper.displayAlert(title: viewModel.title, message: errorMessage, displayTo: self)
            return
        }

        viewModel.registerUser(success: { (_) in
            if self.viewModel.isAdmin {
                AlertHelper.displayAlert(title: self.viewModel.title, message: "User will be created in a few moments", displayTo: self, completion: { (_) in
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                if let loginCallback = self.loginCallBack {
                    loginCallback(true)
                }
                self.navigationController?.dismiss(animated: true, completion: {})
            }
        }) { (errorMessage) in
            AlertHelper.displayAlert(title: self.viewModel.title, message: errorMessage, displayTo: self)
        }
    }

    @IBAction func goBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
