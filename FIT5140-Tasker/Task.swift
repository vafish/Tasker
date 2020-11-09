//
//  SuperHero.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/3/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class Task: NSObject, Codable{

    var id: String?
    var name:String=""
    var duedate:String=""
    var tid: String = ""
    var reminder: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case duedate
        case tid
        case reminder
    }
}



//class Team: NSObject{
//
//var id: String?
//var name:String=""
//var heroes:[Task]=[]
//}
