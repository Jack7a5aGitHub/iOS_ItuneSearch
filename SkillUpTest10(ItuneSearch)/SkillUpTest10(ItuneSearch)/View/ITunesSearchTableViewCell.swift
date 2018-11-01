//
//  ITunesSearchTableViewCell.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/18.
//  Copyright © 2018 Jack. All rights reserved.
//

import UIKit

class ITunesSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        trackImageView.image = nil
        trackNameLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    // MARK: - Setter
    
    func setImage(songIcon: UIImage?) {
        trackImageView.image = songIcon
    }
    
    func setText(text: String) {
        trackNameLabel.text = text
    }
    
}
