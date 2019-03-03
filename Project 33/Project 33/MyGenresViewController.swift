//
//  MyGenresViewController.swift
//  Project 33
//
//  Created by Paul on 27.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import UIKit
import CloudKit

class MyGenresViewController: UITableViewController {
    var myGenres = [SelectGenreViewController.Genres]() // changed to enum

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if let savedGenres = defaults.stringArray(forKey: myGenresSettingKey) {// Paul's note more convenient than object(for: key)
            myGenres = savedGenres.compactMap {SelectGenreViewController.Genres(rawValue: $0)}
        } else {
            myGenres.removeAll(keepingCapacity: false)
        }
        title = "Notyfy me about..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc private func saveTapped() {
        let defaults = UserDefaults.standard
        defaults.setValue(myGenres.compactMap {$0.rawValue}, forKey: myGenresSettingKey)
        let database = CKContainer.default().publicCloudDatabase
        database.fetchAllSubscriptions { [unowned self] subscriptions, error in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        database.delete(withSubscriptionID: subscription.subscriptionID) { (str, error) in
                            if error != nil {
                                // TODO: find out about str, do error handling
                                print(error!.localizedDescription)
                            } else {
                                print("Deleting subscription with ID \(subscription.subscriptionID)")
                            }
                        }
                    }
                    for genre in self.myGenres {
                        let predicate = NSPredicate(format: "\(Whistles.genre) = %@", genre.rawValue)
                        let subscription = CKQuerySubscription(recordType: Whistles.Record.type, predicate: predicate, options: CKQuerySubscription.Options.firesOnRecordCreation)
                        let notification = CKSubscription.NotificationInfo()
                        notification.alertBody = "There is a new whistle in the \(genre.localizedName()) genre."
                        notification.soundName = "default"
                        notification.category = genre.rawValue // TODO: change to function
                        notification.collapseIDKey = Whistles.genre // Analog of content.threadIdentifier = "Some thread" for UNMutableNotificationContent()?
                        notification.shouldBadge = true
                        notification.shouldSendContentAvailable = true

                        
                        subscription.notificationInfo = notification
                        database.save(subscription) { resultSubscription, error in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                print("Creating subscription with ID \(subscription.subscriptionID)")
                            }
                        }
                    }
                }
            } else {
               // do error handling
                print(error!.localizedDescription)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return SelectGenreViewController.genres.count // original version
        return SelectGenreViewController.Genres.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let genre = SelectGenreViewController.Genres(index: indexPath.row){
            cell.textLabel?.text = genre.localizedName()
            
            if myGenres.contains(genre) {//TODO: change to [enum]
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath), let selectedGenre = SelectGenreViewController.Genres(index: indexPath.row) {
            // cell.accessoryType = cell.accessoryType.none ? .checkmark : .none // not now
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                myGenres.append(selectedGenre)
            } else {
                cell.accessoryType = .none
                // print(myGenres)
                // print(selectedGenre.hashValue)
                // myGenres.remove(at: selectedGenre.hashValue)
                myGenres.remove(at: myGenres.firstIndex(of: selectedGenre)!)

            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
