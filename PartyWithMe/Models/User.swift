//
//  User.swift
//  PartyWithMe
//
//  Created by lucia heredia on 18/06/2022.
//

import Foundation
import UIKit
import FirebaseDatabase


class User {
    var firstname: String
    var lastname: String
    var age: String
    var phone: String
    var email: String
    
    init(firstname: String, lastname: String, age: String, phone: String, email: String) {
        self.firstname = firstname
        self.lastname = firstname
        self.age = firstname
        self.phone = firstname
        self.email = firstname
    }
    
    init() {
        self.firstname = ""
        self.lastname = ""
        self.age = ""
        self.phone = ""
        self.email = ""
    }
    
    func getFirstName() -> String {
        return self.firstname
    }
    
    func getLastName() -> String {
        return self.lastname
    }
    
}
