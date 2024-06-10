//
//  ApiExtensions.swift
//  KcalLogger
//
//  Created by Luís Machado on 14/03/2019.
//  Copyright © 2019 Luís Machado. All rights reserved.
//

import UIKit
import Firebase

func getFirebaseError(error: Error) -> String? {
    if let error = error._userInfo as? [String:Any] {
        return error["NSLocalizedDescription"] as? String
    }

    return nil
}

//MARK: Error handler
func handleErrors(error: Error) -> String {
   if let error = error as? UserApiErrors {
        return error.handle()
    }
    return getFirebaseError(error: error) ?? (error as NSError).domain
}
