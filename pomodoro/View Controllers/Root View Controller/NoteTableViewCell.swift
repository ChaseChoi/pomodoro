//
//  NoteTableViewCell.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/21.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    // MARK: - Static Properties
    static let reuseIdentifier = "NoteTableViewCell"
    
    // MARK: - Properties
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var costTimeLabel: UILabel!
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
