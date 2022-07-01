//
//  PartyViewController.swift
//  PartyWithMe
//
//  Created by lucia heredia on 08/06/2022.
//

import UIKit
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
    
    var partyJson: String = ""
    var party: Party = Party()
    
    let imageEnding = ".jpg"
    let twelveMB : Int64 = 1024 * 1024 * 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show spinner
        imageSpinner.isHidden = false
        imageSpinner.startAnimating()
        
        // json to object
        do{
            if let dataFromJsonString = partyJson.data(using: .utf8) {
                party = try JSONDecoder().decode(Party.self,from: dataFromJsonString)
                setUpElements()
            }
        }catch{
            print("Failed converting json string to object!")
            print(error)
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
    }
    
    @IBAction func addMeButton(_ sender: UIButton) {
        
    }
    
    @IBAction func goBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

}
