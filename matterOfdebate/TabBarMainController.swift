//
//  TabBarMainController.swift
//  matterOfdebate
//
//  Created by Daniel Eichinger on 19.11.17.
//  Copyright © 2017 Gruppe7. All rights reserved.
//

import UIKit
import Firebase

// TODO pass user_obj to sub views http://www.thomashanning.com/passing-data-between-view-controllers/
class TabBarMainController: UITabBarController {
    var user_obj: User? = nil
    var ref : DatabaseReference!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch user data from database
        get_user()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation Controller in Case user, came from EmailRegistrationController
        self.navigationController?.navigationBar.isHidden = true
    }

    
    func get_user() {
        // get cached uid 
        if let usr_uid = Auth.auth().currentUser?.uid {
            ref = Database.database().reference()
            ref.child("users").child(usr_uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let username = value?["username"] as? String ?? ""
                let email = value?["email"] as? String ?? ""
                
                self.user_obj = User(uid: usr_uid, email: email, user_name: username)
                print(":-) Currently signed in User " + email)
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }

}
