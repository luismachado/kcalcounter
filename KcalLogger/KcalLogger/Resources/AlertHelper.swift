//
//  AlertHelper.swift
//  KcalLogger
//
//  Created by Luís Machado on 14/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class AlertHelper {

    static func displayAlert(title: String, message: String, displayTo: UIViewController, completion: @escaping (UIAlertAction) -> Void = { _ in return }) {

        let alert = UIAlertController(title: title, message: message , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))

        displayTo.present(alert, animated: true, completion: nil)

    }


    static func displayAlertCancel(title: String, message: String, displayTo: UIViewController, okCallback: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: okCallback))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        displayTo.present(alert, animated: true, completion: nil)
    }

    static func displayEmailRequest(defaultText: String = "", displayTo: UIViewController, okCallback: @escaping (String) -> Void) {
        let defaultText: String = defaultText

        let alert = UIAlertController(title: "Password Recovery", message: "Please enter the email associated with your account", preferredStyle: UIAlertController.Style.alert)

        let action = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if let email = textField.text {
                if email.count == 0 || !email.isValidEmail() {
                    AlertHelper.displayAlert(title: "Password Recovery", message: "Email is empty or incorrectly formatted", displayTo: displayTo, completion: { (_) in
                        self.displayEmailRequest(defaultText: email, displayTo: displayTo, okCallback: okCallback)
                    })
                } else {
                    okCallback(email)
                }
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alert.addTextField { (textField) in
            textField.text = defaultText
            textField.placeholder = "email@email.com"
            textField.keyboardType = .emailAddress
        }

        alert.addAction(cancel)
        alert.addAction(action)

        displayTo.present(alert, animated: true) {}
    }

    static func getTextFieldConfig(initialText: String, placeholder: String, keyboardType: UIKeyboardType, closure: @escaping TextField.Action) -> TextField.Config {
        return { textField in
            textField.becomeFirstResponder()
            textField.textColor = .black
            textField.text = initialText
            textField.leftViewPadding = 12
            textField.borderWidth = 1
            textField.cornerRadius = 8
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = keyboardType
            textField.returnKeyType = .done
            textField.action(closure: closure)
        }
    }
}
