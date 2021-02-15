//
//  CalendarViewController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/02.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import Firebase
import FirebaseFirestore
import FirebaseAuth

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TaskCellTableViewCellDelegate{
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var backImageView: UIImageView!
    
    var tasks:[Task] = []
    var datesWithElement:[String] = []
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    let soundFile = PlaySound()
    let stringDateConverter = StringDateConverter()
    
    var testDate = "2020-12-27"
    
    var todaysDate:String?
    var selectedDate:String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.delegate = self
        self.calendar.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        taskTextField.delegate = self
        tableView.register(UINib(nibName: "TaskCellTableViewCell", bundle:nil), forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .none //罫線
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationItem.title = "Calendar"
        todaysDate = setUpTodaysDate()
        selectedDate = todaysDate
        loadData()
        DispatchQueue.main.async { self.calendar.reloadData() }
        showImageFromUserDefaults()
        self.tableView.reloadData()
        
    }
    
//    カレンダー関連ーーーーーーーーーーーーーーーーーーーーーーーーーーー-------

    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let tmpDate = Calendar(identifier: .gregorian)
        var yearString = String(tmpDate.component(.year, from: date))
        var monthString = String(tmpDate.component(.month, from: date))
        var dayString = String(tmpDate.component(.day, from: date))
        
        // 1の位は01,02,09というふうにしたい。
        if monthString.count == 1{
            monthString = "0"+monthString
        }
        if dayString.count == 1{
            dayString = "0"+dayString
        }

        selectedDate = "\(yearString)/\(monthString)/\(dayString)"
        tasks.removeAll()
        self.loadData()
        //tableviewをリロードします。
        self.tableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = stringDateConverter.dateToString(date: date, format: "yyyy/MM/dd") as String?
//           print("calendarでのdateWithElementです")
//           print(datesWithElement)
           if datesWithElement.contains(dateString!){
               return 1
           }
           return 0
       }
 
    func setUpTodaysDate() -> String{
        // 現在日時を取得
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    
//    /カレンダー関連ーーーーーーーーーーーーーーーーーーーーーーーーーーー-------

    
    
    
//    tableView-------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
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
//    /tableview---------------------------------------------------------------------------
    
    //エンター押したら確定
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func pushSend(_ sender: Any) {
        self.send(sender)
    }
    
    @IBAction func send(_ sender: Any) {
        if taskTextField.text != "", let sender = currentUser?.uid{
            let taskBody = taskTextField.text
            soundFile.playSound(fileName: "addSound", extensionName: "mp3")
            db.collection("Tasks").addDocument(data: ["sender":sender, "body":taskBody as Any, "date":selectedDate as Any, "isCompleted":false]) { (error) in
                
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                DispatchQueue.main.async { //非同期処理　通信が重かった時とか、ローカルで処理する。
                    self.taskTextField.text = ""
                    self.taskTextField.resignFirstResponder()
                    self.calendar.reloadData()
                }
            }
        }
    }
    
    func loadData(){
        db.collection("Tasks").order(by: "date").addSnapshotListener { [self] (snapShot, error) in
            self.datesWithElement.removeAll()
            self.tasks.removeAll() //初期化しておく
            if error != nil{
                print(error.debugDescription)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                //snapshotはある一つのコレクション
                for doc in snapShotDoc{
                    let data = doc.data()
                    //ここのifを通ってない--------------------------------------------------
                    if let sender = data["sender"] as? String, let body = data["body"] as? String, let date = data["date"] as? String, let isCompleted = data["isCompleted"] as? Bool, let docID = doc.documentID as? String{
                        
                        if currentUser?.uid == sender{
                            datesWithElement.append(data["date"] as! String)
                        }
                        
                        if currentUser?.uid == sender, selectedDate == (data["date"] as! String){
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
