//
//  TaskCellTableViewCell.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/08.
//

import UIKit
import Firebase
import AVFoundation

protocol TaskCellTableViewCellDelegate {
    func loadData()
}


class TaskCellTableViewCell: UITableViewCell {
    var delegate: TaskCellTableViewCellDelegate!
    
    var soundFile = PlaySound()

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var label: UILabel!
    var index:Int? // VCでここにIndexが入る
    var documentID:String?
    var isCompleted = false
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    
    override func awakeFromNib() { //viewDidLoadと同じ
        super.awakeFromNib()
        backView.layer.cornerRadius = 10
//        checkButton.backgroundColor = .red
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func tapCheck(_ sender: Any) {
        //ここでindexPathを利用したいです。
        print("今タップされたセルのindexPath.rowは、\(index ?? 404)です")
        let docRef = db.collection("Tasks").document(documentID!)
        
        //isCompletedを反転させる処理
        if isCompleted{
            docRef.updateData(["isCompleted": false])
            soundFile.playSound(fileName: "unCompleteSound", extensionName: "mp3")
        } else {
            docRef.updateData(["isCompleted": true])
            soundFile.playSound(fileName: "completeSound", extensionName: "mp3")
        }
        delegate?.loadData() //protocolを記述したことによって、他のクラスのメソッドが利用可能になる。（他のクラスで処理をする事ができる。）
        
    }
}
