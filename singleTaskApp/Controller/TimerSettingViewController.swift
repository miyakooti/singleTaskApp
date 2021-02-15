//
//  TimerSettingViewController.swift
//  singleTaskApp
//
//  Created by Arai Kousuke on 2021/02/15.
//

import UIKit

class TimerSettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return settingArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(settingArray[row])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults.standard.setValue(settingArray[row], forKey: "timerSetting")
        UserDefaults.standard.synchronize()
    }
    
    
    let settingArray:[Int] = Array(1...60)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerSettingPicker.delegate = self
        timerSettingPicker.dataSource = self
        

        
        timerSettingPicker.selectRow(24, inComponent: 0, animated: true)

    }
    
    @IBOutlet weak var timerSettingPicker: UIPickerView!
    
    @IBAction func tapChange(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
