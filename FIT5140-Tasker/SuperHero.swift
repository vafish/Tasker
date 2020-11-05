//
//  SuperHero.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/3/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class SuperHero: NSObject, Codable{

    var id: String?
    var name:String=""
    var abilities:String=""
    var tid: String = ""

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case abilities
        case tid
    }
}



class Team: NSObject{

var id: String?
var name:String=""
var heroes:[SuperHero]=[]
}
