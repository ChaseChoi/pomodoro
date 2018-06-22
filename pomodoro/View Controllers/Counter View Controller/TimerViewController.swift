//
//  CounterViewController.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/22.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var timer = Timer()
    var timerIsOn = false
    var resumeTapped = false
    var totalTime = 1500.0
    var secondsRemaining = 1500.0
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "番茄钟"
        // Congiure titles for buttons
        startButton.setTitle("开始", for: .normal)
        stopButton.setTitle("暂停", for: .normal)
        resetButton.setTitle("重置", for: .normal)
        
        // Initial state of buttons
        configureInitBtns()
        
        timeLabel.text = timeString(time: secondsRemaining)
    }
    
    // MARK: - Button Actions
    @IBAction func startBtnTapped() {
        if !timerIsOn {
            runTimer()
            timerIsOn = true
        }
        
    }
    
    @IBAction func stopBtnTapped() {
        if !resumeTapped {
            timer.invalidate()
            resumeTapped = true
            stopButton.setTitle("继续", for: .normal)
        } else {
            runTimer()
            resumeTapped = false
            stopButton.setTitle("暂停", for: .normal)
        }
    }
    
    @IBAction func resetBtnTapped() {
        timer.invalidate()
        
        secondsRemaining = totalTime
        timeLabel.text = timeString(time: secondsRemaining)
        timerIsOn = false
        resumeTapped = false
        configureInitBtns()
    }
    // MARK: Helper Methods
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(secondsRemaining) / 60 % 60
        let seconds = Int(secondsRemaining) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    // MARK: Congiure Timer
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        startButton.isEnabled = false
        stopButton.isEnabled = true
        resetButton.isEnabled = true
    }
    
    @objc func updateTimer() {
        if secondsRemaining < 1 {
            resetButton.sendActions(for: .touchUpInside)
            showAlert()
        } else {
            secondsRemaining -= 1
            timeLabel.text = timeString(time: secondsRemaining)
        }
    }
    func showAlert() {
        let alert = UIAlertController(title: "计时结束", message: "番茄钟计时已结束", preferredStyle: .alert)
        let action = UIAlertAction(title: "好", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Initial state of buttons
    func configureInitBtns() {
        startButton.isEnabled = true
        stopButton.isEnabled = false
        resetButton.isEnabled = false
    }
    
    
}
