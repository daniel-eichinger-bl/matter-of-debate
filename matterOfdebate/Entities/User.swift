//
//  User.swift
//  matterOfdebate
//
//  Created by Daniel Eichinger on 16.11.17.
//  Copyright © 2017 Gruppe7. All rights reserved.
//

import Foundation
import FirebaseAuth

struct User {
    let uid: String
    let email: String
    let user_name: String
    let isAdmin: Bool
    
    
    // Inits a User with Data from Firebase
    init(userData: FirebaseAuth.User, user_name: String, isAdmin: Bool = false) {
        self.user_name = user_name
        uid = userData.uid
        if let mail = userData.providerData.first?.email {
            email = mail
        } else {
            email = ""
        }
        self.isAdmin = isAdmin
    }
    
    init(uid: String, email: String, user_name: String, isAdmin: Bool = false) {
        self.user_name = user_name
        self.uid = uid
        self.email = email
        self.isAdmin = isAdmin
    }
    
    func getUserStrings() -> Dictionary<String, Any> {
        return ["username": self.user_name, "email": self.email, "isAdmin": self.isAdmin]
    }
}
