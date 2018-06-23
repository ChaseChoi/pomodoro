//
//  HistoryViewController.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/23.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    // MARK: - Properties
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension HistoryViewController: UITableViewDelegate {
    
}

extension HistoryViewController: UITableViewDataSource {
    
}
