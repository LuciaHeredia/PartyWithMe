//
//  Party.swift
//  PartyWithMe
//
//  Created by lucia heredia on 01/07/2022.
//

import Foundation

struct Party: Codable {
    var name: String
    var date: String
    var day: String
    var city: String
    
    var totalAmount: Int
    var currentAmount: Int
    
    var description: String
    
    //var idListOfPeople: String
    var idImage: String
}
