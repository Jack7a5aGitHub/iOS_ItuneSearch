//
//  ITunesViewController+TableViewDelegate.swift
//  SkillUpTest10(ItuneSearch)
//
//  Created by Jack Wong on 2018/03/20.
//  Copyright © 2018 Jack. All rights reserved.
//

import UIKit

extension ITunesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
