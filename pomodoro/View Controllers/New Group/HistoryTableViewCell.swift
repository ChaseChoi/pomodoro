//
//  HistoryTableViewCell.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/23.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    // MARK: - Static Properties
    static let reuseIdentifier = "HistoryTableViewCell"
    
    // MARK: - Properties
    @IBOutlet weak var timerLengthLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
