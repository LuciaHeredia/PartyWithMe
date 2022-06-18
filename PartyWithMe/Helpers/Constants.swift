//
//  Constants.swift
//  PartyWithMe
//
//  Created by lucia heredia on 18/06/2022.
//

import Foundation
import UIKit

struct Constants {
    
    static let link = "https://partywithme-2022b-default-rtdb.europe-west1.firebasedatabase.app/"

    
    struct Texts {
        static let firstName = "First Name"
        static let lastName = "Last Name"
        static let age = "Age"
        static let phone = "Phone"
        static let email = "Email"
        static let password = "Password"
    }
    
    struct ViewNames {
        static let first = "first"
        static let login = "login"
        static let signin = "signin"
        static let home = "home"
        static let party = "party"
    }
    
    struct ErrorMsg {
        
        // SIGN IN
        static let empty = "Please fill in all fields."
        static let fnameInvalid = "First name must contain at least 3 characters and only letters."
        static let lnameInvalid = "Last name must contain at least 3 characters and only letters."
        static let ageInvalid = "Age must contain numbers only and be between 16 and 99."
        static let phoneInvalid = "Phone must start with '05' and contain 10 numbers."
        static let emailInvalid = "Check Email address."
        static let passwordInvalid = "Password must contain at least 8 characters, a special character and a number."
        
        static let userCreated = "User created successfully! Verify your email to LogIn."
        static let userNotCreated = "Error creating user."
        static let userDbNotCreated = "Error creating user Database."
        static let userAuthDeleted = "Error creating user DB, user Auth deleted successfully!"
        static let userVerifyNotCreated = "Error sending verify email."
        static let userVerifyFailed = "Error: Either the user is not available, or the user is already verified."
        
        // LOG IN
        static let userLoggedIn = "Successfully Logged In!"
        static let userYetVerified = "Email yet verified."
        static let userDoesntExist = "User doesn't exist."
        static let userWrongCredentials = "Email or Password incorrect."
        
    }
    
    
}
