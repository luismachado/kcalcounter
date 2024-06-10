//
//  AdministrationViewModelProtocol.swift
//  KcalLogger
//
//  Created by Luís Machado on 20/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import Foundation

protocol AdministrationViewModelProtocol: class {
    var user: AppUser? { get set }
    var title: String { get }

    var users: Dynamic<[AppUser]> { get set }

    func fetchUsers(finished: @escaping (String?)->())

    //MARK: Table Delegate
    func numberOfRows() -> Int
    func userFor(indexPath: IndexPath) -> AppUser
}

