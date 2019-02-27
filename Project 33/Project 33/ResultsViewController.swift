//
//  ResultsViewController.swift
//  Project 33
//
//  Created by Paul on 25.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit

class ResultsViewController: UITableViewController {
    var whistle: Whistle!
    var suggestions = [String]()
    
    var whistlePlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Genre: (whistle.genre!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(downloadTapped))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let reference = CKRecord.Reference(recordID: whistle.recordID, action: .deleteSelf) // Paul's note: why not make an instance calculated var instead?
        let pred = NSPredicate(format: "\(Suggestions.owningWhistle) == %@", reference)
        let sort = NSSortDescriptor(key: Suggestions.creationDate, ascending: true)
        let query = CKQuery(recordType: Suggestions.Record.type, predicate: pred)
        query.sortDescriptors = [sort]
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] (results, error) in //Paul's note: weak self ! not unowned
            if let error = error {
                print("perform(query) ", #function, error.localizedDescription)
            } else {
                if let results = results {
                    self.parseResults(records: results)
                }
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @objc private func downloadTapped() {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.tintColor = UIColor.black
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: whistle.recordID) { [weak self] record, error in
            if let error = error {
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    self?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(self?.downloadTapped))
                }
            } else {
                if let record = record {
                    if let assert = record["audio"] as? CKAsset {
                        self?.whistle.audio = assert.fileURL
                        DispatchQueue.main.async {
                            self?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen", style: .plain, target: self, action: #selector(self?.listenTapped))
                        }
                    }
                }
            }
        }
    }
    
    private func parseResults(records: [CKRecord]) {
        // var newSuggestions = String()
        // records.forEach{ newSuggestions.append($0[Suggestions.text] as! String) } //catch errors
        let newSuggestions = records.compactMap { $0[Suggestions.text] as? String }
        DispatchQueue.main.async { [unowned self] in //Paul's note: check if we need it
            self.suggestions = newSuggestions
            self.tableView.reloadData()
        }
    }
    
    @objc private func listenTapped() {
        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: whistle.audio)
            whistlePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem: \(error.localizedDescription)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Suggested songs"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return suggestions.count + 1
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.section == 0 {
            // the user's comments about this whistle
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
            
            if whistle.comments.count == 0 {
                cell.textLabel?.text = "Comments: None"
            } else {
                cell.textLabel?.text = whistle.comments
            }
        } else {
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            if indexPath.row == suggestions.count {
                // this is our extra row
                cell.textLabel?.text = "Add suggestion"
                cell.selectionStyle = .gray
            } else {
                cell.textLabel?.text = suggestions[indexPath.row]
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 && indexPath.row == suggestions.count else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let ac = UIAlertController(title: "suggest a song...", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { [unowned self] action in
            if let textField = ac.textFields?.first, (textField.text?.count ?? 1) > 0 {
            self.add(suggestion: textField.text!)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func add(suggestion: String) {
        let whistleRecord = CKRecord(recordType: Suggestions.Record.type)
        let reference = CKRecord.Reference(recordID: whistle.recordID, action: .deleteSelf)
        whistleRecord[Suggestions.text] = suggestion // as CKRecordValue
        whistleRecord[Suggestions.owningWhistle] = reference // as CKRecordValue
        
        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] record, error in
            DispatchQueue.main.async {
                if error == nil {
                    self.suggestions.append(suggestion)
                    self.tableView.reloadData() // or insert row
                } else {
                    let ac = UIAlertController(title: "Error", message: "There was a problem submitting your suggestion: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
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
