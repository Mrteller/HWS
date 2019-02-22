//
//  SubmitViewController.swift
//  Project 33
//
//  Created by Paul on 19.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//
// TODO: check network avalability, cellurar usage

import UIKit
import CloudKit

class SubmitViewController: UIViewController {
    
    var genre: String! // TODO: think about transforming it to enum
    var comments: String!
    
    var stackView: UIStackView! // make lazy
    var status: UILabel! // init with clousure
    let spinner = UIActivityIndicatorView(style: .whiteLarge) // This is better: let instead of var, no optionality.
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.gray
        // Paul's note: a bit different init sequence to demonstrate UIStackView(arrangedSubviews : [UIView]). And save a couple of lines of code.
        
        status = UILabel()
        status.translatesAutoresizingMaskIntoConstraints = false
        status.text = "Submitting..."
        status.textColor = UIColor.white
        status.font = UIFont.preferredFont(forTextStyle: .title1)
        status.numberOfLines = 0
        status.textAlignment = .center
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        stackView = UIStackView(arrangedSubviews: [status, spinner])
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "You're all set!"
        navigationItem.setHidesBackButton(true, animated: true) //Same as hidesBackButton but animated
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doSubmission() // TODO: add and process return value: success: Bool
    }

    @discardableResult private func doSubmission() -> Bool {
        //        CKContainer.default().accountStatus { accountStatus, error in
        //            DispatchQueue.main.sync {
        //                print(accountStatus, error?.localizedDescription ?? "No errors")
        //            }
        //        }
        
        let whistleRecord = CKRecord(recordType: "Whistles")
        whistleRecord["genre"] = genre // as CKRecordValue
        whistleRecord["comments"] = comments // as CKRecordValue
        
        let audioURL = RecordWhistleViewController.getWhistleURL()
        let whistleAsset = CKAsset(fileURL: audioURL)
        whistleRecord["audio"] = whistleAsset
        CKContainer.default().publicCloudDatabase.save(whistleRecord) {[unowned self] record, error in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                if let error = error {
                    self.status.text = "Error: \(error.localizedDescription)"
                    if let skError = error as? CKError {
                        switch (skError.code) {
                        case .networkUnavailable:
                            print("Please check network \(skError.localizedDescription)")
                        case .networkFailure:
                            print("Network error occured. Retry in \(skError.retryAfterSeconds ?? 5) seconds")
                        case .requestRateLimited:
                            print("Too many requests. Retry in \(skError.retryAfterSeconds ?? 5) seconds")
                        case .notAuthenticated:
                            print("Please, log in to your account")
                        default:
                            break
                        }
                    }
                } else {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    self.status.text = "Done"
                    ViewController.isDirty = true
                }
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
                print(#function, error?.localizedDescription ?? "No errors")
            }
        }
        return true // success
    }
    
    @objc private func doneTapped() {
        _ = navigationController?.popToRootViewController(animated: true) // nice NVC method
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
