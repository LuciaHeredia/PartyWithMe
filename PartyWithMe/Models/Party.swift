//
//  Party.swift
//  PartyWithMe
//
//  Created by lucia heredia on 01/07/2022.
//

import Foundation

struct Party: Codable {
    var id: String = ""
    var name: String = ""
    var date: String = ""
    var day: String = ""
    var time: String = ""
    var city: String = ""
    var address: String = ""
    
    var totalAmount: Int = 0
    var currentAmount: Int = 0
    
    var description: String = ""
    
    var idList: String = ""
    var idImage: String = ""
}
