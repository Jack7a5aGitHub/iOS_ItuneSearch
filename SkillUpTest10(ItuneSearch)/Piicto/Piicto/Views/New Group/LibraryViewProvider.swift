//
//  LibraryViewProvider.swift
//  Piicto
//
//  Created by kawaharadai on 2018/01/29.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import Kingfisher
import UIKit

class LibraryViewProvider: NSObject {
    
    var photoData = [URL]()
}

extension LibraryViewProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return photoData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LibraryViewCell.identifier,
            for: indexPath) as? LibraryViewCell else {
                fatalError("LibraryViewCell is nil.")
        }
        
        cell.photoView.kf.setImage(with: photoData[indexPath.row])
        
        return cell
    }
}
