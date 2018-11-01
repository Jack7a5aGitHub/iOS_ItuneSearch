//
//  InfomationPageViewController.swift
//  Piicto
//
//  Created by kawaharadai on 2018/01/28.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit
import WebKit

class InfomationPageViewController: UIViewController {

    private var webView: WKWebView?

    private let corporateURL = "https://www.yudo.jp"
    private var accessURL = ""
    
    // MARK: - Factory
    class func make(accessURL: String) -> InfomationPageViewController {
        let vcName = InfomationPageViewController.className
        guard let infomationVC = UIStoryboard.viewController(
            storyboardName: vcName, identifier: vcName) as? InfomationPageViewController else {
                fatalError("InfomationPageViewController is nil.")
        }
        
        infomationVC.accessURL = accessURL
        return infomationVC
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Private
    
    private func setup() {
        if accessURL.isEmpty {
            accessURL = corporateURL
        }
        
        setupNavigationItem()
        setupWKWebView()
        setUrl(url: accessURL)
    }
    
    private func setupWKWebView() {
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        webView?.allowsBackForwardNavigationGestures = true
        
        view.addSubview(webView ?? WKWebView())
        
        webView?.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|",
                                                           options: NSLayoutFormatOptions(),
                                                           metrics: nil,
                                                           views: ["v0": webView ?? WKWebView()]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|",
                                                           options: NSLayoutFormatOptions(),
                                                           metrics: nil,
                                                           views: ["v0": webView ?? WKWebView()]))
    }
    
    private func setUrl(url: String) {
        load(urlString: url)
    }
    
    private func load(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("not exist url")
            return
        }
        
        let myRequest = URLRequest(url: url)
        webView?.load(myRequest)
    }
    
    private func createBackButton() {
        
        let screenWidth: CGFloat = self.view.frame.width
        let screenHeight: CGFloat = self.view.frame.height
        
        let backButton = UIButton()
        
        backButton.frame = CGRect(x: screenWidth * 0.06, y: screenHeight * 0.02,
                                  width: 40, height: 30)
        
        backButton.setBackgroundImage(#imageLiteral(resourceName: "setting_return_bt"), for: .normal)
        backButton.setBackgroundImage(#imageLiteral(resourceName: "setting_return_bt"), for: .highlighted)
        
        backButton.addTarget(self,
                             action: #selector(InfomationPageViewController.buttonTapped(sender:)),
                             for: .touchUpInside)
        
        self.webView?.addSubview(backButton)
    }
    
    @objc func buttonTapped(sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - WKUIDelegate Medhods
extension InfomationPageViewController: WKUIDelegate {
    /// 新しいウィンドウ、フレームを指定してコンテンツを開く時
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        return nil
    }
}

// MARK: - WKNavigationDelegate Medhods
extension InfomationPageViewController: WKNavigationDelegate {
    /// ページ遷移前
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 読み込む
        decisionHandler(.allow)
    }
    
    /// 読み込み開始時
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        
    }
    
    /// 読み込み完了時
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        createBackButton()
    }
    
    /// 読み込み失敗
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
    }
}
