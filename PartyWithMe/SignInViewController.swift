//
//  SignInViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseDatabase
import Lottie

class SignInViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorlabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    
    var firstName: String = ""
    var lastName: String = ""
    var age: String = ""
    var phone: String = ""
    var email: String = ""
    var password: String = ""
    
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
    
    func getCleanedData() {
        firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        age = ageTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        phone = phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @IBAction func saveUserButton(_ sender: UIButton) {
        
        // Create cleaned versions of the data
        getCleanedData()
        
        // hide error label
        self.errorlabel.isHidden = true
        
        // start animation loading
        self.startAnimLoading()
        
        // validate fields
        let error = validateFields()
        
        if error != nil {
            // There's something wrong with the fields, show error message
            showError(error!)
        } else {
            
            // Create the user ***********
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    
                    // There was an error creating the user
                    self.showError(Constants.ErrorMsg.userNotCreated)
                } else {
                    
                    // Store user Database ***********
                    let ref = Database.database(url: Constants.link).reference().child("users")
                    let user = ["firstname": self.firstName,
                                "lastname": self.lastName,
                                "age": self.age,
                                "phone": self.phone,
                                "email": self.email
                            ] as [String : Any]
                    ref.child(result!.user.uid).setValue(user, withCompletionBlock: { (error, snapshot) in
                        
                        // Check for errors
                        if error != nil {
                            
                            // Error creating user DB
                            self.showError(Constants.ErrorMsg.userDbNotCreated)
                            
                            // delete user auth
                            let thisUser = Auth.auth().currentUser
                            thisUser?.delete { errorDeleting in
                              if let thisError = errorDeleting {
                                print(thisError)
                              } else {
                                  print(Constants.ErrorMsg.userAuthDeleted)
                              }
                            }
                            
                        } else {
                            
                            // Sending verify email ***********
                            if result?.user != nil && !result!.user.isEmailVerified {
                                result!.user.sendEmailVerification(completion: { (errorVerify) in
                                    
                                    // Check for errors
                                    if errorVerify != nil {
                                        
                                        // Error sending verify email
                                        self.showError(Constants.ErrorMsg.userVerifyNotCreated)
                                    } else {
                                        
                                        // show alert: Notify verify email sent
                                        let alert = UIAlertController(title: "", message: Constants.InfoMsg.userCreated, preferredStyle: .alert)
                                        self.present(alert, animated: true, completion: nil)
                                        
                                        // hide animation loading
                                        self.animationView.isHidden = true
                                        
                                        // number of seconds of alert
                                        let when = DispatchTime.now() + 2
                                        DispatchQueue.main.asyncAfter(deadline: when){
                                            alert.dismiss(animated: true, completion: nil)
                                            self.transitionToFirstView() // return to first view
                                        }
                                        
                                    }
                                })
                            } else {
                                
                                // Error creating the user:
                                // Either the user is not available, or the user is already verified.
                                self.showError(Constants.ErrorMsg.userVerifyFailed)
                            }
                            
                        }
                        
                    })
                }
                
            }
        }
    }
    
    func startAnimLoading() {
        animationView.isHidden = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.play()
    }
    
    /* If correct - returns nil
       else - returns error message */
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if self.firstName == "" ||
            self.lastName == "" ||
            self.age == "" ||
            self.phone == "" ||
            self.email == "" ||
            self.password == "" {
            return Constants.ErrorMsg.empty
        }
        
        // Check if first name valid
        if Utilities.isNameValid(self.firstName) == false {
            // first name not valid
            return Constants.ErrorMsg.fnameInvalid
        }
        
        // Check if last name valid
        if Utilities.isNameValid(self.lastName) == false {
            // last name not valid
            return Constants.ErrorMsg.lnameInvalid
        }
        
        // Check if age valid
        if Utilities.isAgeValid(self.age) == false {
            // age not valid
            return Constants.ErrorMsg.ageInvalid
        }
        
        // Check if phone valid
        if Utilities.isPhoneValid(self.phone) == false {
            // phone not valid
            return Constants.ErrorMsg.phoneInvalid
        }
        
        // Check if email is correct
        if Utilities.isEmailValid(self.email) == false {
            // Email wrong
            return Constants.ErrorMsg.emailInvalid
        }
        
        // Check if the password is secure
        if Utilities.isPasswordValid(self.password) == false {
            // Password isn't secure enough
            return Constants.ErrorMsg.passwordInvalid
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        animationView.isHidden = true
        errorlabel.text = message
        errorlabel.isHidden = false
    }
    
    func transitionToFirstView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.first) as! FirstViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

}
