//
//  SignUpViewController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/04.
//
//カメラアプリセクションｆ参照
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//


import UIKit
import Firebase
import FirebaseAuth


class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SendProfileOKDelegate, UITextFieldDelegate {
    
    func sendProfileOKDelegate(url: String) {
        //firebaseのデータがちゃんと保存されたなら。（url(sendToDBModelの変数)があるなら）
        let urlString = url
        if urlString.isEmpty != true{
            self.performSegue(withIdentifier: "goToHome", sender: nil)
        }
    }
    

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var personImageView: UIImageView!
    
    var SendToDBInstance = SendToDBModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let checkModel = CheckPermission()
        checkModel.showCheckPermission()
        SendToDBInstance.sendProfileOKDelegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    //タッチしたらキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    //新規登録---------------------------------------------------------------------------------------
    @IBAction func signUp(_ sender: Any) {
        //emailTextFieldとかがカラ出ないということを確認
        if emailTextField.text?.isEmpty != true && passwordTextField.text?.isEmpty != true, let image = personImageView.image{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                //データ型にする。
                let data = image.jpegData(compressionQuality: 1.0)
                self.SendToDBInstance.sendProfileImageData(data: data!)
            
//                ここから、データがちゃんと登録されたときだけ、画面遷移を行いたい。
                
                
    }
    }
    }
    
    @IBAction func tapImageView(_ sender: Any) {
        //画像選択させる
        //アラート出す
        showAlert()
    }
    
    //カメラ立ち上げメソッド
       
    func doCamera(){
        let sourceType:UIImagePickerController.SourceType = .camera
        //カメラ利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
        
    }
    
    //アルバム立ち上げメソッド
    func doAlbum(){
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        //カメラ利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
        
    }
    
//    カメラやアルバムで選択した時、呼ばれる。つまり画像が多分入る
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] as? UIImage != nil{
            let selectedImage = info[.originalImage] as! UIImage
            personImageView.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //アラート。アルバム？キャンセル？それとも、カメラ？
    func showAlert(){
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか?", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "カメラ", style: .default) { (alert) in
            self.doCamera()
        }
        let action2 = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            self.doAlbum()
        }
        let action3 = UIAlertAction(title: "キャンセル", style: .cancel)
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
        
    }
}
