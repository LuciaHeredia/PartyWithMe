//
//  ListViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 02/07/2022.
//

import UIKit

class ListViewController: UIViewController {

    var listOfPeople = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(listOfPeople)
    }
    
    
    @IBAction func goBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
