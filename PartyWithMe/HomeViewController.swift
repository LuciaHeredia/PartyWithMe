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
        
        // text fields
        userNameLabel.text = "Hello " + (user?.getFirstName())!
        
        
    }
    
    @IBAction func signOutButton(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "first") as! FirstViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    

}
