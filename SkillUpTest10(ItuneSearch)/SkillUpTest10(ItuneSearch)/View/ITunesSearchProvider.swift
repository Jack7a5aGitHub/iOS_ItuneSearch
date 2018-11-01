//
//  ITunesSearchProvider.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/18.
//  Copyright © 2018 Jack. All rights reserved.
//

import UIKit

final class ITunesSearchProvider: NSObject {
    
    private var items = [ItunesResults]()
    private var tasks = [URLSessionTask]()
    
    func set(items: [ItunesResults]) {
        self.items = items
    }
    
    /// song icon image download
    private func downloadProfileImage(forItemAtIndex index: Int, completion: (() -> Void)? = nil) {
        
        let urlString = items[index].artworkUrl100
        guard let iconImageUrl = URL(string: urlString!) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: iconImageUrl) { data, _, error in
            if let error = error {
                print("Failed to download image.\n\(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                let downloadedProfileImage = ITunesTempImage()
                downloadedProfileImage.resultID = String(describing: self.items[index].trackId)
                downloadedProfileImage.imageData = data
                ITunesTempImageDao.add(model: downloadedProfileImage)
                completion?()
            }
        }
        task.resume()
        tasks.append(task)
    }
    /// cancel dl in prefetching
    private func cancelDownloadingImage(forItemAtIndex index: Int) {
        let urlString = items[index].artworkUrl100
        guard let iconImageUrl = URL(string: urlString!) else {
            return
        }
        guard let taskIndex = tasks.index(where: { $0.originalRequest?.url == iconImageUrl } ) else {
            return
        }
        let task = tasks[taskIndex]
        task.cancel()
        tasks.remove(at: taskIndex)
    }
    
    
    /// Load Images
    private func loadImageFromDB(items: ItunesResults) -> UIImage? {
        if let resultIconImage = ITunesTempImageDao.findByID(resultID: String(describing: items.trackId)),
            let imageData = resultIconImage.imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
    
}

extension ITunesSearchProvider: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of Rows Count: \(items.count)")
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? ITunesSearchTableViewCell else {
            fatalError("Search Cell is nil")
        }
        
        cell.setImage(songIcon: nil)
        if let image = loadImageFromDB(items: items[indexPath.row]){
            cell.setImage(songIcon: image)
        }
        downloadProfileImage(forItemAtIndex: indexPath.row) {
            if let image = self.loadImageFromDB(items: self.items[indexPath.row]) {
                cell.setImage(songIcon: image)
            }
        }
        if !(items[indexPath.row].trackName?.isEmpty)! {
            cell.setText(text: (items[indexPath.row].trackName!))
        }
        return cell
    }
    
}

extension ITunesSearchProvider: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            downloadProfileImage(forItemAtIndex: $0.row)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            cancelDownloadingImage(forItemAtIndex: $0.row)
        }
    }
    
}
