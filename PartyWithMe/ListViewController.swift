//
//  ListViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 02/07/2022.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    var listOfPeople = [String]()
    var partyNameStr: String = ""
    
    @IBOutlet weak var partyName: UILabel!
    @IBOutlet weak var personsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set title
        partyName.text = partyNameStr
        
        personsTableView.dataSource = self
        personsTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfPeople.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = personsTableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
        cell.textLabel?.text = listOfPeople[indexPath.row]
        
        return cell
    }
    
    @IBAction func goBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
