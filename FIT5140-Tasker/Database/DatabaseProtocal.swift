//
//  DatabaseProtocal.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/3/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case tasks
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onTaskListChange(change: DatabaseChange, tasks: [Task])
}

protocol DatabaseProtocol: AnyObject {
//    var defaultTeam: Team {get}
    
    func cleanup()
    func addTask(name: String, duedate: String, reminder: Bool) -> Task
    func editTask(oldtask:Task, newtask:Task)-> Task
//    func addTeam(teamName: String) -> Team
//    func addHeroToTeam(hero: Task, team: Team) -> Bool
    func deleteTask(task: Task)
//    func deleteTeam(team: Team)
//    func removeHeroFromTeam(hero: Task, team: Team)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
