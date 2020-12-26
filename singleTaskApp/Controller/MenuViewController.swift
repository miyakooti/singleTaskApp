//
//  MenuViewController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/08.
//

//ログアウトしてから別のアカウントでろぐいんすると、画像が消えてしまう理由。ログアウトした後にmenuviewcontrollerにアクセスしても、さっきアクセスしたため、viewDidLoadが実行されず、loadDataによってimageStringに値が入ってこないので、sd_setImageをしても反映されないから。キャッシュ削除すると表示されます。

import UIKit
import Firebase
import FirebaseAuth
import SDWebImage

class MenuViewController: UIViewController {
    

    let currentUser = Auth.auth().currentUser
    
    let db = Firestore.firestore()

    @IBOutlet weak var mailText: UILabel!
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var imageString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "menu"
    
        mailText.text = String((currentUser?.email)!)
//        uidLabel.text = String((user?.uid)!)
        
        if UserDefaults.standard.object(forKey: "userImage") != nil{
            imageString = UserDefaults.standard.object(forKey: "userImage") as! String
        } else{
            //ここのテストは、複数のデバイスで確認してください。
            print("画像がuserDefaultsに保存されていません。ここからuserDefaultsへの登録を開始します。")
            loadImage()
            
        }
        //画像を反映させる
        iconImageView.sd_setImage(with: URL(string: imageString))
        iconImageView.layer.cornerRadius = 64.0

    }
    
    func loadImage(){
        db.collection("imagePath").addSnapshotListener { [self] (snapShot, error) in
            if error != nil{
                print(error.debugDescription)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                //snapshotはある一つのコレクション
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let imageStringData = data["imageString"] as? String, let uidData = data["uid"] as? String{
                        if currentUser?.uid == uidData{
                            //ローカルに保存
                            UserDefaults.standard.setValue(imageStringData, forKey: "userImage")
                            print("画像が新たに保存されました。これを変数imageStringに格納します。")
                            imageString = UserDefaults.standard.object(forKey: "userImage") as! String
                        }
                    }
                }
            }
        }
    }
    
    func logOut(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "userImage")
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        performSegue(withIdentifier: "logOut", sender: nil)
    }
    
    @IBAction func dispLogoutAlert(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: "ログアウトしますか？", message: "", preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ [self]
            (action: UIAlertAction!) -> Void in
            logOut(sender)
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)



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
