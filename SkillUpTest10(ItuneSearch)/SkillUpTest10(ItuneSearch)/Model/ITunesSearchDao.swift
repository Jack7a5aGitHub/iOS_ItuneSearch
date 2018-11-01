//
//  ITunesSearchDao.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/18.
//  Copyright © 2018 Jack. All rights reserved.
//

import UIKit
import Alamofire

//API Status
enum ITunesSearchAPIStatus {
    case loading
    case loaded([ItunesResults])
    case timeout
    case offline
    case error(message: String)
}

protocol ITunesSearchResult: class {
    func set(status: ITunesSearchAPIStatus)
}

final class ITunesSearchDao {
    weak var result: ITunesSearchResult?
    
    
    func test(){
        
        let path = "http://n3k8z.mocklab.io/search"
        let url = URL(string: path)
        let para = ["email" : "abcd@gmail.com"]
        print("test")
   
        Alamofire.request(url!).responseString { (response) in
            guard let json = response.data else { return }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            print(response)
            do {
                
                let testResult = try decoder.decode(DumDum.self, from: json)
                print(testResult.message)
                print("Finsihed searching")
            } catch let error as NSError {
                if error.code == NSURLErrorTimedOut {
                    print("Error: \(error.localizedDescription)")
                }
                
            }
        }
//        Alamofire.request(url!, method: .post, parameters: para).responseString { (response) in
//            guard let json = response.data else { return }
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            print(response)
//            do {
//
//                let testResult = try decoder.decode(TestDummy.self, from: json)
//                print(testResult.email)
//                print(testResult.message)
//                print(testResult.return_code)
//                print("Finsihed searching")
//            } catch let error as NSError {
//                if error.code == NSURLErrorTimedOut {
//                   print("Error: \(error.localizedDescription)")
//                }
//
//            }
//        }
}

    func search(term: String?) {
        
        if !NetworkConnection.isConnectable() {
            result?.set(status: .offline)
            return
        }
        
        result?.set(status: .loading)
        var searchResults: SearchResults?
        let itunesTerm = term?.replacingOccurrences(of: "", with: "+", options: .caseInsensitive, range: nil)
        let escapedTerm = itunesTerm?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let path = "https://itunes.apple.com/search?term=\(escapedTerm ?? "")&country=jp&media=music&lang=ja_jp"
        let url = URL(string: path)
    
        Alamofire.request(url!).responseJSON { (response) in
            guard let json = response.data else {return}
            
            do {
    
                searchResults = try JSONDecoder().decode(SearchResults.self, from: json)
                // self.cellItem = (searchResults?.results)!
                let result = (searchResults?.results)!
                self.result?.set(status: .loaded(result))
                //print("Result :\(searchResults?.results)")
                print("Finsihed searching")
            } catch let error as NSError {
                if error.code == NSURLErrorTimedOut {
                    self.result?.set(status: .timeout)
                }
                self.result?.set(status: .error(message: error.localizedDescription))
                
            }
        }
    }
    
}


