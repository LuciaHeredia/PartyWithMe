//
//  LogInViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit
import FirebaseAuth
import Lottie
import FirebaseDatabase

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    
    var email: String = ""
    var password: String = ""
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        errorLabel.isHidden = true
        
        // text fields hints
        emailTextField.placeholder = Constants.Texts.email
        passwordTextField.placeholder = Constants.Texts.password
    }
    
    func getCleanedData() {
        email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @IBAction func continueToHome(_ sender: UIButton) {
        
        // Create cleaned versions of the text field
        getCleanedData()
        
        // hide error label
        self.errorLabel.isHidden = true
        
        // start animation loading
        self.startAnimLoading()
        
        // validate fields
        let error = validateFields()
        
        if error != nil {
            // There's something wrong with the fields, show error message
            showError(error!)
        } else {
        
            // Signing in user ***********
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    // Couldn't sign in
                    self.showError(error!.localizedDescription)
                }
                else {
                    
                    // User verified email ***********
                    if Auth.auth().currentUser == nil || !Auth.auth().currentUser!.isEmailVerified {
                        // Couldn't sign in
                        self.showError(Constants.ErrorMsg.userYetVerified)
                    } else {
                        
                        // show alert: Notify logged in
                        let alert = UIAlertController(title: "", message: Constants.InfoMsg.userLoggedIn, preferredStyle: .alert)
                        self.present(alert, animated: true, completion: nil)
                        
                        // hide animation loading
                        self.animationView.isHidden = true
                        
                        // number of seconds of alert
                        let when = DispatchTime.now() + 1
                        DispatchQueue.main.asyncAfter(deadline: when){
                            alert.dismiss(animated: true, completion: nil)
                            self.loadUserData(userUid: result!.user.uid)
                        }
                        
                    }
                    
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
        if email == "" || password == "" {
            return Constants.ErrorMsg.empty
        }
        
        // Check if email is correct
        if Utilities.isEmailValid(email) == false {
            // Email wrong
            return Constants.ErrorMsg.emailInvalid
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        animationView.isHidden = true
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    @IBAction func forgotPasswordButton(_ sender: UIButton) {
        let forgotPasswordAlert = UIAlertController(title: Constants.InfoMsg.forgotPassword, message: Constants.InfoMsg.enterEmail, preferredStyle: .alert)
        forgotPasswordAlert.addTextField { (textField) in
            textField.placeholder = Constants.InfoMsg.enterEmail
        }
        forgotPasswordAlert.addAction(UIAlertAction(title: Constants.Texts.cancel, style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: Constants.InfoMsg.resetPassword, style: .default, handler: { (action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                if error != nil{
                    let resetFailedAlert = UIAlertController(title: Constants.InfoMsg.resetFailed, message: error?.localizedDescription, preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: Constants.Texts.ok, style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }else {
                    let resetEmailSentAlert = UIAlertController(title: Constants.InfoMsg.resetSuccess, message: Constants.InfoMsg.checkEmail, preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: Constants.Texts.ok, style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            })
        }))
        self.present(forgotPasswordAlert, animated: true, completion: nil) // show alert
    }
    
    func loadUserData(userUid: String) {
        let ref = Database.database(url: Constants.link).reference().child("users")
        ref.child(userUid).observeSingleEvent(of: .value, with: { snapshot in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let userFirstname = value?["firstname"] as? String ?? ""
            let userLastname = value?["lastname"] as? String ?? ""
            let userAge = value?["age"] as? String ?? ""
            let userPhone = value?["phone"] as? String ?? ""
            let userEmail = self.email
            self.user = User(firstname: userFirstname, lastname: userLastname, age: userAge, phone: userPhone, email: userEmail)
            
            self.transitionToHomeView() // go to home view
        }) { error in
            // Couldn't load user data
            self.showError("Couldn't load user data, try again later.")
        }

    }
    
    func transitionToHomeView() {
                
        // TODO: make HOME the root view.
        
        //let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.home) as! HomeViewController
        //self.view.window?.rootViewController = homeViewController
        //self.view.window?.makeKeyAndVisible()
        
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.home) as! HomeViewController
        vc.modalPresentationStyle = .fullScreen
        vc.user = self.user
        present(vc, animated: true)
        
    }
    
}
