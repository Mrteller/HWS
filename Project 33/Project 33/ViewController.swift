//
//  ViewController.swift
//  Project 33
//
//  Created by Paul on 09.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UITableViewController {
    static var isDirty = true
    var whistles = [Whistle]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "What's that Whistle?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Paul's note: we better handle all selected row, not just one
        if let indexPaths = tableView.indexPathsForSelectedRows {
            indexPaths.forEach { indexPath in
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        if ViewController.isDirty {
            loadWhistles()
        }
        
    }
    
    func loadWhistles() {
        
    }

    @objc func addWhistle() {
        let vc = RecordWhistleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

