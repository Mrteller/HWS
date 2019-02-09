//
//  RecordWhistleViewController.swift
//  Project 33
//
//  Created by Paul on 09.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import UIKit
import AVFoundation

class RecordWhistleViewController: UIViewController {
    var stackView: UIStackView!
    var recordButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var whistleRecorder: AVAudioRecorder!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.gray
        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false // Autolayout dynamically calculates size
        stackView.distribution = .fillEqually //Paul's note: shorter record forUIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "What's that Whistle?"

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Record", style: .plain, target: nil, action: nil)
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed { self.loadRecordingUI() } else { self.loadFailUI() }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }
    
    private func loadRecordingUI() {
        
    }
    
    private func loadFailUI() {
        
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
