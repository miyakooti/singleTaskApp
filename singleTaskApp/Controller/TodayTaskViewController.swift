//
//  TodayTaskViewController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/08.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class TodayTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskTextField: UITextField!
    
    var todaysDate:String?
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    var tasks:[Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        taskTextField.delegate = self
        //カスタムセル
        tableView.register(UINib(nibName: "TaskCellTableViewCell", bundle:nil), forCellReuseIdentifier: "Cell")
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todaysDate = setUpTodaysDate()
        print(todaysDate)
    }
    
    func setUpTodaysDate() -> String{
        // 現在日時を取得
        var date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskCellTableViewCell
        let task = tasks[indexPath.row]
        cell.label.text = task.body
        cell.backView.backgroundColor = .systemTeal
        cell.label.textColor = .black
        return cell
    }
    //--------------------------------------------------------------------------------
    
    @IBAction func pushSend(_ sender: Any) {
        self.send((Any).self)
    }
    
    @IBAction func send(_ sender: Any) {
        if taskTextField.text != "", let sender = currentUser?.uid{
            
            let taskBody = taskTextField.text
            
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
                //ここまではOK
                //snapshotはある一つのコレクション
                for doc in snapShotDoc{
                    let data = doc.data()
                    //ここのifを通ってない--------------------------------------------------
                    if let sender = data["sender"] as? String, let body = data["body"] as? String, let date = data["date"] as? String, let isCompleted = data["isCompleted"] as? Bool{
                        
                        if currentUser?.uid == sender, todaysDate == (data["date"] as! String){
                            //新しいインスタンスを作成します。
                            let newTask = Task(sender: sender, body: body, date: date, isCompleted: isCompleted)
                            print("aaa")
                            
                            //tasksリストにappendする。
                            self.tasks.append(newTask)
                            
                            //dispatchQueueはfor分の外に出しました。
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                print(self.tasks.count)
                                let indexPath = IndexPath(row: self.tasks.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            
                            }
                        }
                        
                    }
                }
                //ここにdispatchを移動すると、動作が軽くなるかもしれません

            }
        }
    }
    
    
}
