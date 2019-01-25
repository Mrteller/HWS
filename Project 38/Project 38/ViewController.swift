//
//  ViewController.swift
//  Project 38
//
//  Created by Paul on 24.01.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    var container: NSPersistentContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        container = NSPersistentContainer(name: "Project38") // load from model file Project38.xcdatamodeld
        container.loadPersistentStores { (storeDescription, error) in // load existing or create new database on disk otherwise
            if let error = error {
                print("Inresolved error \(error.localizedDescription)")
            }
        }
        let commit = Commit()
        commit.message = "woo"
        commit.url = "http://www.example.com"
        commit.date = Date()
    }
    
    private func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occured while saving: \(error.localizedDescription)")
            }
        }
    }


}

