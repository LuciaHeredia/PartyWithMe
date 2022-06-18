//
//  User.swift
//  PartyWithMe
//
//  Created by lucia heredia on 18/06/2022.
//

import Foundation
import UIKit
import FirebaseDatabase


struct User: Decodable {
    var firstname: String
    var lastname: String
    var age: String
    var phone: String
    var email: String
    
    init(firstname: String, lastname: String, age: String, phone: String, email: String) {
        self.firstname = firstname
        self.lastname = lastname
        self.age = age
        self.phone = phone
        self.email = email
    }
    
    // init with snapshot
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        firstname = snapshotValue["firstname"] as! String
        lastname = snapshotValue["lastname"] as! String
        age = snapshotValue["age"] as! String
        phone = snapshotValue["phone"] as! String
        email = snapshotValue["email"] as! String
    }
    
    // function for saving data
    func toAnyObject() -> Any {
        return [
            "firstname": firstname,
            "lastname": lastname,
            "age": age,
            "phone": phone,
            "email": email
        ]
    }
    
}
