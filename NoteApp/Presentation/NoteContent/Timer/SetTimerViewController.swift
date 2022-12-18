//
//  SetTimerViewController.swift
//  NoteApp
//
//  Created by Nam Ngây on 18/12/2022.
//

import UIKit

class SetTimerViewController: UIViewController {
    
    @IBOutlet weak var timerPicker: UIPickerView!
    var timeChoose: ((Int, Int, Int) -> Void)?
    
    var hour:Int = 0
    var minutes:Int = 0
    var seconds:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerPicker.delegate = self
        timerPicker.dataSource = self
    }
    
    @IBAction func setAction(_ sender: UIButton) {
        timeChoose?(hour, minutes, seconds)
        self.dismiss(animated: true, completion: nil)
    }
}

extension SetTimerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 24
        case 1,2:
            return 60
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return (timerPicker.frame.self.width - 60) / 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) hours"
        case 1:
            return "\(row) min"
        case 2:
            return "\(row) sec"
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hour = row
        case 1:
            minutes = row
        case 2:
            seconds = row
        default:
            break;
        }
    }
}
