//
//  HomeViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class HomeViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var partysList: UITableView!
    
    var user: User? = nil
    
    // empty array of partys
    var allPartys = [Party]()
    
    let imageEnding = ".jpg"
    let twelveMB : Int64 = 1024 * 1024 * 12
    
    lazy var background: DispatchQueue = {
        return DispatchQueue.init(label: "background.queue", attributes: .concurrent)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show spinner
        self.spinner.isHidden = false
        spinner.startAnimating()
        
        // load and set up user details
        setUpUserElements()
        
        // load partys from firebase
        self.background.async {
            // first load data
            self.allPartys = self.loadPartysData()
            DispatchQueue.main.async {
                // hide spinner
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                // table list
                self.partysList.dataSource = self
                self.partysList.reloadData()
                // then setup collection
                self.setUpListElements()
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
                let name = dict["name"] as? String ?? ""
                let date = dict["date"] as? String ?? ""
                let day = dict["day"] as? String ?? ""
                let city = dict["city"] as? String ?? ""
                let totalAmount = dict["totalAmount"] as? Int ?? 0
                let currentAmount = dict["currentAmount"] as? Int ?? 0
                let description = dict["description"] as? String ?? ""
                let idImage = dict["idImage"] as? String ?? ""
                
                /*
                // party list
                ref.child("listOfPeople").observeSingleEvent(of: .value, with: { snapshot in
                    // Get value
                    let value = snapshot.value as? NSDictionary
                    
                })*/
                
                // make Party model
                let party = Party(name: name, date: date, day: day, city: city, totalAmount: totalAmount, currentAmount: currentAmount, description: description, idImage: idImage)
                
                // add to list
                partys.append(party)
 
            }
            group.leave()
        }) { error in
            // Couldn't load data
            self.showErrorAlert("Couldn't load data, try again later.")
        }
        group.wait()
        
        return partys
    }
    
    func setUpListElements() {
        
        /* load partys in cards */
        
        
        for p in allPartys {
            print(p)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPartys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let party = allPartys[indexPath.row]
        let cell = partysList.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.partyNameLabel.text = party.name
        cell.dayLabel.text = party.day
        cell.dateLabel.text = party.date
        cell.cityLabel.text = party.city
        cell.amountLabel.text = String(party.currentAmount) + "/" + String(party.totalAmount)
        
        // set image from storage
        let imageName = party.idImage + imageEnding
        let downloadImageRef = Storage.storage().reference().child(imageName)
        let downloadTask = downloadImageRef.getData(maxSize: twelveMB) { data, error in
            if let data = data {
                let image = UIImage(data: data)
                cell.partyImage.image = image
            }
            print("Failed loading image!")
        }
        downloadTask.resume()
        
        return cell
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
    
    func transitionToPartyView() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "party") as! PartyViewController
        vc.modalPresentationStyle = .fullScreen
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
    
}
