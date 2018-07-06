//
//  Note.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/7/6.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import Foundation

extension Note {
    @objc var dateForSection: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "zh_CN")
        let date = dateFormatter.string(from: self.createdAt!)
        return date
    }
}
