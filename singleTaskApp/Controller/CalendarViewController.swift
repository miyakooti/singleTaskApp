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
    
    var tasks:[Task] = []
    var datesWithElement:[String] = []
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    let soundFile = PlaySound()
    
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
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todaysDate = setUpTodaysDate()
        selectedDate = todaysDate
        DispatchQueue.main.async { self.calendar.reloadData() }
    }
    
//    カレンダー関連ーーーーーーーーーーーーーーーーーーーーーーーーーーー-------

    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        selectedDate = "\(year)/\(month)/\(day)"
        tasks.removeAll()
        self.loadData()
        //tableviewをリロードします。
        self.tableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateToString(date: date, format: "yyyy/MM/dd") as String?
           print("calendarでのdateWithElementです")
           print(datesWithElement)
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
    
    func stringToDate(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    func dateToString(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
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
//    /tableview---------------------------------------------------------------------------
    

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
                        
                        datesWithElement.append(data["date"] as! String)
                        print("loadDataでのdatesWithElementです↓")
                        print(datesWithElement)
                        
                        if currentUser?.uid == sender, selectedDate == (data["date"] as! String){
                            //新しいインスタンスを作成します。
                            let newTask = Task(sender: sender, body: body, date: date, isCompleted: isCompleted, documentID: docID)
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
            }
        }
    }

}
