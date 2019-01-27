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
    var commits = [Commit]()

    override func viewDidLoad() {
        super.viewDidLoad()
        container = NSPersistentContainer(name: "Project38") // load from model file Project38.xcdatamodeld
        container.loadPersistentStores { [weak self] (storeDescription, error) in // load existing or create new database on disk otherwise
            self?.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Inresolved error \(error.localizedDescription)")
            }
        }
//        let commit = Commit()
//        commit.message = "woo"
//        commit.url = "http://www.example.com"
//        commit.date = Date()
        performSelector(inBackground: #selector(fetchCommits), with: nil) //Paul's note: compare with other background fetching techniques
        loadSavedData()
    }
    
    @objc func fetchCommits() { //Paul's note: make real error handling someday
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100")!) {
            // give the data to SwiftlyJSON to parse
            let jsonCommits = JSON(parseJSON: data)
            // read the commits back out
            let jsonCommitArray = jsonCommits.arrayValue
            print("Received \(jsonCommitArray.count) new commits.")
            
            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit, usingJSON: jsonCommit)
                }
                self.saveContext() // Paul's note: that's right: viewContext is main thread context and should be saved (and operated) on main thread only. Even Asycncroniously.
                self.loadSavedData()
            }
        }
    }
    
    private func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
        print(commit.date, json["commit"]["committer"]["date"].stringValue)
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
    
    private func loadSavedData() {
        let request = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            commits = try container.viewContext.fetch(request)
            print("Got \(commits.count) commits")
            tableView.reloadData()
        } catch  {
            print("Fetch failed")
        }
    }
    
    // MARK: Table datasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        let commit = commits[indexPath.row]
        cell.textLabel?.text = commit.message
        cell.detailTextLabel?.text = commit.date.description
        return cell
    }


}

