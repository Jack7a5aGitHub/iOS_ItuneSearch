//
//  ITunesViewController.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/18.
//  Copyright © 2018 Jack. All rights reserved.
//

import UIKit
import SVProgressHUD

class ITunesViewController: UIViewController {
    
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private let refreshControl = UIRefreshControl()
    private let itunesSearchDao =  ITunesSearchDao()
    private let  resultProvider = ITunesSearchProvider()
   
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(isHidden: true)
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ITunesViewController {
    private func setupView(isHidden: Bool) {
        noResultView.isHidden = isHidden
        resultTableView.isHidden = isHidden
    }
    private func setup(){
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = resultProvider
        resultTableView.allowsSelection = false
        itunesSearchDao.result = self
        registerGestureRecognizer()
        
    }
   
    private func showAlert(message: String) {
        let alert = AlertHelper.buildAlert(message: message)
        present(alert, animated: true, completion: nil)
    }
    private func endRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    private func searchBegin(){
        guard searchBar.text != nil else { return }
        itunesSearchDao.search(term: searchBar.text!)
        
    }
    private func registerGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        self.view.addGestureRecognizer(tap)
    }
    @objc private func endEditing() {
        self.view.endEditing(true)
    }
}

extension ITunesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        if (searchBar.text == "") && (searchBar.text?.isEmpty)! {
            showAlert(message: "EMPTY_TEXT".localized())
        } else {
            self.navigationItem.title = searchBar.text
            print("Search Started")
            noResultView.isHidden = true
            resultTableView.isHidden = false
            searchBegin()
            
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

extension ITunesViewController: ITunesSearchResult {
    func set(status: ITunesSearchAPIStatus) {
        switch status {
        case .loading:
            if !refreshControl.isRefreshing {
                SVProgressHUD.show()
            }
            break
        case .loaded(let response):
            SVProgressHUD.dismiss()
            endRefreshing()
            
            response.forEach{
                print($0.trackName ?? "")
            }
            if response.count != 0 {
                resultProvider.set(items: response)
                resultTableView.reloadData()
            } else {
                resultTableView.isHidden = true
                noResultView.isHidden = false
            }
            break
        case .timeout:
            SVProgressHUD.dismiss()
            endRefreshing()
            showAlert(message: "TIMEOUT".localized())
            break
        case .offline:
            SVProgressHUD.dismiss()
            endRefreshing()
            showAlert(message: "OFFLINE".localized())
            break
        case .error(message: let message):
            SVProgressHUD.dismiss()
            endRefreshing()
            showAlert(message: message)
            break
        }
    }
}
