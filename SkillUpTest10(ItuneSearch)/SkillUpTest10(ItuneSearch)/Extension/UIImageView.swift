//
//  UIImageView.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/20.
//  Copyright © 2018 Jack. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImageByKingfisher(with url: URL) {
        
        self.kf.setImage(with: url) { [weak self] image, error, _, _ in
            // Success
            if error == nil, let image = image {
                self?.image = image
                
                // Failure
            } else {
                // error handling
                print("Error: \(String(describing: error))")
            }
        }
        
    }
}
