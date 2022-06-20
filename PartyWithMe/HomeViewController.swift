//
//  HomeViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    
    var user: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    func setUpElements() {
        
        /* load user */
        let userString: String = UserDefaults.standard.string(forKey: "userJson")!
        // Convert JSON to Object
        if let dataFromJsonString = userString.data(using: .utf8) {
            self.user = try! JSONDecoder().decode(User.self, from: dataFromJsonString)
        }
        
        // text fields
        userNameLabel.text = "Hello " + self.user!.firstname
        
    }
    
    @IBAction func signOutButton(_ sender: UIButton) {
        saveUserLoggedOut() // save logged-out param
        transitionToFirstView() // back to first view
    }
    
    func saveUserLoggedOut() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set(nil, forKey: "userJson")
        UserDefaults.standard.synchronize()
    }
    
    func transitionToFirstView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "first") as! FirstViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    

}
