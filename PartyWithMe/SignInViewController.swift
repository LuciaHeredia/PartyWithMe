//
//  SignInViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit
import FirebaseAuth
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        errorlabel.isHidden = true
        
        // text fields hints
        firstNameTextField.placeholder = Constants.Texts.firstName
        lastNameTextField.placeholder = Constants.Texts.lastName
        ageTextField.placeholder = Constants.Texts.age
        phoneTextField.placeholder = Constants.Texts.phone
        emailTextField.placeholder = Constants.Texts.email
        passwordTextField.placeholder = Constants.Texts.password
    }
    
    @IBAction func saveUserButton(_ sender: UIButton) {
        
        // validate fields
        let error = validateFields()
        
        if error != nil {
            // There's something wrong with the fields, show error message
            self.errorlabel.isHidden = false
            showError(error!)
        } else {
            
            // Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let age = ageTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let phone = phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    // There was an error creating the user
                    self.errorlabel.isHidden = false
                    self.showError("Error creating user")
                } else {
                    // User was created successfully, now store the first name and last name
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": result!.user.uid ]) { (error) in
                        
                        if error != nil {
                            // Show error message
                            self.errorlabel.isHidden = false
                            self.showError("Error saving user data")
                        }
                    }
                    
                    // hide error label
                    self.errorlabel.isHidden = true
                    
                    // show alert
                    let alert = UIAlertController(title: "", message: "User created successfully!", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)

                    // number of seconds of alert
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when){
                        alert.dismiss(animated: true, completion: nil)
                        
                        // return to first view
                        self.transitionToFirstView()
                    }
                    
                }
                
            }
        }
    }
    
    /* If correct - returns nil
       else - returns error message */
    func validateFields() -> String? {
        
        let cleanedFirstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedLastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAge = ageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPhone = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check that all fields are filled in
        if cleanedFirstName == "" ||
            cleanedLastName == "" ||
            cleanedAge == "" ||
            cleanedPhone == "" ||
            cleanedEmail == "" ||
            cleanedPassword == "" {
            return "Please fill in all fields."
        }
        
        // Check if first name valid
        if Utilities.isNameValid(cleanedFirstName) == false {
            // first name not valid
            return "First name must contain at least 3 characters and only letters."
        }
        
        // Check if last name valid
        if Utilities.isNameValid(cleanedLastName) == false {
            // last name not valid
            return "Last name must contain at least 3 characters and only letters."
        }
        
        // Check if age valid
        if Utilities.isAgeValid(cleanedAge!) == false {
            // age not valid
            return "Age must contain numbers only and be 16 or above."
        }
        
        // Check if phone valid
        if Utilities.isPhoneValid(cleanedPhone!) == false {
            // phone not valid
            return "Phone must start with '05' and contain 10 numbers."
        }
        
        // Check if email is correct
        if Utilities.isEmailValid(cleanedEmail) == false {
            // Email wrong
            return "Check Email address."
        }
        
        // Check if the password is secure
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Password must contain at least 8 characters, a special character and a number."
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        errorlabel.text = message
        errorlabel.alpha = 1
    }
    
    func transitionToFirstView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "first") as! FirstViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

}
