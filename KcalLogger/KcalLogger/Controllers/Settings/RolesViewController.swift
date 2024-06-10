//
//  RolesViewController.swift
//  KcalLogger
//
//  Created by Luís Machado on 21/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class RolesViewController: UITableViewController {

    var viewModel: RolesViewModel = RolesViewModel(user: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.roles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoleCell", for: indexPath)
        cell.textLabel?.text = viewModel.roleFor(row: indexPath.item)
        cell.accessoryType = viewModel.isRoleSelected(row: indexPath.item) ? .checkmark : .none
         return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.item == 0 {
            AlertHelper.displayAlert(title: "Roles", message: "This is the minimum role that a user can carry and therefore can't be removed", displayTo: self)
        } else {
            viewModel.selectUnselectRow(row: indexPath.row)
            self.tableView.reloadData()
        }
    }

    @IBAction func savePressed(_ sender: Any) {
        viewModel.changeRoles(success: {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }) { (error) in
            AlertHelper.displayAlert(title: self.viewModel.title, message: "There was an issue updating the user's roles. Please try again later", displayTo: self)
        }
    }

    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
