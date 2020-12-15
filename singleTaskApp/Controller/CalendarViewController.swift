//
//  CalendarViewController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2020/12/02.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic




class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource{

    
    
    @IBOutlet weak var calendar: FSCalendar!
    var todaysDate:String?
    var selectedDate:String?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.delegate = self
        self.calendar.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        todaysDate = setUpTodaysDate()
        selectedDate = todaysDate
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        selectedDate = "\(year)-\(month)-\(day)"
        print(selectedDate as Any)
        print(type(of: selectedDate))
        
        if selectedDate == todaysDate{
            print("今日の日付が選択されました。")
        }
//
//        print(date)
//        print("日付けが選択されました")
//        date = String(date)
//        print(type(of: date))

        //        selectedDate = String(date)

    }
    
    func setUpTodaysDate() -> String{
        // 現在日時を取得
        let date = Date()
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

}
