//
//  LetsStartViewController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/09.
//

import UIKit
import Firebase
import FirebaseAuth

class LetsStartViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        
        //この時点でuserdefaultsに保存されているはず
        let imageString = UserDefaults.standard.object(forKey: "userImage") as! String
        
        self.db.collection("imagePath").addDocument(data: ["imageString": imageString , "uid":self.currentUser?.uid ?? "設定されていません"]) { (error) in
            
            if error != nil{
                print(error.debugDescription)
                return
    }
    
}
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
