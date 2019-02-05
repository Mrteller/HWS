//
//  ViewController.swift
//  Project 31
//
//  Created by Paul on 05.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    private weak var activeWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultTitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
    }

    func setDefaultTitle() {
        title = "Multibrowser"
    }
    
    @objc private func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        stackView.addArrangedSubview(webView)
        let url = URL(string: "https://www.hackingwithswift.com")!
        _ = webView.load(URLRequest(url: url))
        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.name = "WebViewTapped"
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }
    
    @objc private func deleteWebView() {
        // safely unwrap our WebView
    
    }
    
    private func selectWebView(_ webView: WKWebView) {
        stackView.arrangedSubviews.forEach { view in
            view.layer.borderWidth = 0
        }
        activeWebView = webView
        webView.layer.borderWidth = 3
    }
    
    @objc private func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.name == "WebViewTapped" {
            return true
        } else {
            return false
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webView = activeWebView, let address = addressBar.text {
            if let url = URL(string: address) {
                webView.load(URLRequest(url: url))
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
}

