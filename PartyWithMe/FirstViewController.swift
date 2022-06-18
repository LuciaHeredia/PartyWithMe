//
//  ViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit
import Lottie

class FirstViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }

    func setUpElements() {
        
        // Start AnimationView
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.play()
        
    }

    @IBAction func logIn(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.login) as! LogInViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.signin) as! SignInViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
}

