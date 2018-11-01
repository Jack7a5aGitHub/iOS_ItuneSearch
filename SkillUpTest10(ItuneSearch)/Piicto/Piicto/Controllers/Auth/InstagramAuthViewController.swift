//
//  InstagramAuthViewController.swift
//  Piicto
//
//  Created by kawaharadai on 2018/01/26.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit
import WebKit

class InstagramAuthViewController: UIViewController {

    private let instagramAPI = InstagramAPI()
    
    // TODO: インスタグラム、サービスレビュー完了後、本番用IDに書き換える
    private let clientId = "b3ff73cb386f43ae8124abc2424063d9"
    private let redirectUri = "http://www.st-ventures.jp/"
    private let targetURLHost = "www.st-ventures.jp"
    
    private var webView: WKWebView?
    
    // MARK: - Factory
    
    class func make() -> InstagramAuthViewController {
        let vcName = InstagramAuthViewController.className
        guard let instaAuthVC = UIStoryboard.viewController(
            storyboardName: vcName, identifier: vcName) as? InstagramAuthViewController else {
                fatalError("InstagramAuthViewController is nil.")
        }
        return instaAuthVC
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Private
    
    private func setup() {
        setupWKWebView()
        instagramAPI.instagramAPIDelegate = self
        
        load(urlString: "https://instagram.com/oauth/authorize/?client_id=\(clientId)&redirect_uri=\(redirectUri)&response_type=token")
    }
    
    private func setupWKWebView() {
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        webView?.allowsBackForwardNavigationGestures = true
        webView?.scrollView.bounces = false
        
        view.addSubview(webView ?? WKWebView())
        
        webView?.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|",
                                                           options: NSLayoutFormatOptions(),
                                                           metrics: nil,
                                                           views: ["v0": webView ?? WKWebView()]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[v0]|",
                                                           options: NSLayoutFormatOptions(),
                                                           metrics: nil,
                                                           views: ["v0": webView ?? WKWebView()]))
    }
    
    private func load(urlString: String) {
        
        guard let url = URL(string: urlString) else {
            return
        }
        let myRequest = URLRequest(url: url)
        webView?.load(myRequest)
    }
    
    private func setBackButton() {
        
        let screenWidth: CGFloat = self.view.frame.width
        let screenHeight: CGFloat = self.view.frame.height
        
        let backButton = UIButton()
        
        backButton.frame = CGRect(x: screenWidth * 0.07, y: screenHeight * 0.4,
                                  width: screenWidth * 0.15, height: 50)
        
        backButton.setBackgroundImage(#imageLiteral(resourceName: "setting_return_bt"), for: .normal)
        
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        
        backButton.addTarget(self,
                             action: #selector(InstagramAuthViewController.buttonTapped(sender:)),
                             for: .touchUpInside)
        
        self.webView?.addSubview(backButton)
    }
    
    @objc func buttonTapped(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - WKUIDelegate

extension InstagramAuthViewController: WKUIDelegate {
    
    /// 新しいウィンドウ、フレームを指定してコンテンツを開く時
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        return nil
    }
    
    /// JSのalert実行時
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Swift.Void) {
    }
    
    /// JSのconfirm実行時
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Swift.Void) {
        
    }
    
    /// JSのprompt実行時
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Swift.Void) {
        
    }
    
    func webView(_ webView: WKWebView,
                 shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        
        return true
    }
    
    func webView(_ webView: WKWebView,
                 previewingViewControllerForElement elementInfo: WKPreviewElementInfo,
                 defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        
        return self
    }
    
    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        
    }
}

// MARK: - WKNavigationDelegate (ロード処理)
extension InstagramAuthViewController: WKNavigationDelegate {
    
    /// ページ遷移前
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 読み込む
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation) {
        
        if webView.url?.host == targetURLHost {
            // "="で分割
            guard let separateString = webView.url?.absoluteString.components(separatedBy: "=") else {
                print("Instagramのアクセストークンの取得に失敗")
                return
            }
            
            UserDefaults.standard.set(separateString[1], forKey: "instagramAccessToken")
            // 取得したアクセストークンを使い、ユーザー情報を取得する
            instagramAPI.userDataRequest(accssToken: separateString[1], endPoint: "/users/self")
        }
    }
    
    /// 読み込み完了時
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        print("読み込み完了")
        setBackButton()
    }
}

extension InstagramAuthViewController: InstagramAPIAuthDelegate {
    func finishedAuth() {
        dismiss(animated: true, completion: nil)
    }
}
