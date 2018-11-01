//
//  LibraryViewCell.swift
//  Piicto
//
//  Created by kawaharadai on 2018/01/29.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

final class LibraryViewCell: UICollectionViewCell {
    
    static var identifier: String {
        return self.className
    }
    
    @IBOutlet weak var photoView: UIImageView!
    
}
