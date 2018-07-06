//
//  Record.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/23.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import Foundation

extension Record {
    @objc var dateForSection: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "zh_CN")
        let date = dateFormatter.string(from: self.addedDate!)
        return date
    }
}
