//
//  ViewController.swift
//  Project 38
//
//  Created by Paul on 24.01.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    // Paul's note: add refresh controll! (Done)

    var container: NSPersistentContainer!
    // Paul's note: in real app we should leave a container var in appDelegate and make a shared one

    // var commits = [Commit]()
    var commitPredicate: NSPredicate?
    var fetchedResultsController: NSFetchedResultsController<Commit>!

    @IBAction func refresh(_ sender: UIRefreshControl) {
        performSelector(inBackground: #selector(fetchCommits), with: nil) //Paul's note: better pass newestCommitDate as argument
    }
    
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
        loadSavedData() //Paul's note: duplicate - done in fetchCommits()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
    }
    
    @objc func fetchCommits() { // Paul's note: make real error handling someday
        let newestCommitDate = getNewestCommitDate() // is run in background, but uses viewContext (which is a main ViewContext)
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!) {
            // give the data to SwiftlyJSON to parse
            let jsonCommits = JSON(parseJSON: data)
            // read the commits back out
            let jsonCommitArray = jsonCommits.arrayValue
            print("Received \(jsonCommitArray.count) new commits.")
            
            //Paul's note: Do we really need to dispatch back or we can just thread-protect block?
            // container.viewContext.perform { }
            // the other thing we could do instead of DispatchQueue.main.async is:
//            container.performBackgroundTask { [unowned self] backgroundContext in
//                for jsonCommit in jsonCommitArray {
//                    let commit = Commit(context: backgroundContext)
//                    self.configure(commit: commit, usingJSON: jsonCommit)
//                }
//                try? backgroundContext.save()
//                self.loadSavedData()
//                self.refreshControl?.endRefreshing()
//            }
            DispatchQueue.main.async { [unowned self] in
                
                for jsonCommit in jsonCommitArray {
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit, usingJSON: jsonCommit)
                }
                self.saveContext() // Paul's note: that's right: viewContext is main thread context and should be saved (and operated) on main thread only. Even Asycncroniously.
                self.loadSavedData()
                self.refreshControl?.endRefreshing()
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()
        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1
        // newest.propertiesToFetch = ["date"] find out what this is for and check if we can avoid fetching thing we don't need
        // print("Date.distantPast \(Date.distantPast) vs Date(timeIntervalSince1970:) \(Date(timeIntervalSince1970: 0))")

        // if let commits = try? container.viewContext.fetch(newest) {
        #if DEBUG
        print("Fetching or executing request on \(Thread.isMainThread ? "Main" : "Background") thread :\r\(#file) (\(#line)) \(#function)")
        #endif
        // FIXME: getNewestCommitDate gets called from fetchCommits which in its turn is run in background. We are not allowed to use viewContext off the main queue ("view" is for UI what is for main tread).
        // There are several ways to fix this:
        // 1 We could wrap everything inside 'perform' (we can't return from block, so we can use a local var to store theresult and return it when done).
        // container.viewContext.perform {
        // 2 Pass the apropriate context as argumet
        // 3 Rewrite the logic and make use of 'container.performBackgroundTask' instead of 'performSelector(inBackground:)'(best option IMHO)
        // This will also help to move DM filling off the Main queue!
        // 4 Manually dispach back to the Main
        // 5 Use 'execute' (the smallest change)
        if let commits = try? newest.execute() { // Paul's note: fetching with execute will choose a proper NSManagedContext for whatever queue we are in.
                if commits.count > 0 {
                    print(formatter.string(from: commits[0].date.addingTimeInterval(1)))
                    return formatter.string(from: commits[0].date.addingTimeInterval(1))
                }
            }
//        }
        return formatter.string(from: Date(timeIntervalSince1970: 0))
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
        //authorRequest.predicate = NSPredicate(format: "name == %@ and email == %@", json["commit"]["committer"]["name"].stringValue, json["commit"]["committer"]["email"].stringValue)
        authorRequest.predicate = NSPredicate(format: "name == %@",json["commit"]["committer"]["name"].stringValue)
        //if let authors = try? container.viewContext.fetch(authorRequest) {
        // Paul's note - this is safer. Entities are linked and are considered to be one context (view, background, other)
        if let authors = try? commit.managedObjectContext!.fetch(authorRequest) {
        // if let authors = try? authorRequest.execute() // Paul's note - this good too. execute() will use a proper context (according to the current que)
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
        //3.1
        ac.addAction(UIAlertAction(title: "Show only resent", style: .default) { [unowned self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self.loadSavedData()
        })
        // 3.2
        ac.addAction(UIAlertAction(title: "Show only Durian commits", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
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
        if fetchedResultsController == nil {
            let request = Commit.createFetchRequest()
            let authorName = NSSortDescriptor(key: "author.name", ascending: true)
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [authorName, sort]
            request.fetchBatchSize =  20 // Now it is clear what this thing does
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)
            fetchedResultsController.delegate = self
        }

        fetchedResultsController.fetchRequest.predicate = commitPredicate
        do {
            //commits = try container.viewContext.fetch(request)
            //print("Got \(commits.count) commits")
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch  {
            print("Fetch failed")
        }
    }
    
    // MARK: Table datasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return commits.count
        if let sectionInfo = fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        } else { return 0 }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        // let commit = commits[indexPath.row]
        let commit = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = commit.message
        cell.detailTextLabel?.text = "By \(commit.author.name) on \(commit.date.description)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            //vc.detailItem = commits[indexPath.row] //Pauls note: better make it independent of Commits class
            vc.detailItem = fetchedResultsController.object(at: indexPath)
            navigationController?.pushViewController(vc, animated: !UIAccessibility.isReduceMotionEnabled)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // let commit = commits[indexPath.row]
            let commit = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(commit)
            // commits.remove(at: indexPath.row)
            // tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveContext() //Pauls note: better try to save and delete only on success
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("Section header: \(fetchedResultsController.sections![section].name)")
        return fetchedResultsController.sections?[section].name
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }

}

