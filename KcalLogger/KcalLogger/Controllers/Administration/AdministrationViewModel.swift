//
//  AdministrationViewModel.swift
//  KcalLogger
//
//  Created by Luís Machado on 20/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

final class AdministrationViewModel: AdministrationViewModelProtocol {
    var user: AppUser?

    internal let title = "Administration"

    internal var users: Dynamic<[AppUser]>

    func fetchUsers(finished: @escaping (String?)->()) {
        guard let user = user else { return }
        user.fetchUserList(success: { (userList) in
            self.users.value = userList.filter { $0.uid !=  user.uid }.sorted(by: { (u1, u2) -> Bool in
                u1.email < u2.email
            })
            finished(nil)
        }, failure: { (error) in
            finished(error)
        })
    }

    init() {
        self.user = AppUser.getCurrentUser()
        users = Dynamic([])
    }

    //MARK: Table Delegate
    func numberOfRows() -> Int {
        return users.value.count
    }

    func userFor(indexPath: IndexPath) -> AppUser {
        return users.value[indexPath.item]
    }
}
