//
//  LogInViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit
import FirebaseAuth
import Lottie

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    
    var email: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        errorLabel.isHidden = true
        
        // Create cleaned versions of the text field
        email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @IBAction func continueToHome(_ sender: UIButton) {
        
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
                    
                    // show alert: Notify logged in
                    let alert = UIAlertController(title: "", message: Constants.ErrorMsg.userLoggedIn, preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    
                    // hide animation loading
                    self.animationView.isHidden = true
                    
                    // number of seconds of alert
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when){
                        alert.dismiss(animated: true, completion: nil)
                        
                        // TODO: send User to HOME view.
                        
                        self.transitionToHomeView() // go to home view
                        
                        //let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.home) as! HomeViewController
                        //self.view.window?.rootViewController = homeViewController
                        //self.view.window?.makeKeyAndVisible()
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
        if email == "" ||
            password == "" {
            return Constants.ErrorMsg.empty
        }
        
        // Check if email is correct
        if Utilities.isEmailValid(email) == false {
            // Email wrong
            return Constants.ErrorMsg.emailInvalid
        }
        
        // Check if the password is secure
        if Utilities.isPasswordValid(password) == false {
            // Password isn't secure enough
            return Constants.ErrorMsg.passwordInvalid
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        animationView.isHidden = true
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    func transitionToHomeView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.home) as! HomeViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}
