//
//  FirebaseController.swift
//  FIT5140-Tasker
//
//  Created by user173309 on 11/3/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
	class FirebaseController: NSObject, DatabaseProtocol {
    

    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var taskRef: CollectionReference?
    var taskList: [Task]
//    var defaultTeam: Team
    
    override init() {
        // To use Firebase in our application we first must run the
        // FirebaseApp configure method
        
        // We call auth and firestore to get access to these frameworks
        authController = Auth.auth()
        database = Firestore.firestore()
        taskList = [Task]()
//        defaultTeam = Team()
        
        super.init()
        
        // This will START THE PROCESS of signing in with an anonymous account
        // The closure will not execute until its recieved a message back which can be
        // any time later
        if Auth.auth().currentUser != nil{
            setUpTaskListener()
            
        }
    }
    
    // MARK:- Setup code for Firestore listeners
    func setUpTaskListener() {
        let userId = Auth.auth().currentUser!.uid
        taskRef = database.collection("users").document(userId).collection("tasks")
        taskRef?.whereField("tid", isEqualTo: userId).addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseHeroesSnapshot(snapshot: querySnapshot)
            

        }
    }
        
        

    
    // MARK:- Parse Functions for Firebase Firestore responses
    func parseHeroesSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            let taskID = change.document.documentID
            print(taskID)
            
            var parsedTask: Task?
            
            do {
                parsedTask = try change.document.data(as: Task.self)
            } catch {
                print("Unable to decode the task")
                return
            }
            
            guard let task = parsedTask else {
                print("Document doesn't exist")
                return;
            }
            
            task.id = taskID
            if change.type == .added {
                taskList.append(task)
            }
            else if change.type == .modified {
                let index = getTaskIndexByID(taskID)!
                taskList[index] = task
            }
            else if change.type == .removed {
                if let index = getTaskIndexByID(taskID) {
                    taskList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.tasks ||
                listener.listenerType == ListenerType.all {
                listener.onTaskListChange(change: .update, tasks: taskList)
            }
        }
    }

    
    // MARK:- Utility Functions
    func getTaskIndexByID(_ id: String) -> Int? {
        if let hero = getTaskById(id) {
            return taskList.firstIndex(of: hero)
        }
        
        return nil
    }
    
    func getTaskById(_ id: String) -> Task? {
        for task in taskList {
            if task.id == id {
                return task
            }
        }
        
        return nil
    }
    // MARK:- Required Database Functions
    func cleanup() {
        
    }
    
    func addTask(name: String, duedate: String, reminder: Bool) -> Task {
        let task = Task()
        task.name = name
        task.duedate = duedate
        task.reminder = reminder
        task.tid = Auth.auth().currentUser!.uid
        
        
        do {
            if let taskRef = try taskRef?.addDocument(from: task) {
                task.id = taskRef.documentID
            }
        } catch {
            print("Failed to serialize task")
        }
        
        return task
    }
    
    func editTask(oldtask: Task, newtask:Task)->Task {
            
            if let taskID = oldtask.id {
                taskRef?.document(taskID).delete()
            }
            
            let task = Task()
            task.name = newtask.name
            task.duedate = newtask.duedate
            task.reminder = newtask.reminder
            task.tid = Auth.auth().currentUser!.uid
            
            
            do {
                if let taskRef = try taskRef?.addDocument(from: task) {
                    task.id = taskRef.documentID
                }
            } catch {
                print("Failed to edit task")
            }
            
        return task
    }
    
    func deleteTask(task: Task) {
        if let taskID = task.id {
            taskRef?.document(taskID).delete()
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.tasks ||
            listener.listenerType == ListenerType.all {
            listener.onTaskListChange(change: .update, tasks: taskList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        
        listeners.removeDelegate(listener)
    }
}
