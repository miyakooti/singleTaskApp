//
//  TodayTaskViewController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/08.
//


//メモ：タップ処理
//まずdidselectrowatでindexpathを指定
//そのあと、そのindexpathを利用して、そのindexpathをもつデータをfirebase上で指定して、
//その値を変更して、loaddataをすれば良い気がする。あああ


import UIKit
import Firebase
import FirebaseAuth


class TodayTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, TaskCellTableViewCellDelegate {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var todaysDate:String?
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var soundFile = PlaySound()
    var tasks:[Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        taskTextField.delegate = self
        //カスタムセル登録
        tableView.register(UINib(nibName: "TaskCellTableViewCell", bundle:nil), forCellReuseIdentifier: "Cell")
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationItem.title = "Today" //親クラスのプロパティを変更するには、parentが必要です！
        todaysDate = setUpTodaysDate()
        showImageFromUserDefaults()
        print("aaaaaaaaaaaaaaaaaa")
        loadData()
        self.tableView.reloadData()
    }
    
    func setUpTodaysDate() -> String{
        // 現在日時を取得
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        print(formatter.string(from: date))
        return formatter.string(from: date)
    }
    
    //    tableView-------------------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80.0
//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskCellTableViewCell
        cell.delegate = self
        
        let task = tasks[indexPath.row]
        
        cell.index = indexPath.row
        cell.documentID = task.documentID
        cell.isCompleted = task.isCompleted
        
        
        
        cell.label.text = task.body
        cell.backView.backgroundColor = .systemTeal
        cell.label.textColor = .black
        
        if task.isCompleted == false{
            cell.checkButton.setImage(UIImage(named: "nonChecked"), for: .normal)
        } else {
            cell.checkButton.setImage(UIImage(named: "checked"), for: .normal)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false //ハイライトしない
    }
    
    //削除処理を許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    //スワイプしたセルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let task = tasks[indexPath.row]
            //ローカルのデータを削除処理
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            //リモートのデータを削除する処理
//            let task = tasks[indexPath.row]　ここにindexPathを定義してしまうと、ローカルで削除されたあとに定義することになるので、indexPathがずれてエラーになる。
            db.collection("Tasks").document(task.documentID).delete(){ error in
                if error != nil {
                    let error = error
                    print("削除失敗。内容：\(error.debugDescription)")
                    } else {
                        print("削除成功")
                }
            }
        }
    }
    
    

    //--------------------------------------------------------------------------------
    
    //エンター押したら確定
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func pushSend(_ sender: Any) {
        self.send((Any).self)
    }
    
    @IBAction func send(_ sender: Any) {
        if taskTextField.text != "", let sender = currentUser?.uid{
            
            let taskBody = taskTextField.text
            soundFile.playSound(fileName: "addSound", extensionName: "mp3")
            
            db.collection("Tasks").addDocument(data: ["sender":sender, "body":taskBody as Any, "date":todaysDate as Any, "isCompleted":false]) { (error) in
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                DispatchQueue.main.async { //非同期処理　通信が重かった時とか、ローカルで処理する。
                    self.taskTextField.text = ""
                    self.taskTextField.resignFirstResponder()
                }
            }
        }
    }
    
    func loadData(){
        db.collection("Tasks").order(by: "date").addSnapshotListener { [self] (snapShot, error) in
            self.tasks = [] //初期化しておく
            if error != nil{
                print(error.debugDescription)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                //snapshotはある一つのコレクション
                for doc in snapShotDoc{
                    
                    let data = doc.data()

                    if let sender = data["sender"] as? String, let body = data["body"] as? String, let date = data["date"] as? String, var isCompleted = data["isCompleted"] as? Bool, let docID = doc.documentID as String?{
//                        print(todaysDate)
//                        print("++++++++")
//                        print(data["date"])
                        
                        if currentUser?.uid == sender, todaysDate == (data["date"] as! String){
                            //新しいインスタンスを作成します。
                            let newTask = Task(sender: sender, body: body, date: date, isCompleted: isCompleted, documentID: docID)
                            
                            //tasksリストにappendする。
                            self.tasks.append(newTask)
                            
                            //dispatchQueueはfor分の外に出しました。
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
//                                let indexPath = IndexPath(row: self.tasks.count - 1, section: 0)
//                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            
                            }
                        }
                        
                    }
                }
                //ここにdispatchを移動すると、動作が軽くなるかもしれません

            }
        }
    }
    func showImageFromUserDefaults() {
        //UserDefaultsの中身が空でないことを確認
        if UserDefaults.standard.object(forKey: "backImage") != nil {
            print("背景画像は殻ではありません")
            let object = UserDefaults.standard.object(forKey: "backImage")
            backImageView.image = UIImage(data: object as! Data)
        } else {
            backImageView.image = UIImage(named: "back")
        }
    }
    
}
