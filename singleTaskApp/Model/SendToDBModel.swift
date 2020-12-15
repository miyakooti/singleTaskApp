//
//  SendToDBModel.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/05.
//画像をデータベースに送るモデル

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

protocol SendProfileOKDelegate {
    func sendProfileOKDelegate(url:String)
}

class SendToDBModel {
    
    let currentUser = Auth.auth().currentUser
    let db = Firestore.firestore()
    var sendProfileOKDelegate:SendProfileOKDelegate? //これはインスタンスを作成している 。左がインスタンスで右がプロトコル。
    
    init(){
    }
    
    func sendProfileImageData(data: Data){ //dataが局所変数で、Dataが型。
        
        //        dataをUIImageに変換する。
        let image = UIImage(data: data)
        //        jpegデータに変換する。
        let profileImageData = image?.jpegData(compressionQuality: 0.1)
        //        保存する場所を指定する。。
        let imageRef = Storage.storage().reference().child("profileImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        //        さっき保存する場所を指定したので、そこに向かってデータを飛ばすことができる。
        imageRef.putData(profileImageData!, metadata: nil) { (metaData, error) in //値が入ってきた時に動作する。
            if error != nil{
                print(error.debugDescription)
                return
            }
            imageRef.downloadURL { [self] (url, error) in //urlが入ってきた時　[self]はクロージャーの明示？
                
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                UserDefaults.standard.setValue(url?.absoluteString, forKey: "userImage")
                self.sendProfileOKDelegate?.sendProfileOKDelegate(url: url!.absoluteString)

                        
                        

            }
        }
        
    }
}
