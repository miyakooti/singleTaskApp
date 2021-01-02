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
//        self.navigationItem.title = ""
        
        //タブバーとナビゲーションバーの色を変更する。
        self.tabBar.barTintColor = UIColor(red: 0/255, green: 26/255, blue: 67/255, alpha: 1.0)
        self.tabBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 26/255, blue: 67/255, alpha: 1.0)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white] //navigationBarのタイトルの色を変更する。


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
