//
//  EditingUserInfo.swift
//  KcalLogger
//
//  Created by Luís Machado on 21/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class EditingUserInfo: UIView {
    @IBOutlet weak var usernameLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(username: String) {
        self.usernameLabel.text = "Editing \(username)"
    }

}
