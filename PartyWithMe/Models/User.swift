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
    
}
