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

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    

    let currentUserInstance = Auth.auth().currentUser
    let db = Firestore.firestore()
        
    var saveArray: Array! = [NSData]()
    var imageString = String()
    
    let menuCellLabels = ["背景画像を変更する","ログアウト"]

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "menu"
        tableView.delegate = self
        tableView.dataSource = self
        if UserDefaults.standard.object(forKey: "userImage") != nil{
            imageString = UserDefaults.standard.object(forKey: "userImage") as! String
        } else{
            //ここのテストは、複数のデバイスで確認してください。
            print("画像がuserDefaultsに保存されていません。ここからuserDefaultsへの登録を開始します。")
            loadImage()
        }
        showImage(imageString: imageString) //画像を反映させる
        greeting() //こんにちは。メールアドレスさん
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showImageFromUserDefaults()
        self.parent?.navigationItem.title = "Menu"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuCellLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")
        let label = cell?.viewWithTag(1) as! UILabel
        label.text = "　　"+menuCellLabels[indexPath.row]
        if menuCellLabels[indexPath.row] == "ログアウト" {
            label.textColor = .red
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            tapChangeBackImage(self)
        case 1:
            dispLogoutAlert(self)
        default:
            print("didSelectRowAtでエラーが発生")
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func greeting(){
        greetingLabel.text = "\(currentUserInstance?.email ?? "○○") さん"
    }
    
    
    func showImage(imageString: String){
        iconImageView.sd_setImage(with: URL(string: imageString))
        iconImageView.layer.cornerRadius = 95.0
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
                        if currentUserInstance?.uid == uidData{
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
        UserDefaults.standard.removeObject(forKey: "backImage") //ローカルのやつ消して
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
    
    
// image選択-------------------------------------------------------------
    
    //アラートコントローラの作成。
    func showAlert(){
        let alertController = UIAlertController(title: "背景画像の変更", message: "背景画像を変更する方法を選んでください。", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "写真を取る", style: .default) { (alert) in
            self.doCamera()
        }
        let action2 = UIAlertAction(title: "アルバムから選ぶ", style: .default) { (alert) in
            self.doAlbum()
        }
        let action3 = UIAlertAction(title: "デフォルト画像に戻す", style: .default) { (alert) in
            self.revertDefaultBackImage() //デフォルトのやつ反映させる。
        }
        let action4 = UIAlertAction(title: "キャンセル", style: .cancel)
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(action4)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //　1.カメラアクション。
    func doCamera(){
        let sourceType:UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    // 2.アルバムアクション
    func doAlbum(){
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    // 3.デフォルト画像に戻すアクション
    func revertDefaultBackImage(){
        UserDefaults.standard.removeObject(forKey: "backImage") //ローカルのやつ消して
        self.backImageView.image = UIImage(named: "back")
    }
    
    // 4.キャンセルアクション
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //　ここでカメラやアルバムの画像を取り込む。
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] as? UIImage != nil{
            let selectedImage = info[.originalImage] as! UIImage
            //この部分が新規登録画面と違うところ。ローカルにある背景画像を更新する。
            
            setBackImage(selectedImage: selectedImage) //画像をローカルに保存して、
            showImageFromUserDefaults() //それを反映させます！
            
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
//    userDefaultsに背景画像を保存する。
    func setBackImage(selectedImage: UIImage) {
            let data = selectedImage.pngData() //pngに変換
            if let backImageData = data {
                UserDefaults.standard.set(backImageData, forKey: "backImage")
            } else {
                print("setBackImageでエラーが発生。backImageDataに値が入っていません。")
            }
        }
    
    func showImageFromUserDefaults() {
            //UserDefaultsの中身が空でないことを確認
            if UserDefaults.standard.object(forKey: "backImage") != nil {
                let object = UserDefaults.standard.object(forKey: "backImage")
                backImageView.image = UIImage(data: object as! Data)
            } else {
                backImageView.image = UIImage(named: "back")
            }
        }
    //　背景画像を変更する　タップ
    @IBAction func tapChangeBackImage(_ sender: Any) {
        showAlert()
    }
    
    // /-image選択----------------------------------------------------

    
}
