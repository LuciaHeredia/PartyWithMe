//
//  HomeViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import DropDown

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var partysList: UITableView!
    
    @IBOutlet weak var cityDropDown: UIView!
    @IBOutlet weak var cityLabelDropDown: UILabel!
    
    @IBOutlet weak var dateDropDown: UIView!
    @IBOutlet weak var dateLabelDropDown: UILabel!
    
    let cityDropDownModule = DropDown()
    let dateDropDownModule = DropDown()
    
    var user: User? = nil
    
    // empty array of partys - original
    var allPartys = [Party]()
    
    // array of partys - for filter
    var filteredAllPartys = [Party]()
    
    // filter arrays
    var allCitys = [String]()
    var allDates = [String]()
    
    let imageEnding = ".jpg"
    let twelveMB : Int64 = 1024 * 1024 * 12
    
    lazy var background: DispatchQueue = {
        return DispatchQueue.init(label: "background.queue", attributes: .concurrent)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show spinner
        spinner.isHidden = false
        spinner.startAnimating()
        
        // load and set up user details
        setUpUserElements()
        
        // load partys from firebase
        self.background.async {
            // first load data
            self.allPartys = self.loadPartysData()
            DispatchQueue.main.async {
                // load filter arrays
                self.cityDropDownModule.anchorView = self.cityDropDown
                self.cityDropDownModule.dataSource = self.allCitys
                self.dateDropDownModule.anchorView = self.dateDropDown
                self.dateDropDownModule.dataSource = self.allDates
                
                // hide spinner
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                
                // list
                self.noFilteredList()
                
                // table list
                self.partysList.dataSource = self
                self.partysList.delegate = self
                self.partysList.reloadData()
            }
        }
    }
    
    func setUpUserElements() {
        
        /* load user */
        let userString: String = UserDefaults.standard.string(forKey: "userJson")!
        // Convert JSON to Object
        if let dataFromJsonString = userString.data(using: .utf8) {
            self.user = try! JSONDecoder().decode(User.self, from: dataFromJsonString)
        }
        
        // text fields
        userNameLabel.text = "Hello " + self.user!.firstname
        
    }
    
    func loadPartysData() -> [Party] {
        
        var partys = [Party]()
        let group = DispatchGroup.init()
        
        group.enter()
        let ref = Database.database(url: Constants.databaseLink).reference().child("partys")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let dict = child.value as? [String : AnyObject] ?? [:]
                
                // Get party value
                let id = child.key
                let name = dict["name"] as? String ?? ""
                let date = dict["date"] as? String ?? ""
                let day = dict["day"] as? String ?? ""
                let time = dict["time"] as? String ?? ""
                let city = dict["city"] as? String ?? ""
                let address = dict["address"] as? String ?? ""
                let totalAmount = dict["totalAmount"] as? Int ?? 0
                let currentAmount = dict["currentAmount"] as? Int ?? 0
                let description = dict["description"] as? String ?? ""
                let idImage = dict["idImage"] as? String ?? ""
                let idList = dict["idList"] as? String ?? ""
                
                // make Party model
                let party = Party(id: id, name: name, date: date, day: day, time: time, city: city, address: address, totalAmount: totalAmount, currentAmount: currentAmount, description: description, idList: idList, idImage: idImage)

                // add to list
                partys.append(party)
                
                // add to city filter array
                var enterCity: Bool = true
                for cityParty in self.allCitys {
                    if city == cityParty {
                        enterCity = false
                    }
                }
                if enterCity {
                    self.allCitys.append(city)
                }
                
                // add to date filter array
                var enterDate: Bool = true
                for dateParty in self.allDates {
                    if date == dateParty {
                        enterDate = false
                    }
                }
                if enterDate {
                    self.allDates.append(date)
                }
 
            }
            group.leave()
        }) { error in
            // Couldn't load data
            self.showErrorAlert("Couldn't load data, try again later.")
        }
        group.wait()
        
        return partys
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAllPartys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let party = filteredAllPartys[indexPath.row]
        let cell = partysList.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.partyNameLabel.text = party.name
        cell.dayLabel.text = party.day
        cell.dateLabel.text = party.date
        cell.timeLabel.text = party.time
        cell.cityLabel.text = party.city
        cell.addressLabel.text = party.address
        cell.amountLabel.text = String(party.currentAmount) + "/" + String(party.totalAmount)
        
        // set image from storage
        let imageName = party.idImage + imageEnding
        let downloadImageRef = Storage.storage().reference().child(imageName)
        let downloadTask = downloadImageRef.getData(maxSize: twelveMB) { data, error in
            if let data = data {
                let image = UIImage(data: data)
                cell.partyImage.image = image
            } else {
                print("Failed loading image!")
            }
        }
        downloadTask.resume()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        partysList.deselectRow(at: indexPath, animated: true)
        
        // send party selected to Party view
        let p:Party = filteredAllPartys[indexPath.row]
        let encodedData = try! JSONEncoder().encode(p)
        let jsonString = String(data: encodedData, encoding: .utf8)
        transitionToPartyView(partyJson: jsonString!)
    }
    
    @IBAction func signOutButton(_ sender: UIButton) {
        saveUserLoggedOut() // save logged-out param
    }
    
    func saveUserLoggedOut() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.set(nil, forKey: "userJson")
        UserDefaults.standard.synchronize()
        transitionToFirstView() // back to first view
    }
    
    func transitionToFirstView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.first) as! FirstViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func transitionToPartyView(partyJson: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: Constants.ViewNames.party) as! PartyViewController
        vc.modalPresentationStyle = .fullScreen
        vc.partyJson = partyJson
        vc.userConnected = user
        present(vc, animated: true, completion: nil)
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
    
    func noFilteredList() {
        filteredAllPartys = allPartys
    }
    
    func filterBy() {
        var filteredListPartys = [Party]()
        
        // filter by city only
        if self.cityLabelDropDown.text != Constants.filterNames.city &&
            self.dateLabelDropDown.text == Constants.filterNames.date {
            for party in allPartys {
                if party.city == self.cityLabelDropDown.text {
                    filteredListPartys.append(party)
                }
            }
        }
        
        // filter by date only
        else if self.cityLabelDropDown.text == Constants.filterNames.city &&
                self.dateLabelDropDown.text != Constants.filterNames.date {
            for party in allPartys {
                if party.date == self.dateLabelDropDown.text {
                    filteredListPartys.append(party)
                }
            }
        }
        
        else { // filter by city and date
            for party in allPartys {
                if party.city == self.cityLabelDropDown.text &&
                    party.date == self.dateLabelDropDown.text {
                    filteredListPartys.append(party)
                }
            }
        }
        
        // reload table
        filteredAllPartys = filteredListPartys
        self.partysList.dataSource = self
        self.partysList.delegate = self
        self.partysList.reloadData()
    }
    
    @IBAction func showCityList(_ sender: UIButton) {
        if !allCitys.isEmpty {
            cityDropDownModule.show()
            
            cityDropDownModule.direction = .bottom
            cityDropDownModule.bottomOffset = CGPoint(x: 0, y:(cityDropDownModule.anchorView?.plainView.bounds.height)!)
            
            cityDropDownModule.selectionAction = { [unowned self] (index: Int, item: String) in
                self.cityLabelDropDown.text = allCitys[index]
                filterBy()
            }
        }
    }
    
    @IBAction func showDateList(_ sender: UIButton) {
        if !allDates.isEmpty {
            dateDropDownModule.show()
            
            dateDropDownModule.direction = .bottom
            dateDropDownModule.bottomOffset = CGPoint(x: 0, y:(dateDropDownModule.anchorView?.plainView.bounds.height)!)
            
            dateDropDownModule.selectionAction = { [unowned self] (index: Int, item: String) in
                self.dateLabelDropDown.text = allDates[index]
                filterBy()
            }
        }
        
    }
    
    @IBAction func clearFilter(_ sender: UIButton) {
        self.cityLabelDropDown.text = Constants.filterNames.city
        self.dateLabelDropDown.text = Constants.filterNames.date
        // list
        self.noFilteredList()
        // reload table
        self.partysList.dataSource = self
        self.partysList.delegate = self
        self.partysList.reloadData()
    }
    
}
