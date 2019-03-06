//
//  ViewController.swift
//  Project-31-Multibrowser
//
//  Created by verebes on 12/02/2019.
//  Copyright © 2019 A&D Progress. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    weak var activeWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultTitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
        
    }


    private func setDefaultTitle() {
        title = "Multibrowser"
    }
    
    private func updateUI(for webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.url?.absoluteString ?? ""
    }
    
    @objc private func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        stackView.addArrangedSubview(webView)
        
        let url = URL(string: "https://www.apple.com")!
        webView.load(URLRequest(url: url))
        
        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
    }
    
    @objc private func deleteWebView() {
        //safe unwrapping of our webView
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.index(of: webView) {
                // we found the current webView in the stackView and we remove it
                stackView.removeArrangedSubview(webView)
                // now remove it from the view hierarchy - this is important!
                webView.removeFromSuperview()
                
                if stackView.arrangedSubviews.count == 0 {
                    // set our default UI
                    setDefaultTitle()
                } else {
                    // convert the Index value to an integer
                    var currenIndex = Int(index)
                    
                    // if that was the last webView in the stack go back by one
                    if currenIndex == stackView.arrangedSubviews.count {
                        currenIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    // find the webView at the new index and select it
                    if let newSelectedWebView = stackView.arrangedSubviews[currenIndex] as? WKWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    private func selectWebView(_ webView: WKWebView) {
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        activeWebView = webView
        webView.layer.borderWidth = 3
        
        updateUI(for: webView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("EDIT MODE ON")
        if let webView = activeWebView, var address = addressBar.text {
            print("WE ARE TRYING TO GET AN URL")
            address = address.hasPrefix("http") ? address : "http://\(address)"
            if let url = URL(string: address) {
                print("WE ARE LOADING")
                webView.load(URLRequest(url: url))
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
    
}

