//
//  SubmitViewController.swift
//  Project 33
//
//  Created by Paul on 19.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//
// TODO: check network avalability, cellurar usage

import UIKit

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
