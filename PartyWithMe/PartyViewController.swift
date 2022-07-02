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
    var partyId: String = ""
    var userConnected: User? = nil
    var userName: String = ""
    
    let imageEnding = ".jpg"
    let twelveMB : Int64 = 1024 * 1024 * 12
    
    let ref = Database.database(url: Constants.databaseLink).reference()
    
    lazy var loadListData: DispatchQueue = {
        return DispatchQueue.init(label: "loadListData.queue", attributes: .concurrent)
    }()

    lazy var loadPartyAgain: DispatchQueue = {
        return DispatchQueue.init(label: "loadPartyAgain.queue", attributes: .concurrent)
    }()
    
    lazy var savePartyDataDispatch: DispatchQueue = {
        return DispatchQueue.init(label: "savePartyDataDispatch.queue", attributes: .concurrent)
    }()

    lazy var saveListDataDispatch: DispatchQueue = {
        return DispatchQueue.init(label: "saveListDataDispatch.queue", attributes: .concurrent)
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
        
        // user name
        userName = userConnected!.firstname  + " " + userConnected!.lastname
        // party id
        partyId = party.id
        
        // screen elements
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
        self.loadListData.async {
            // first load data
            self.listOfPeople = self.loadListOfPeopleData()
            DispatchQueue.main.async {
                self.disableAddMeButton()
            }
        }
        
    }
    
    func disableAddMeButton() {
        if (party.currentAmount == party.totalAmount) {
            // disable button
            addMe.isEnabled = false
        } else {
            for person in listOfPeople {
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
        ref.child("listOfPeople").child(party.idList).observeSingleEvent(of: .value, with: { (snapshot) in
                        
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
    
    func loadPartyData(idParty: String) -> Party {
        
        var partyCurrentData: Party = Party()
        let group = DispatchGroup.init()
        
        group.enter()
        ref.child("partys").child(idParty).observeSingleEvent(of: .value, with: { snapshot in
                        
            // Get party values
            let value = snapshot.value as? NSDictionary
            let partyId = value?["id"] as? String ?? ""
            let partyName = value?["name"] as? String ?? ""
            let partyDate = value?["date"] as? String ?? ""
            let partyDay = value?["day"] as? String ?? ""
            let partyCity = value?["city"] as? String ?? ""
            let partyTotalAmount = value?["totalAmount"] as? Int ?? 0
            let partyCurrentAmount = value?["currentAmount"] as? Int ?? 0
            let partyDescription = value?["description"] as? String ?? ""
            let partyIdList = value?["idList"] as? String ?? ""
            let partyIdImage = value?["idImage"] as? String ?? ""
            
            // add to party
            partyCurrentData = Party(id: partyId, name: partyName, date: partyDate, day: partyDay, city: partyCity, totalAmount: partyTotalAmount, currentAmount: partyCurrentAmount, description: partyDescription, idList: partyIdList, idImage: partyIdImage)
            
            group.leave()
            
        }) { error in
            // Couldn't load data
            self.showErrorAlert("Couldn't load data, try again later.")
        }
        group.wait()
        
        return partyCurrentData
    }
    
    @IBAction func addMeButton(_ sender: UIButton) {

        // set list of people
        self.loadPartyAgain.async {
            // load again party data
            self.party = self.loadPartyData(idParty: self.party.id)
            DispatchQueue.main.async {
                // check available space
                self.disableAddMeButton()
                if (self.party.currentAmount != self.party.totalAmount) {
                    self.addUserName()
                } else {
                    self.showErrorAlert("Capacity full!")
                }
            }
        }

    }
    
    func addUserName() {
        var partySaved: Bool = false
        var listSaved: Bool = false

        // save party data
        self.savePartyDataDispatch.async {
            partySaved = self.savePartyData()
            DispatchQueue.main.async {
                
                // save list data
                self.saveListDataDispatch.async {
                    listSaved = self.saveListOfPeople()
                    DispatchQueue.main.async { [self] in
                        
                        if listSaved && partySaved {
                            self.showErrorAlert("You were added to the list!")
                            self.disableAddMeButton()
                            self.amountLabel.text = String(self.party.currentAmount) + "/" + String(self.party.totalAmount)
                        } else {
                            self.showErrorAlert("Couldn't save data, try again later.")
                        }
                        
                    }
                }
                
                
            }
        }
        
    }
    
    func savePartyData() -> Bool {
        var partySaved: Bool = false
        let group = DispatchGroup.init()
        
        // add one to currentAmount
        party.currentAmount = party.currentAmount + 1
        
        // add party data to DB
        group.enter()
        ref.child("partys").child(partyId).updateChildValues(["currentAmount": party.currentAmount]) {
          (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Party data could not be saved: \(error).")
          } else {
                print("Party Data saved successfully!")
                partySaved = true
          }
            group.leave()
        }
        group.wait()
        
        return partySaved
    }
    
    func saveListOfPeople() -> Bool {
        var listSaved: Bool = false
        let group = DispatchGroup.init()
        
        // add user name to list
        listOfPeople.append(userName)
        
        // add list data to DB
        group.enter()
        ref.child("listOfPeople").child(party.idList).child(String(party.currentAmount)).setValue(["name": userName]) {
          (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("List data could not be saved: \(error).")
          } else {
                print("List data saved successfully!")
                listSaved = true
          }
            group.leave()
        }
        group.wait()
        
        return listSaved
    }
    
    @IBAction func goBackButton(_ sender: UIButton) {
        transitionToHomeView()
    }
    
    @IBAction func goToListButton(_ sender: UIButton) {
        transitionToListView()
    }
    
    func transitionToHomeView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.home) as! HomeViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func transitionToListView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.list) as! ListViewController
        vc.modalPresentationStyle = .fullScreen
        vc.listOfPeople = listOfPeople
        present(vc, animated: true, completion: nil)
    }

}
