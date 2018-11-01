//
//  PiictoAuth.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/21.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FirebaseAuth

final class PiictoAuth {
    
    static func signInAnonymously() {
        if let currentUser = Auth.auth().currentUser {
            print("Logged in")
            print("uid: \(currentUser.uid)")
            UserDefaults.standard.set(currentUser.uid, forKey: .uid)
            _ = EntityManager.shared
            return
        }
        Auth.auth().signInAnonymously { user, error in
            if let error = error {
                print("error: \(error.localizedDescription)")
                return
            }
            guard let user = user else {
                print("user is nil.")
                return
            }
            print("Signed in with uid: \(user.uid)")
            UserDefaults.standard.set(user.uid, forKey: .uid)
        }
    }
}
