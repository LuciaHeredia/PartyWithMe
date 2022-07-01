//
//  PartyViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class PartyViewController: UIViewController {

    @IBOutlet weak var partyNameLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var partyImage: UIImageView!
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addMe: UIButton!
    
    var partyJson: String = ""
    var party: Party = Party()
    var listOfPeople = [String]()
    var userConnected: User? = nil
    var userName: String = ""
    
    let imageEnding = ".jpg"
    let twelveMB : Int64 = 1024 * 1024 * 12
    
    lazy var background: DispatchQueue = {
        return DispatchQueue.init(label: "background.queue", attributes: .concurrent)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show spinner
        imageSpinner.isHidden = false
        imageSpinner.startAnimating()
        
        // json to object
        if let dataFromJsonString = partyJson.data(using: .utf8) {
            party = try! JSONDecoder().decode(Party.self,from: dataFromJsonString)
            setUpElements()
        }
        
    }
    
    func setUpElements() {
        
        partyNameLabel.text = party.name
        dayLabel.text = party.day
        dateLabel.text = party.date
        cityLabel.text = party.city
        amountLabel.text = String(party.currentAmount) + "/" + String(party.totalAmount)
        descriptionLabel.text = party.description
        
        // set image from storage
        let imageName = party.idImage + imageEnding
        let downloadImageRef = Storage.storage().reference().child(imageName)
        let downloadTask = downloadImageRef.getData(maxSize: twelveMB) { data, error in
            if let data = data {
                // hide spinner
                self.imageSpinner.stopAnimating()
                self.imageSpinner.isHidden = true
                
                let image = UIImage(data: data)
                self.partyImage.image = image
            } else {
                print("Failed loading image!")
            }
        }
        downloadTask.resume()
        
        // set list of people
        self.background.async {
            // first load data
            self.listOfPeople = self.loadListOfPeopleData()
            DispatchQueue.main.async {
                print(self.listOfPeople)
                self.disableAddMeButton()
            }
        }
        
    }
    
    func disableAddMeButton() {
        // disable ADDME button
        if (party.currentAmount == party.totalAmount) {
            for person in listOfPeople {
                userName = userConnected!.firstname  + " " + userConnected!.lastname
                if person == userName {
                    // disable button
                    addMe.isEnabled = false
                }
            }
        }
    }
    
    func loadListOfPeopleData() -> [String] {
        
        var peoples = [String]()
        let group = DispatchGroup.init()
        
        group.enter()
        let ref = Database.database(url: Constants.databaseLink).reference().child("listOfPeople")
        ref.child(party.idList).observeSingleEvent(of: .value, with: { (snapshot) in
                        
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject] ?? [:]
                
                // Get  value
                let name = dict["name"] as? String ?? ""
                
                // add to list
                peoples.append(name)
                
            }
            group.leave()
        }) { error in
            // Couldn't load data
            self.showErrorAlert("Couldn't load data, try again later.")
        }
        group.wait()
        
        return peoples
    }
    
    func showErrorAlert(_ message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // number of seconds of alert
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addMeButton(_ sender: UIButton) {

        // add one to currentAmount
        // save in listOfPeople
        // show: user added
 
    }
    
    @IBAction func goBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
