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
    // Paul's note: add refresh controll!
    
    var container: NSPersistentContainer!
    var commits = [Commit]()
    var commitPredicate: NSPredicate?

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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
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
        
        var commitAuthor: Author!
        // see if this author exists already
        let authorRequest = Author.createFetchRequest()
        // Paul's note: Danger! - we might have authors with the same name. TODO: check if it is unique. if not we are about to mix them here.
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        //if let authors = try? container.viewContext.fetch(authorRequest) {
        // Paul's note - this is safer. Entities are linked and are considered to be one context (view, background, other)
        if let authors = try? commit.managedObjectContext!.fetch(authorRequest) {
            if authors.count > 0 {
                // we have this author already
                assert(authors.count == 1, "DB inconsitency: too many authors with the same name")
                commitAuthor = authors[0]
            }
        }
        if commitAuthor == nil {
            // we didn't find a saved author - create a new one
            let author = Author(context: commit.managedObjectContext!) // Paul's note: again - it is better to use the same context tha related entity uses
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        
        // use the author, either saved or new
        commit.author = commitAuthor
    }
    
    @objc private func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occured while saving: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func changeFilter() {
        // Paul's note: change to segmented control with search item
        let ac = UIAlertController(title: "Filter commits...", message: nil, preferredStyle: .actionSheet)
        //1
        ac.addAction(UIAlertAction(title: "Show only fixes", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        })
        //2
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        })
        //3
        ac.addAction(UIAlertAction(title: "Show only resent", style: .default) { [unowned self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self.loadSavedData()
        })
        //4
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { [unowned self] _ in
            self.commitPredicate = nil
            self.loadSavedData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: !UIAccessibility.isReduceMotionEnabled)
        
    }
    
    private func loadSavedData() {
        let request = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.predicate = commitPredicate
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
        cell.detailTextLabel?.text = "By \(commit.author.name) on \(commit.date.description)"
        return cell
    }


}

