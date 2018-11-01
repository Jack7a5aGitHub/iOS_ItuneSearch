//
//  IntroPageProvider.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/06.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import EAIntroView
import UIKit

final class IntroPageProvider {

    static func pages() -> [EAIntroPage] {
        var pages = [EAIntroPage]()

        let page1 = EAIntroPage()
        page1.bgImage = #imageLiteral(resourceName: "start_setumei1")
        pages.append(page1)

        let page2 = EAIntroPage()
        page2.bgImage = #imageLiteral(resourceName: "start_setumei2")
        pages.append(page2)

        let page3 = EAIntroPage()
        page3.bgImage = #imageLiteral(resourceName: "start_setumei3")
        pages.append(page3)

        let page4 = EAIntroPage()
        page4.bgImage = #imageLiteral(resourceName: "start_setumei4")
        pages.append(page4)

        return pages
    }
}
