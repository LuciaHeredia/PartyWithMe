//
//  Utilities.swift
//  PartyWithMe
//
//  Created by lucia heredia on 17/06/2022.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textField:UITextField) {
        let bottomLine = CALayer() // create bottom line
        
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        textField.borderStyle = .none // remove border on text field
        textField.layer.addSublayer(bottomLine) // add line to text field
    }
    
    static func isNameValid(_ name:String) -> Bool {
        guard name.count > 2, name.count < 15 else { return false }
        let nameRegEx = "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: name)
    }
    
    static func isAgeValid(_ age:String) -> Bool {
        guard Int(age) ?? 0 > 15 else { return false }
        let ageRegEx = "[1-9][0-9]"
        let ageTest = NSPredicate(format:"SELF MATCHES %@", ageRegEx)
        return ageTest.evaluate(with: age)
    }
    
    static func isPhoneValid(_ phone:String) -> Bool {
        guard phone.count == 10 else { return false }
        let phoneRegEx = "[0][5][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: phone)
    }
    
    static func isEmailValid(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isPasswordValid(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
}
