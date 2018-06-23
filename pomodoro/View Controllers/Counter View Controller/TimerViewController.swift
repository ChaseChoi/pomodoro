//
//  CounterViewController.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/22.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import UIKit
import UserNotifications

class TimerViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var timer = Timer()
    var timerIsOn = false
    var resumeTapped = false
    var totalTime = 5.0
    var secondsRemaining = 5.0
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "番茄钟"
        
        // User Notification Authorization
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        
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
        
        var backgroundTask = UIBackgroundTaskIdentifier()
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(backgroundTask)
        })
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    @objc func updateTimer() {
        if secondsRemaining < 1 {
            resetButton.sendActions(for: .touchUpInside)
            showNotification()
        } else {
            secondsRemaining -= 1
            timeLabel.text = timeString(time: secondsRemaining)
        }
    }
    
    // Initial state of buttons
    func configureInitBtns() {
        startButton.isEnabled = true
        stopButton.isEnabled = false
        resetButton.isEnabled = false
    }
}

extension TimerViewController: UNUserNotificationCenterDelegate {
    
    func showNotification() {
        let actionIdentifier = "done"
        let action = UNNotificationAction(identifier: actionIdentifier, title: "完成", options: UNNotificationActionOptions.foreground)

        let categoryIdentifier = "finishCategory"
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [action], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let content = UNMutableNotificationContent()
        content.title = "计时结束"
        content.subtitle = "休息一下吧"
        content.body = "您已成功完成一个番茄钟!"
        content.badge = 1
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = categoryIdentifier
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.4, repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // called when user interacts with notification (app not running in foreground)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse, withCompletionHandler
        completionHandler: @escaping () -> Void) {
        
        // do something with the notification
        print(response.notification.request.content.userInfo)
        if response.actionIdentifier == "done" {
            print("Done!")
        }
        
        // the docs say you should execute this asap
        return completionHandler()
    }
    
    // called if app is running in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
        notification: UNNotification, withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // show alert while app is running in foreground
        return completionHandler(UNNotificationPresentationOptions.alert)
    }
}


