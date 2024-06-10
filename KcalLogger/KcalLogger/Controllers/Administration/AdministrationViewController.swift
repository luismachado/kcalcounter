//
//  AdministrationViewController.swift
//  KcalLogger
//
//  Created by Luís Machado on 20/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit

class AdministrationViewController: UITableViewController {

    let viewModel: AdministrationViewModelProtocol = AdministrationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.title

        viewModel.users.bindAndFire { [unowned self] (_) in
            self.tableView.reloadData()
        }
        refresh()
    }

    @IBAction func pullToRefresh(_ sender: Any) {
        refresh()
    }

    @objc private func refresh() {
        viewModel.fetchUsers { (errorMessage) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.refreshControl?.endRefreshing()
            })
            if let error = errorMessage {
                AlertHelper.displayAlert(title: self.viewModel.title, message: error, displayTo: self)
            }
        }
    }

    @IBAction func addUser(_ sender: Any) {
        performSegue(withIdentifier: "showRegistration", sender: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.tableView.reloadData()
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSettings" {
            guard let settingsVC = segue.destination as? SettingsViewController, let selectedIdx = tableView.indexPathForSelectedRow else {return}
            let user = viewModel.userFor(indexPath: selectedIdx)
            tableView.deselectRow(at: selectedIdx, animated: false)
            settingsVC.adminModel = self.viewModel
            settingsVC.viewModel = SettingsViewModel(user: user)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = viewModel.userFor(indexPath: indexPath)
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.email
        return cell
    }

}
