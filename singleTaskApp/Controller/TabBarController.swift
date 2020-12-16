//
//  TabBarController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/02.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.title = ""
    }

    

}
