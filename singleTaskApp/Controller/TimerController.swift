import UIKit
import UserNotifications

class TimerController: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var clockBackView: UIView!
    
    //Timerクラスを利用する
    var timer = Timer()
    
    //秒と分の変数を用意
    var seconds:Int = 0
    var minutes:Int = 0
    var limit = 25
    
    //分のタイマーラベル
    @IBOutlet weak var minuteLabel: UILabel!
    //秒のタイマーラベル
    @IBOutlet weak var secondLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clockBackView.layer.cornerRadius = 30.0
        setUpTimer()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showImageFromUserDefaults()
    }
    
    //タイマーをスタートさせるメソッド
    @IBAction func startTimer(_ sender: Any) {
        setUpTimer()//このメソッドは、viewdidloadと、ユーザーがタイマーの変更を完了したタイミングで呼びたい。
        timer.invalidate() //一回タイマー消す
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true) //1秒毎に自分のupdateTimerメソッドを繰り返し呼び出す。
    }
    //startTimerメソッドで、繰り返し呼ばれるメソッド
    @objc func updateTimer() {
        seconds -= 1
        if seconds <= -1{
            minutes -= 1
            seconds = 59
        }
        if minutes == 0 && seconds == 0{
            resetTimer((Any).self)
        }
        if seconds < 10 {
            secondLabel.text = String("0\(seconds)")
        } else {
            secondLabel.text = String(seconds)
        }
        minuteLabel.text = String(minutes)
        
    }
    
    func setUpTimer() {
        seconds = 0
        minutes = limit
        if seconds < 10 {
            secondLabel.text = String("0\(seconds)")
        } else {
            secondLabel.text = String(seconds)
        }
        minuteLabel.text = String(minutes)
    }
    
    //リセットボタン
    @IBAction func resetTimer(_ sender: Any) {
        timer.invalidate()
        setUpTimer()
    }
    
    //開始する
    @IBAction func start(_ sender: Any) {
        startTimer(Any.self)
    }
    
    @IBAction func reset(_ sender: Any) {
        resetTimer(Any.self)
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
