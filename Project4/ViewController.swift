//
//  ViewController.swift
//  Project4
//
//  Created by Nikola on 7/9/19.
//  Copyright © 2019 Nikola Krstevski. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com","stackoverflow.com","google.com"]
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil) //1)
        // 1) we are using KVO(Key-Value Observing) to watch estimated progress property of WKWebView. Once you have registered as KVO observer, YOU MUST IMPLEMENT a method called observeValue (look line 69)
        //----------------------------------------
        progressView = UIProgressView(progressViewStyle: .default) //1
        progressView.sizeToFit()                                   //2
        let progressButton = UIBarButtonItem(customView: progressView) //3
        // 1) This line creates a new UIProgressView instance giving it a default style. There is a alternative style called .bar which doesn't draw un unfilled line to show the extent of the progress view.
        // 2) Tell's the progress view to set its layout size so that it fits its contents fully.
        // 3) creates new UIBarButtonItem using the custom view parameter, which is where we wrap up our UIProgressView in a UIBarButtonItem so that it can go into our toolbar.
        //----------------------------------------
        backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        forwardButton = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(goForward))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        toolbarItems = [progressButton,spacer,backButton,spacer,forwardButton,spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        
        let url = URL(string: "https://" + websites[0])! //making a new data type called URL
        webView.load(URLRequest(url: url)) //this line does two things: 1) creates a new URLRequest object from that URL data type and 2) gives it to our webview to load!Now, this probably seems like pointless obfuscation from Apple, but WKWebViews don't load websites from strings like www.hackingwithswift.com, or even from a URL made out of those strings. You need to turn the string into a URL, then put the URL into an URLRequest, and WKWebView will load that.
        webView.allowsBackForwardNavigationGestures = true // The third line enables a property on the web view that allows users to swipe from the left or right edge to move backward or forward in their web browsing. This is a feature from the Safari browser that many users rely on, so it's nice to keep it around.
    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction!) {
        let url = URL(string: "https://" + action.title!)! //title is an optional string so we must unwrap it and because we are making URL from the string we must unwrap that too!!
        webView.load(URLRequest(url: url))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress) //estimatedProgress is a Double. UIProgressView's property is a Float. We must typecast it;  that is, we must create a new Float from Double
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url //1
        
        if let host = url?.host { //2
            for website in websites { //3
                if host.contains(website) { //4
                    decisionHandler(.allow) //5
                    return                  //6
                }
            }
        }
        decisionHandler(.cancel)      // 7
    }
    // To open only sites that we provide; prevent all others if they are not on our safe list of websites
    // 1) we set the constant to be equal to the url of the navigation
    // 2) we use if let to unwrap the optional url.host in other words it says "if theres a host for this URL pull it out" and by host it means "website domain" like apple.com. Note: we need to unwrap this carefully because not all websites have hosts.
    // 3) looping through sites in out safe list placing the name of the site in the website variable
    // 4) we use contains() String method to see whether each safe site exists somewhere in the host name
    // 5) if the website was found than we call decision handler with a positive response - we want to allow loading
    // 6) means exit the method now
    // 7)
    
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
}
