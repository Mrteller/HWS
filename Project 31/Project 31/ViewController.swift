//
//  ViewController.swift
//  Project 31
//
//  Created by Paul on 05.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//
//  Known bugs: if server redirects we get nothing, if we don't type https:// we get nothing

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
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.firstIndex(of: webView) {
            // we found the current webview in the stack view
                stackView.removeArrangedSubview(webView)
                webView.removeFromSuperview()
                
                if stackView.arrangedSubviews.count == 0 {
                    // go back to our default UI
                    setDefaultTitle()
                } else {
                    var currentIndex = Int(index)
                    if currentIndex == stackView.arrangedSubviews.count { //What's the difference between count and endIndex
                        currentIndex -= 1
                    }
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    private func selectWebView(_ webView: WKWebView) {
        stackView.arrangedSubviews.forEach { view in
            view.layer.borderWidth = 0
        }
        activeWebView = webView
        webView.layer.borderWidth = 3
        updateUI(for: webView)
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
    
    // Paul's note: this can be also done in storyboard
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }
    
    private func updateUI(for webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.url?.absoluteString
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
    
}

