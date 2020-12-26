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
//        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.title = ""
    }
    
//    override func performSegue(withIdentifier identifier: String, sender: Any?) {
//        if sender.ide
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menu"{
            self.navigationItem.title = "menu"
        }
    }

    

}
