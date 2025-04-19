//
//  TabBarVC.swift
//  Categories
//
//  Created by Apple on 01/04/25.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.unselectedItemTintColor = UIColor.darkGray
        self.tabBar.selectedImageTintColor = UIColor.systemGreen
    }
    


}
